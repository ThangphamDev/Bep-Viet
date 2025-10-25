import { Injectable, NotFoundException, Logger } from '@nestjs/common';
import { Inject } from '@nestjs/common';
import { RedisService } from '../redis/redis.service';

@Injectable()
export class RecipesService {
  private readonly logger = new Logger(RecipesService.name);
  private readonly CACHE_TTL = 600; // 10 minutes for recipes (longer than suggestions)

  constructor(
    @Inject('DATABASE_CONNECTION') private db: any,
    private redisService: RedisService,
  ) {}

  /**
   * Parse instructions_md into steps array for mobile app compatibility
   * Expected format: numbered list (1., 2., 3., etc.) or markdown list (-, *, etc.)
   */
  private parseInstructionsToSteps(instructionsMd: string | null): any[] {
    if (!instructionsMd) return [];

    const steps: any[] = [];
    const lines = instructionsMd.split('\n').filter(line => line.trim());
    
    let stepNumber = 1;
    let currentStep = '';

    for (const line of lines) {
      const trimmedLine = line.trim();
      
      // Check if line starts with a number (1., 2., etc.)
      const numberedMatch = trimmedLine.match(/^(\d+)\.\s*(.+)$/);
      if (numberedMatch) {
        // Save previous step if exists
        if (currentStep) {
          steps.push({
            stepNumber: stepNumber - 1,
            instruction: currentStep.trim()
          });
        }
        // Start new step
        stepNumber = parseInt(numberedMatch[1]);
        currentStep = numberedMatch[2];
        stepNumber++;
        continue;
      }

      // Check if line starts with markdown list marker (-, *, +)
      const listMatch = trimmedLine.match(/^[-*+]\s*(.+)$/);
      if (listMatch) {
        // Save previous step if exists
        if (currentStep) {
          steps.push({
            stepNumber: stepNumber - 1,
            instruction: currentStep.trim()
          });
          stepNumber++;
        }
        // Start new step
        currentStep = listMatch[1];
        continue;
      }

      // If line doesn't start with number or list marker, append to current step
      if (currentStep) {
        currentStep += ' ' + trimmedLine;
      } else {
        // First line without marker, start first step
        currentStep = trimmedLine;
      }
    }

    // Add last step
    if (currentStep) {
      steps.push({
        stepNumber: stepNumber - 1,
        instruction: currentStep.trim()
      });
    }

    // If no structured steps found, treat entire text as one step
    if (steps.length === 0 && instructionsMd.trim()) {
      steps.push({
        stepNumber: 1,
        instruction: instructionsMd.trim()
      });
    }

    return steps;
  }

  async getAllRecipes(filters: any = {}) {
    try {
      // Query to get all public recipes (with or without ingredients)
      let query = `
        SELECT DISTINCT
          r.id,
          r.name_vi,
          r.name_en,
          r.meal_type,
          r.difficulty,
          r.cook_time_min,
          r.region,
          r.base_region,
          r.authenticity,
          r.spice_level,
          r.saltiness,
          r.hardness,
          r.image_url,
          r.rating_avg,
          r.rating_count,
          r.created_at,
          r.updated_at
        FROM recipes r
        LEFT JOIN recipe_ingredients ri ON r.id = ri.recipe_id
        WHERE r.is_public = 1
      `;
      
      let params: any[] = [];

      if (filters.meal_type) {
        query += ' AND r.meal_type = ?';
        params.push(filters.meal_type);
      }

      if (filters.difficulty) {
        query += ' AND r.difficulty = ?';
        params.push(filters.difficulty);
      }

      if (filters.region) {
        query += ' AND r.base_region = ?';
        params.push(filters.region);
      }

      if (filters.max_time) {
        query += ' AND r.cook_time_min <= ?';
        params.push(filters.max_time);
      }

    if (filters.search) {
      query += ' AND (LOWER(r.name_vi) LIKE LOWER(?) OR LOWER(r.name_en) LIKE LOWER(?))';
      params.push(`%${filters.search}%`, `%${filters.search}%`);
    }

      query += ' ORDER BY r.rating_avg DESC, r.created_at DESC';

    // Add pagination support
    if (filters.limit) {
      query += ` LIMIT ${parseInt(filters.limit.toString())}`;
    }
    if (filters.offset) {
      query += ` OFFSET ${parseInt(filters.offset.toString())}`;
    }

      const [recipes] = await this.db.execute(query, params);

      return {
        success: true,
        data: recipes,
      };
    } catch (error) {
      console.error('Error in getAllRecipes:', error);
      return {
        success: false,
        error: error.message,
        data: [],
      };
    }
  }

  async getRecipeById(id: string, userId?: string) {
    // Try cache first (without user-specific data)
    const cacheKey = `recipe:${id}`;
    let recipe: any;

    if (this.redisService.isReady()) {
      const cached = await this.redisService.getJson(cacheKey);
      if (cached) {
        this.logger.log(`Cache HIT for recipe: ${id}`);
        recipe = cached;
      }
    }

    if (!recipe) {
      this.logger.log(`Cache MISS for recipe: ${id}`);
      
      const [recipes] = await this.db.execute(
        `SELECT 
          r.id,
          r.name_vi,
          r.name_en,
          r.meal_type,
          r.difficulty,
          r.cook_time_min,
          r.region,
          r.base_region,
          r.authenticity,
          r.spice_level,
          r.saltiness,
          r.hardness,
          r.image_url,
          r.instructions_md,
          r.nutrition_json,
          r.rating_avg,
          r.rating_count,
          r.created_at,
          r.updated_at
        FROM recipes r
        WHERE r.id = ?`,
        [id]
      );

      recipe = (recipes as any[])[0];
      if (!recipe) {
        throw new NotFoundException('Recipe not found');
      }
    }

    // Check if recipe is in user's favorites (always fresh, not cached)
    if (userId) {
      const [favoriteCheck] = await this.db.execute(
        'SELECT 1 FROM favorites WHERE user_id = ? AND recipe_id = ?',
        [userId, id]
      );
      recipe.is_favorite = (favoriteCheck as any[]).length > 0;
    } else {
      recipe.is_favorite = false;
    }

    // If not cached, get all related data
    if (!recipe.ingredients) {
      // Get ingredients
      const [ingredients] = await this.db.execute(
        `SELECT 
          ri.id,
          ri.ingredient_id,
          i.name as ingredient_name,
          ri.quantity,
          ri.unit,
          ri.note
        FROM recipe_ingredients ri
        JOIN ingredients i ON ri.ingredient_id = i.id
        WHERE ri.recipe_id = ?
        ORDER BY ri.id`,
        [id]
      );

      // Get tags
      const [tags] = await this.db.execute(
        `SELECT 
          t.id,
          t.name,
          t.type
        FROM recipe_tags rt
        JOIN tags t ON rt.tag_id = t.id
        WHERE rt.recipe_id = ?`,
        [id]
      );

      // Get variants
      const [variants] = await this.db.execute(
        `SELECT 
          rv.id,
          rv.region,
          rv.title,
          rv.notes
        FROM recipe_variants rv
        WHERE rv.recipe_id = ?`,
        [id]
      );

      // Parse instructions_md into steps array for mobile compatibility
      const steps = this.parseInstructionsToSteps(recipe.instructions_md);

      // Add to recipe object
      recipe.ingredients = ingredients;
      recipe.tags = tags;
      recipe.variants = variants;
      recipe.steps = steps;

      // Cache the complete recipe (without is_favorite)
      if (this.redisService.isReady()) {
        const recipeToCache = { ...recipe };
        delete recipeToCache.is_favorite; // Don't cache user-specific data
        await this.redisService.setJson(cacheKey, recipeToCache, this.CACHE_TTL);
        this.logger.log(`Cached recipe: ${id}`);
      }
    }

    return {
      success: true,
      data: recipe,
    };
  }

  async getRecipeIngredients(recipeId: string) {
    const [ingredients] = await this.db.execute(
      `SELECT 
        ri.id,
        ri.ingredient_id,
        i.name as ingredient_name,
        i.default_unit,
        ri.quantity,
        ri.unit,
        ri.note as notes
      FROM recipe_ingredients ri
      JOIN ingredients i ON ri.ingredient_id = i.id
      WHERE ri.recipe_id = ?
      ORDER BY ri.id`,
      [recipeId]
    );

    return {
      success: true,
      data: ingredients,
    };
  }

  async getRecipeVariants(recipeId: string) {
    const [variants] = await this.db.execute(
      `SELECT 
        rv.id,
        rv.region,
        rv.title,
        rv.notes
      FROM recipe_variants rv
      WHERE rv.recipe_id = ?
      ORDER BY rv.region`,
      [recipeId]
    );

    return {
      success: true,
      data: variants,
    };
  }

  async createRecipe(recipeData: any) {
    const {
      name_vi,
      name_en,
      meal_type,
      difficulty,
      cook_time_min,
      region,
      base_region,
      authenticity,
      spice_level,
      saltiness,
      hardness,
      image_url,
      instructions_md,
      nutrition_json,
      author_id
    } = recipeData;

    const [result] = await this.db.execute(
      `INSERT INTO recipes 
       (name_vi, name_en, meal_type, difficulty, cook_time_min, region, base_region, 
        authenticity, spice_level, saltiness, hardness, image_url, instructions_md, 
        nutrition_json, author_id)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [name_vi, name_en, meal_type, difficulty, cook_time_min, region, base_region,
       authenticity, spice_level, saltiness, hardness, image_url, instructions_md,
       nutrition_json, author_id]
    );

    return {
      success: true,
      data: { id: (result as any).insertId },
    };
  }

  async updateRecipe(id: string, recipeData: any) {
    const {
      name_vi,
      name_en,
      meal_type,
      difficulty,
      cook_time_min,
      region,
      base_region,
      authenticity,
      spice_level,
      saltiness,
      hardness,
      image_url,
      instructions_md,
      nutrition_json
    } = recipeData;

    const [result] = await this.db.execute(
      `UPDATE recipes SET 
       name_vi = ?, name_en = ?, meal_type = ?, difficulty = ?, cook_time_min = ?, 
       region = ?, base_region = ?, authenticity = ?, spice_level = ?, saltiness = ?, 
       hardness = ?, image_url = ?, instructions_md = ?, nutrition_json = ?
       WHERE id = ?`,
      [name_vi, name_en, meal_type, difficulty, cook_time_min, region, base_region,
       authenticity, spice_level, saltiness, hardness, image_url, instructions_md,
       nutrition_json, id]
    );

    if ((result as any).affectedRows === 0) {
      throw new NotFoundException('Recipe not found');
    }

    return {
      success: true,
      message: 'Recipe updated successfully',
    };
  }

  async deleteRecipe(id: string) {
    const [result] = await this.db.execute(
      'DELETE FROM recipes WHERE id = ?',
      [id]
    );

    if ((result as any).affectedRows === 0) {
      throw new NotFoundException('Recipe not found');
    }

    return {
      success: true,
      message: 'Recipe deleted successfully',
    };
  }

  async addRecipeIngredient(recipeId: string, ingredientData: any) {
    const { ingredient_id, quantity, unit, note } = ingredientData;

    const [result] = await this.db.execute(
      `INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit, note)
       VALUES (?, ?, ?, ?, ?)
       ON DUPLICATE KEY UPDATE quantity = VALUES(quantity), unit = VALUES(unit), note = VALUES(note)`,
      [recipeId, ingredient_id, quantity, unit, note]
    );

    return {
      success: true,
      data: { id: (result as any).insertId },
    };
  }

  async removeRecipeIngredient(recipeId: string, ingredientId: string) {
    const [result] = await this.db.execute(
      'DELETE FROM recipe_ingredients WHERE recipe_id = ? AND ingredient_id = ?',
      [recipeId, ingredientId]
    );

    return {
      success: true,
      message: 'Ingredient removed from recipe',
    };
  }

  async addRecipeTag(recipeId: string, tagId: string) {
    const [result] = await this.db.execute(
      `INSERT IGNORE INTO recipe_tags (recipe_id, tag_id) VALUES (?, ?)`,
      [recipeId, tagId]
    );

    return {
      success: true,
      message: 'Tag added to recipe',
    };
  }

  async removeRecipeTag(recipeId: string, tagId: string) {
    const [result] = await this.db.execute(
      'DELETE FROM recipe_tags WHERE recipe_id = ? AND tag_id = ?',
      [recipeId, tagId]
    );

    return {
      success: true,
      message: 'Tag removed from recipe',
    };
  }

  // Favorites
  async getFavorites(userId: string) {
    const [recipes] = await this.db.execute(
      `SELECT 
        r.id,
        r.name_vi as name,
        r.name_en,
        r.meal_type,
        r.difficulty,
        r.cook_time_min as cookTimeMinutes,
        r.region,
        r.base_region as baseRegion,
        r.image_url as imageUrl,
        r.rating_avg,
        r.rating_count,
        f.created_at as favorited_at
      FROM favorites f
      JOIN recipes r ON f.recipe_id = r.id
      WHERE f.user_id = ?
      ORDER BY f.created_at DESC`,
      [userId]
    );

    return {
      success: true,
      data: recipes,
    };
  }

  async addFavorite(userId: string, recipeId: string) {
    try {
      await this.db.execute(
        'INSERT INTO favorites (user_id, recipe_id) VALUES (?, ?)',
        [userId, recipeId]
      );

      return {
        success: true,
        message: 'Added to favorites',
      };
    } catch (error: any) {
      // If already exists (duplicate key error)
      if (error.code === 'ER_DUP_ENTRY') {
        return {
          success: true,
          message: 'Already in favorites',
        };
      }
      throw error;
    }
  }

  async removeFavorite(userId: string, recipeId: string) {
    await this.db.execute(
      'DELETE FROM favorites WHERE user_id = ? AND recipe_id = ?',
      [userId, recipeId]
    );

    return {
      success: true,
      message: 'Removed from favorites',
    };
  }
}