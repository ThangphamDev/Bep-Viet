import { Injectable, NotFoundException } from '@nestjs/common';
import { Inject } from '@nestjs/common';

@Injectable()
export class ShoppingService {
  constructor(@Inject('DATABASE_CONNECTION') private db: any) {}

  async createShoppingList(userId: string, listData: any) {
    const { title, week_range, is_shared = false, note } = listData;

    // Generate UUID
    const [uuidResult] = await this.db.execute('SELECT UUID() as id');
    const listId = (uuidResult as any[])[0].id;

    await this.db.execute(
      `INSERT INTO shopping_lists (id, owner_id, title, week_range, is_shared)
       VALUES (?, ?, ?, ?, ?)`,
      [listId, userId, title, week_range ?? null, is_shared]
    );

    return {
      success: true,
      data: { id: listId },
    };
  }

  async getUserShoppingLists(userId: string) {
    if (!userId) {
      throw new NotFoundException('User ID is required');
    }

    // Get all shopping lists for user
    const [lists] = await this.db.execute(
      `SELECT 
        sl.id,
        sl.title,
        sl.week_range,
        sl.is_shared,
        sl.created_at,
        sl.updated_at
      FROM shopping_lists sl
      WHERE sl.owner_id = ?
      ORDER BY sl.created_at DESC`,
      [userId]
    );

    // For each list, get its items
    const listsWithItems = await Promise.all(
      (lists as any[]).map(async (list) => {
        const [items] = await this.db.execute(
          `SELECT 
            sli.id,
            sli.list_id as shopping_list_id,
            sli.ingredient_id,
            i.name as ingredient_name,
            sli.quantity,
            sli.unit,
            sli.store_section as store_section_id,
            ss.name as store_section_name,
            sli.is_checked,
            sli.note as notes,
            sli.source_recipe_id,
            r.name_vi as recipe_name,
            ip.price_per_unit as estimated_price,
            ip.currency,
            (sli.quantity * COALESCE(ip.price_per_unit, 0)) as estimated_cost,
            0 as priority
          FROM shopping_list_items sli
          JOIN ingredients i ON sli.ingredient_id = i.id
          LEFT JOIN store_sections ss ON sli.store_section = ss.code
          LEFT JOIN recipes r ON sli.source_recipe_id = r.id
          LEFT JOIN ingredient_prices ip ON sli.ingredient_id = ip.ingredient_id AND ip.region = (
            SELECT region FROM users WHERE id = ?
          )
          WHERE sli.list_id = ?
          ORDER BY ss.name, i.name`,
          [userId, list.id]
        );

        return {
          ...list,
          items: items,
        };
      })
    );

    return {
      success: true,
      data: listsWithItems,
    };
  }

  async getShoppingList(listId: string, userId: string) {
    const [lists] = await this.db.execute(
      `SELECT 
        sl.id,
        sl.title,
        sl.week_range,
        sl.is_shared,
        sl.created_at,
        sl.updated_at
      FROM shopping_lists sl
      WHERE sl.id = ? AND sl.owner_id = ?`,
      [listId, userId]
    );

    const list = (lists as any[])[0];
    if (!list) {
      throw new NotFoundException('Shopping list not found');
    }

    // Get items grouped by store section
    const [items] = await this.db.execute(
      `SELECT 
        sli.id,
        sli.list_id as shopping_list_id,
        sli.ingredient_id,
        i.name as ingredient_name,
        sli.quantity,
        sli.unit,
        sli.store_section as store_section_id,
        ss.name as store_section_name,
        sli.is_checked,
        sli.note as notes,
        sli.source_recipe_id,
        r.name_vi as recipe_name,
        ip.price_per_unit as estimated_price,
        ip.currency,
        (sli.quantity * COALESCE(ip.price_per_unit, 0)) as estimated_cost,
        0 as priority
      FROM shopping_list_items sli
      JOIN ingredients i ON sli.ingredient_id = i.id
      LEFT JOIN store_sections ss ON sli.store_section = ss.code
      LEFT JOIN recipes r ON sli.source_recipe_id = r.id
      LEFT JOIN ingredient_prices ip ON sli.ingredient_id = ip.ingredient_id AND ip.region = (
        SELECT region FROM users WHERE id = ?
      )
      WHERE sli.list_id = ?
      ORDER BY ss.name, i.name`,
      [userId, listId]
    );

    // Group items by store section
    const groupedItems = {};
    let totalCost = 0;

    for (const item of items as any[]) {
      const section = item.store_section || 'OTHER';
      if (!groupedItems[section]) {
        groupedItems[section] = {
          section_code: section,
          section_name: item.section_name || 'Khác',
          items: [],
          total_cost: 0
        };
      }
      
      groupedItems[section].items.push(item);
      groupedItems[section].total_cost += item.estimated_cost || 0;
      totalCost += item.estimated_cost || 0;
    }

    return {
      success: true,
      data: {
        ...list,
        items: items, // Add items array for mobile compatibility
        groups: Object.values(groupedItems),
        total_cost: totalCost,
        total_items: items.length,
        checked_items: (items as any[]).filter(item => item.is_checked).length
      },
    };
  }

  async addItemToList(listId: string, itemData: any) {
    const {
      ingredient_id,
      quantity,
      unit,
      store_section,
      note,
      source_recipe_id
    } = itemData;

    // Check if item already exists
    const [existing] = await this.db.execute(
      `SELECT id, quantity FROM shopping_list_items 
       WHERE list_id = ? AND ingredient_id = ?`,
      [listId, ingredient_id]
    );

    if ((existing as any[]).length > 0) {
      // Update existing item
      const existingItem = (existing as any[])[0];
      await this.db.execute(
        `UPDATE shopping_list_items 
         SET quantity = quantity + ?, note = ?
         WHERE id = ?`,
        [quantity, note ?? null, existingItem.id]
      );
      return {
        success: true,
        data: { id: existingItem.id },
      };
    }

    // Generate UUID and insert new item
    const [uuidResult] = await this.db.execute('SELECT UUID() as id');
    const itemId = (uuidResult as any[])[0].id;

    await this.db.execute(
      `INSERT INTO shopping_list_items 
       (id, list_id, ingredient_id, quantity, unit, store_section, note, source_recipe_id)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
      [
        itemId, 
        listId, 
        ingredient_id, 
        quantity, 
        unit ?? null, 
        store_section ?? null, 
        note ?? null, 
        source_recipe_id ?? null
      ]
    );

    return {
      success: true,
      data: { id: itemId },
    };
  }

  async updateItemStatus(listId: string, itemId: string, isChecked: boolean) {
    const [result] = await this.db.execute(
      'UPDATE shopping_list_items SET is_checked = ? WHERE id = ? AND list_id = ?',
      [isChecked, itemId, listId]
    );

    if ((result as any).affectedRows === 0) {
      throw new NotFoundException('Shopping list item not found');
    }

    return {
      success: true,
      message: 'Item status updated successfully',
    };
  }

  async removeItemFromList(listId: string, itemId: string) {
    const [result] = await this.db.execute(
      'DELETE FROM shopping_list_items WHERE id = ? AND list_id = ?',
      [itemId, listId]
    );

    if ((result as any).affectedRows === 0) {
      throw new NotFoundException('Shopping list item not found');
    }

    return {
      success: true,
      message: 'Item removed from list',
    };
  }

  async generateFromMealPlan(userId: string, mealPlanId: string, includePantry: boolean = true) {
    // Get meal plan items
    const [mealItems] = await this.db.execute(
      `SELECT 
        mpi.recipe_id,
        mpi.servings,
        mpi.variant_region,
        r.name_vi as recipe_name
      FROM meal_plan_items mpi
      JOIN recipes r ON mpi.recipe_id = r.id
      WHERE mpi.meal_plan_id = ?`,
      [mealPlanId]
    );

    if ((mealItems as any[]).length === 0) {
      throw new NotFoundException('Meal plan not found or empty');
    }

    // Get ingredients from all recipes
    const ingredientMap = new Map();
    
    for (const mealItem of mealItems as any[]) {
      const [ingredients] = await this.db.execute(
        `SELECT 
          ri.ingredient_id,
          i.name as ingredient_name,
          ri.quantity * ? as total_quantity,
          ri.unit,
          i.default_unit,
          ss.code as store_section
        FROM recipe_ingredients ri
        JOIN ingredients i ON ri.ingredient_id = i.id
        LEFT JOIN ingredient_categories ic ON i.category_id = ic.id
        LEFT JOIN store_sections ss ON (
          CASE ic.name
            WHEN 'THỊT' THEN 'MEAT'
            WHEN 'CÁ' THEN 'SEAFOOD'
            WHEN 'RAU CỦ' THEN 'PRODUCE'
            WHEN 'TRÁI CÂY' THEN 'PRODUCE'
            WHEN 'NGŨ CỐC' THEN 'DRY_GOODS'
            WHEN 'SỮA' THEN 'DAIRY'
            WHEN 'GIA VỊ' THEN 'SPICE'
            WHEN 'NƯỚC CHẤM' THEN 'SAUCE'
            ELSE 'OTHER'
          END
        ) = ss.code
        WHERE ri.recipe_id = ?`,
        [mealItem.servings, mealItem.recipe_id]
      );

      for (const ingredient of ingredients as any[]) {
        const key = ingredient.ingredient_id;
        if (ingredientMap.has(key)) {
          const existing = ingredientMap.get(key);
          existing.total_quantity += ingredient.total_quantity;
          existing.recipes.push(mealItem.recipe_name);
        } else {
          ingredientMap.set(key, {
            ...ingredient,
            recipes: [mealItem.recipe_name]
          });
        }
      }
    }

    // Create shopping list
    const [uuidResult] = await this.db.execute('SELECT UUID() as id');
    const listId = (uuidResult as any[])[0].id;

    await this.db.execute(
      `INSERT INTO shopping_lists (id, owner_id, title, week_range, is_shared)
       VALUES (?, ?, ?, ?, 0)`,
      [listId, userId, `Danh sách mua sắm từ kế hoạch`, new Date().toISOString().split('T')[0]]
    );

    // Add items to shopping list
    for (const [ingredientId, ingredient] of ingredientMap) {
      const [itemUuidResult] = await this.db.execute('SELECT UUID() as id');
      const itemId = (itemUuidResult as any[])[0].id;

      await this.db.execute(
        `INSERT INTO shopping_list_items 
         (id, list_id, ingredient_id, quantity, unit, store_section, note)
         VALUES (?, ?, ?, ?, ?, ?, ?)`,
        [
          itemId,
          listId,
          ingredientId,
          ingredient.total_quantity,
          ingredient.unit || ingredient.default_unit,
          ingredient.store_section,
          `Cho: ${ingredient.recipes.join(', ')}`
        ]
      );
    }

    return {
      success: true,
      data: {
        list_id: listId,
        total_items: ingredientMap.size,
        message: 'Shopping list generated successfully'
      },
    };
  }

  async shareList(listId: string, userId: string, shareData: any) {
    const { invited_email, role = 'VIEWER' } = shareData;

    // Generate UUID and invitation token
    const [uuidResult] = await this.db.execute('SELECT UUID() as id');
    const invitationId = (uuidResult as any[])[0].id;
    const token = Math.random().toString(36).substring(2, 15) + Math.random().toString(36).substring(2, 15);

    await this.db.execute(
      `INSERT INTO share_invitations (id, list_id, invited_email, role, token)
       VALUES (?, ?, ?, ?, ?)`,
      [invitationId, listId, invited_email, role, token]
    );

    return {
      success: true,
      data: {
        invitation_id: invitationId,
        token: token,
        message: 'Invitation sent successfully'
      },
    };
  }

  async acceptInvitation(token: string, userId: string) {
    const [invitations] = await this.db.execute(
      'SELECT * FROM share_invitations WHERE token = ? AND accepted_at IS NULL',
      [token]
    );

    const invitation = (invitations as any[])[0];
    if (!invitation) {
      throw new NotFoundException('Invalid or expired invitation');
    }

    // Add user to shared list
    await this.db.execute(
      `INSERT INTO shopping_shares (list_id, user_id, role)
       VALUES (?, ?, ?)
       ON DUPLICATE KEY UPDATE role = VALUES(role)`,
      [invitation.list_id, userId, invitation.role]
    );

    // Mark invitation as accepted
    await this.db.execute(
      'UPDATE share_invitations SET accepted_at = NOW() WHERE token = ?',
      [token]
    );

    return {
      success: true,
      message: 'Invitation accepted successfully',
    };
  }

  async getStoreSections() {
    const [sections] = await this.db.execute(
      'SELECT code, name FROM store_sections ORDER BY name'
    );

    return {
      success: true,
      data: sections,
    };
  }
}
