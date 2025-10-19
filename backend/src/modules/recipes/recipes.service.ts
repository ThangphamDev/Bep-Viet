import { Injectable, NotFoundException } from '@nestjs/common';
import { Inject } from '@nestjs/common';

@Injectable()
export class RecipesService {
  constructor(@Inject('DATABASE_CONNECTION') private db: any) {}

  async getAllRecipes(filters: any = {}) {
    try {
      // Simple query to get recipes with ingredients
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
        INNER JOIN recipe_ingredients ri ON r.id = ri.recipe_id
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

      if (filters.limit) {
        query += ` LIMIT ${parseInt(filters.limit.toString())}`;
      } else {
        query += ' LIMIT 50'; // Default limit
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

  async getRecipeById(id: string) {
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

    const recipe = (recipes as any[])[0];
    if (!recipe) {
      throw new NotFoundException('Recipe not found');
    }

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

    return {
      success: true,
      data: {
        ...recipe,
        ingredients,
        tags,
        variants,
      },
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
}