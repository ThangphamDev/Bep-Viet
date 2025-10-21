import { Injectable, NotFoundException } from '@nestjs/common';
import { Inject } from '@nestjs/common';

@Injectable()
export class IngredientsService {
  constructor(@Inject('DATABASE_CONNECTION') private db: any) {}

  async getAllIngredients(search?: string, categoryId?: number) {
    let query = `
      SELECT 
        i.id,
        i.name,
        i.category_id,
        ic.name as category_name,
        i.default_unit,
        i.shelf_life_days,
        i.perishable,
        i.notes,
        i.created_at,
        i.updated_at
      FROM ingredients i
      LEFT JOIN ingredient_categories ic ON i.category_id = ic.id
      WHERE 1=1
    `;
    
    let params: any[] = [];

    if (search) {
      query += ' AND (i.name LIKE ? OR i.notes LIKE ?)';
      params.push(`%${search}%`, `%${search}%`);
    }

    if (categoryId) {
      query += ' AND i.category_id = ?';
      params.push(categoryId);
    }

    query += ' ORDER BY i.name';

    const [ingredients] = await this.db.execute(query, params);

    return {
      success: true,
      data: ingredients,
    };
  }

  async getIngredientById(id: string) {
    const [ingredients] = await this.db.execute(
      `SELECT 
        i.id,
        i.name,
        i.category_id,
        ic.name as category_name,
        i.default_unit,
        i.shelf_life_days,
        i.substitutions_json,
        i.perishable,
        i.notes,
        i.created_at,
        i.updated_at
      FROM ingredients i
      LEFT JOIN ingredient_categories ic ON i.category_id = ic.id
      WHERE i.id = ?`,
      [id]
    );

    const ingredient = (ingredients as any[])[0];
    if (!ingredient) {
      throw new NotFoundException('Ingredient not found');
    }

    return {
      success: true,
      data: ingredient,
    };
  }

  async getIngredientPrices(ingredientId: string, region?: string) {
    let query = `
      SELECT 
        ip.id,
        ip.region,
        ip.unit,
        ip.price_per_unit,
        ip.currency,
        ip.source,
        ip.last_updated
      FROM ingredient_prices ip
      WHERE ip.ingredient_id = ?
    `;
    
    let params: any[] = [ingredientId];

    if (region) {
      query += ' AND ip.region = ?';
      params.push(region);
    }

    query += ' ORDER BY ip.region, ip.unit';

    const [prices] = await this.db.execute(query, params);

    return {
      success: true,
      data: prices,
    };
  }

  async getIngredientCategories() {
    const [categories] = await this.db.execute(
      'SELECT id, name FROM ingredient_categories ORDER BY name'
    );

    return {
      success: true,
      data: categories,
    };
  }

  async searchIngredients(query: string) {
    const [ingredients] = await this.db.execute(
      `SELECT 
        i.id,
        i.name,
        ic.name as category_name,
        i.default_unit
      FROM ingredients i
      LEFT JOIN ingredient_categories ic ON i.category_id = ic.id
      WHERE i.name LIKE ? OR EXISTS (
        SELECT 1 FROM ingredient_aliases ia 
        WHERE ia.ingredient_id = i.id AND ia.alias LIKE ?
      )
      ORDER BY i.name
      LIMIT 20`,
      [`%${query}%`, `%${query}%`]
    );

    return {
      success: true,
      data: ingredients,
    };
  }

  async getIngredientSubstitutions(id: string) {
    // Get the ingredient with its substitutions
    const [ingredients] = await this.db.execute(
      `SELECT 
        i.id,
        i.name,
        i.substitutions_json
      FROM ingredients i
      WHERE i.id = ?`,
      [id]
    );

    const ingredient = (ingredients as any[])[0];
    if (!ingredient) {
      throw new NotFoundException('Ingredient not found');
    }

    // Parse substitutions_json (MySQL driver auto-parses JSON, but just in case)
    let substitutions = [];
    if (ingredient.substitutions_json) {
      const subsData = typeof ingredient.substitutions_json === 'string' 
        ? JSON.parse(ingredient.substitutions_json) 
        : ingredient.substitutions_json;
      
      // Extract substitutes array
      substitutions = subsData.substitutes || subsData || [];
    }

    return {
      success: true,
      data: {
        ingredient_id: ingredient.id,
        ingredient_name: ingredient.name,
        substitutes: substitutions
      },
    };
  }

  async createIngredient(ingredientData: any) {
    const {
      name,
      category_id,
      default_unit,
      shelf_life_days,
      substitutions_json,
      perishable,
      notes
    } = ingredientData;

    // Generate UUID
    const [uuidResult] = await this.db.execute('SELECT UUID() as id');
    const ingredientId = (uuidResult as any[])[0].id;

    await this.db.execute(
      `INSERT INTO ingredients 
       (id, name, category_id, default_unit, shelf_life_days, substitutions_json, perishable, notes)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
      [
        ingredientId,
        name,
        category_id ?? null,
        default_unit,
        shelf_life_days ?? null,
        substitutions_json ? JSON.stringify(substitutions_json) : null,
        perishable ?? 1,
        notes ?? null
      ]
    );

    return {
      success: true,
      data: { id: ingredientId },
    };
  }

  async updateIngredient(id: string, ingredientData: any) {
    const {
      name,
      category_id,
      default_unit,
      shelf_life_days,
      substitutions_json,
      perishable,
      notes
    } = ingredientData;

    const [result] = await this.db.execute(
      `UPDATE ingredients SET 
       name = COALESCE(?, name),
       category_id = ?,
       default_unit = COALESCE(?, default_unit),
       shelf_life_days = ?,
       substitutions_json = ?,
       perishable = COALESCE(?, perishable),
       notes = ?
       WHERE id = ?`,
      [
        name ?? null,
        category_id ?? null,
        default_unit ?? null,
        shelf_life_days ?? null,
        substitutions_json ? JSON.stringify(substitutions_json) : null,
        perishable ?? null,
        notes ?? null,
        id
      ]
    );

    if ((result as any).affectedRows === 0) {
      throw new NotFoundException('Ingredient not found');
    }

    return {
      success: true,
      message: 'Ingredient updated successfully',
    };
  }

  async deleteIngredient(id: string) {
    const [result] = await this.db.execute(
      'DELETE FROM ingredients WHERE id = ?',
      [id]
    );

    if ((result as any).affectedRows === 0) {
      throw new NotFoundException('Ingredient not found');
    }

    return {
      success: true,
      message: 'Ingredient deleted successfully',
    };
  }
}