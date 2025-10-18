import { Injectable, NotFoundException } from '@nestjs/common';
import { Inject } from '@nestjs/common';

@Injectable()
export class PricesService {
  constructor(@Inject('DATABASE_CONNECTION') private db: any) {}

  async getPricesByRegion(region: string) {
    const [prices] = await this.db.execute(
      `SELECT 
        ip.id,
        ip.ingredient_id,
        i.name as ingredient_name,
        ip.region,
        ip.unit,
        ip.price_per_unit,
        ip.currency,
        ip.source,
        ip.last_updated
      FROM ingredient_prices ip
      JOIN ingredients i ON ip.ingredient_id = i.id
      WHERE ip.region = ?
      ORDER BY i.name`,
      [region]
    );

    return {
      success: true,
      data: prices,
    };
  }

  async getPriceByIngredientAndRegion(ingredientId: string, region: string, unit?: string) {
    let query = `
      SELECT 
        ip.id,
        ip.ingredient_id,
        i.name as ingredient_name,
        ip.region,
        ip.unit,
        ip.price_per_unit,
        ip.currency,
        ip.source,
        ip.last_updated
      FROM ingredient_prices ip
      JOIN ingredients i ON ip.ingredient_id = i.id
      WHERE ip.ingredient_id = ? AND ip.region = ?
    `;
    
    let params: any[] = [ingredientId, region];

    if (unit) {
      query += ' AND ip.unit = ?';
      params.push(unit);
    }

    const [prices] = await this.db.execute(query, params);

    return {
      success: true,
      data: prices,
    };
  }

  async createPrice(priceData: any) {
    const {
      ingredient_id,
      region,
      unit,
      price_per_unit,
      currency = 'VND',
      source
    } = priceData;

    const [result] = await this.db.execute(
      `INSERT INTO ingredient_prices 
       (ingredient_id, region, unit, price_per_unit, currency, source)
       VALUES (?, ?, ?, ?, ?, ?)
       ON DUPLICATE KEY UPDATE
       price_per_unit = VALUES(price_per_unit),
       source = VALUES(source),
       last_updated = CURRENT_TIMESTAMP`,
      [ingredient_id, region, unit, price_per_unit, currency, source]
    );

    return {
      success: true,
      data: { id: (result as any).insertId || 'updated' },
    };
  }

  async updatePrice(id: string, priceData: any) {
    const {
      unit,
      price_per_unit,
      currency,
      source
    } = priceData;

    const [result] = await this.db.execute(
      `UPDATE ingredient_prices SET 
       unit = ?, price_per_unit = ?, currency = ?, source = ?, last_updated = CURRENT_TIMESTAMP
       WHERE id = ?`,
      [unit, price_per_unit, currency, source, id]
    );

    if ((result as any).affectedRows === 0) {
      throw new NotFoundException('Price not found');
    }

    return {
      success: true,
      message: 'Price updated successfully',
    };
  }

  async deletePrice(id: string) {
    const [result] = await this.db.execute(
      'DELETE FROM ingredient_prices WHERE id = ?',
      [id]
    );

    if ((result as any).affectedRows === 0) {
      throw new NotFoundException('Price not found');
    }

    return {
      success: true,
      message: 'Price deleted successfully',
    };
  }

  async getPriceHistory(ingredientId: string, region: string, days: number = 30) {
    // This would require a price_history table in a real implementation
    // For now, we'll return current prices
    const [prices] = await this.db.execute(
      `SELECT 
        ip.id,
        ip.ingredient_id,
        i.name as ingredient_name,
        ip.region,
        ip.unit,
        ip.price_per_unit,
        ip.currency,
        ip.source,
        ip.last_updated
      FROM ingredient_prices ip
      JOIN ingredients i ON ip.ingredient_id = i.id
      WHERE ip.ingredient_id = ? AND ip.region = ?
      ORDER BY ip.last_updated DESC`,
      [ingredientId, region]
    );

    return {
      success: true,
      data: prices,
    };
  }

  async estimateRecipeCost(recipeId: string, region: string, servings: number = 1) {
    const [ingredients] = await this.db.execute(
      `SELECT 
        ri.ingredient_id,
        i.name as ingredient_name,
        ri.quantity,
        ri.unit,
        ip.price_per_unit,
        ip.currency
      FROM recipe_ingredients ri
      JOIN ingredients i ON ri.ingredient_id = i.id
      LEFT JOIN ingredient_prices ip ON ri.ingredient_id = ip.ingredient_id AND ip.region = ?
      WHERE ri.recipe_id = ?`,
      [region, recipeId]
    );

    let totalCost = 0;
    const costBreakdown = (ingredients as any[]).map(ingredient => {
      const cost = ingredient.price_per_unit 
        ? (ingredient.quantity * ingredient.price_per_unit * servings)
        : 0;
      
      totalCost += cost;

      return {
        ingredient_id: ingredient.ingredient_id,
        ingredient_name: ingredient.ingredient_name,
        quantity: ingredient.quantity * servings,
        unit: ingredient.unit,
        price_per_unit: ingredient.price_per_unit,
        cost: cost,
        currency: ingredient.currency
      };
    });

    return {
      success: true,
      data: {
        recipe_id: recipeId,
        region,
        servings,
        total_cost: totalCost,
        currency: 'VND',
        breakdown: costBreakdown
      },
    };
  }
}