import { Injectable, NotFoundException } from '@nestjs/common';
import { Inject } from '@nestjs/common';

@Injectable()
export class PantryService {
  constructor(@Inject('DATABASE_CONNECTION') private db: any) {}

  async getUserPantry(userId: string) {
    if (!userId) {
      throw new NotFoundException('User ID is required');
    }

    const [items] = await this.db.execute(
      `SELECT 
        pi.id,
        pi.ingredient_id,
        i.name as ingredient_name,
        i.default_unit,
        pi.quantity,
        pi.unit,
        pi.expire_date,
        pi.location,
        pi.batch_code,
        pi.created_at,
        pi.updated_at,
        CASE 
          WHEN pi.expire_date IS NULL THEN 'unknown'
          WHEN pi.expire_date < CURDATE() THEN 'expired'
          WHEN pi.expire_date <= DATE_ADD(CURDATE(), INTERVAL 3 DAY) THEN 'expiring_soon'
          ELSE 'good'
        END as status
      FROM pantry_items pi
      JOIN ingredients i ON pi.ingredient_id = i.id
      WHERE pi.user_id = ? AND pi.quantity > 0
      ORDER BY pi.expire_date ASC, pi.created_at DESC`,
      [userId]
    );

    return {
      success: true,
      data: items,
    };
  }

  async addPantryItem(userId: string, itemData: any) {
    const {
      ingredient_id,
      quantity,
      unit,
      expire_date,
      location = '',
      batch_code = ''
    } = itemData;

    const [result] = await this.db.execute(
      `INSERT INTO pantry_items 
       (user_id, ingredient_id, quantity, unit, expire_date, location, batch_code)
       VALUES (?, ?, ?, ?, ?, ?, ?)
       ON DUPLICATE KEY UPDATE 
       quantity = quantity + VALUES(quantity),
       expire_date = VALUES(expire_date),
       location = VALUES(location),
       batch_code = VALUES(batch_code)`,
      [userId, ingredient_id, quantity, unit, expire_date, location, batch_code]
    );

    return {
      success: true,
      data: { id: (result as any).insertId },
    };
  }

  async updatePantryItem(itemId: string, userId: string, updateData: any) {
    const {
      quantity,
      unit,
      expire_date,
      location,
      batch_code
    } = updateData;

    const [result] = await this.db.execute(
      `UPDATE pantry_items SET 
       quantity = ?, unit = ?, expire_date = ?, location = ?, batch_code = ?
       WHERE id = ? AND user_id = ?`,
      [quantity, unit, expire_date, location, batch_code, itemId, userId]
    );

    if ((result as any).affectedRows === 0) {
      throw new NotFoundException('Pantry item not found');
    }

    return {
      success: true,
      message: 'Pantry item updated successfully',
    };
  }

  async deletePantryItem(itemId: string, userId: string) {
    const [result] = await this.db.execute(
      'DELETE FROM pantry_items WHERE id = ? AND user_id = ?',
      [itemId, userId]
    );

    if ((result as any).affectedRows === 0) {
      throw new NotFoundException('Pantry item not found');
    }

    return {
      success: true,
      message: 'Pantry item deleted successfully',
    };
  }

  async consumePantryItem(userId: string, ingredientId: string, quantity: number) {
    const [result] = await this.db.execute(
      `UPDATE pantry_items 
       SET quantity = GREATEST(0, quantity - ?)
       WHERE user_id = ? AND ingredient_id = ? AND quantity >= ?
       ORDER BY expire_date ASC
       LIMIT 1`,
      [quantity, userId, ingredientId, quantity]
    );

    if ((result as any).affectedRows === 0) {
      throw new NotFoundException('Insufficient quantity in pantry');
    }

    return {
      success: true,
      message: 'Pantry item consumed successfully',
    };
  }

  async getExpiringItems(userId: string, days: number = 3) {
    const [items] = await this.db.execute(
      `SELECT 
        pi.id,
        pi.ingredient_id,
        i.name as ingredient_name,
        pi.quantity,
        pi.unit,
        pi.expire_date,
        pi.location,
        DATEDIFF(pi.expire_date, CURDATE()) as days_until_expiry
      FROM pantry_items pi
      JOIN ingredients i ON pi.ingredient_id = i.id
      WHERE pi.user_id = ? 
        AND pi.quantity > 0
        AND pi.expire_date IS NOT NULL
        AND pi.expire_date <= DATE_ADD(CURDATE(), INTERVAL ? DAY)
        AND pi.expire_date >= CURDATE()
      ORDER BY pi.expire_date ASC`,
      [userId, days]
    );

    return {
      success: true,
      data: items,
    };
  }

  async getExpiredItems(userId: string) {
    const [items] = await this.db.execute(
      `SELECT 
        pi.id,
        pi.ingredient_id,
        i.name as ingredient_name,
        pi.quantity,
        pi.unit,
        pi.expire_date,
        pi.location,
        DATEDIFF(CURDATE(), pi.expire_date) as days_expired
      FROM pantry_items pi
      JOIN ingredients i ON pi.ingredient_id = i.id
      WHERE pi.user_id = ? 
        AND pi.quantity > 0
        AND pi.expire_date < CURDATE()
      ORDER BY pi.expire_date ASC`,
      [userId]
    );

    return {
      success: true,
      data: items,
    };
  }

  async getPantrySuggestions(userId: string, limit: number = 10) {
    // Get pantry items
    const [pantryItems] = await this.db.execute(
      `SELECT 
        pi.ingredient_id,
        i.name as ingredient_name,
        pi.quantity,
        pi.unit,
        pi.expire_date
      FROM pantry_items pi
      JOIN ingredients i ON pi.ingredient_id = i.id
      WHERE pi.user_id = ? AND pi.quantity > 0
      ORDER BY pi.expire_date ASC`,
      [userId]
    );

    const pantryIds = (pantryItems as any[]).map(item => item.ingredient_id);

    if (pantryIds.length === 0) {
      return {
        success: true,
        data: [],
        message: 'Không có nguyên liệu trong tủ lạnh'
      };
    }

    // Find recipes that use pantry ingredients
    const [recipes] = await this.db.execute(
      `SELECT DISTINCT
        r.id as recipe_id,
        r.name_vi,
        r.name_en,
        r.meal_type,
        r.difficulty,
        r.cook_time_min,
        r.spice_level,
        r.rating_avg,
        r.image_url,
        COUNT(ri.ingredient_id) as pantry_match_count,
        COUNT(DISTINCT ri.ingredient_id) as total_ingredients
      FROM recipes r
      JOIN recipe_ingredients ri ON r.id = ri.recipe_id
      WHERE r.is_public = 1 AND ri.ingredient_id IN (${pantryIds.map(() => '?').join(',')})
      GROUP BY r.id
      HAVING pantry_match_count >= 2
      ORDER BY pantry_match_count DESC, r.rating_avg DESC
      LIMIT ?`,
      [...pantryIds, limit]
    );

    return {
      success: true,
      data: recipes,
      pantry_items: pantryItems
    };
  }

  async getPantryStats(userId: string) {
    const [stats] = await this.db.execute(
      `SELECT 
        COUNT(*) as total_items,
        SUM(quantity) as total_quantity,
        COUNT(CASE WHEN expire_date < CURDATE() THEN 1 END) as expired_count,
        COUNT(CASE WHEN expire_date <= DATE_ADD(CURDATE(), INTERVAL 3 DAY) AND expire_date >= CURDATE() THEN 1 END) as expiring_soon_count,
        COUNT(CASE WHEN location = 'fridge' THEN 1 END) as fridge_items,
        COUNT(CASE WHEN location = 'freezer' THEN 1 END) as freezer_items,
        COUNT(CASE WHEN location = 'shelf' THEN 1 END) as shelf_items
      FROM pantry_items 
      WHERE user_id = ? AND quantity > 0`,
      [userId]
    );

    return {
      success: true,
      data: (stats as any[])[0] || {
        total_items: 0,
        total_quantity: 0,
        expired_count: 0,
        expiring_soon_count: 0,
        fridge_items: 0,
        freezer_items: 0,
        shelf_items: 0
      },
    };
  }
}
