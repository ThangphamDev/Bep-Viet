import { Injectable, NotFoundException } from '@nestjs/common';
import { Inject } from '@nestjs/common';

@Injectable()
export class MealPlansService {
  constructor(@Inject('DATABASE_CONNECTION') private db: any) {}

  async createMealPlan(userId: string, mealPlanData: any) {
    const { week_start_date, note } = mealPlanData;

    const [result] = await this.db.execute(
      `INSERT INTO meal_plans (user_id, week_start_date, note)
       VALUES (?, ?, ?)
       ON DUPLICATE KEY UPDATE note = VALUES(note)`,
      [userId, week_start_date, note]
    );

    return {
      success: true,
      data: { id: (result as any).insertId },
    };
  }

  async getMealPlan(userId: string, weekStartDate: string) {
    const [mealPlans] = await this.db.execute(
      `SELECT 
        mp.id,
        mp.user_id,
        mp.week_start_date,
        mp.note,
        mp.created_at,
        mp.updated_at
      FROM meal_plans mp
      WHERE mp.user_id = ? AND mp.week_start_date = ?`,
      [userId, weekStartDate]
    );

    const mealPlan = (mealPlans as any[])[0];
    if (!mealPlan) {
      throw new NotFoundException('Meal plan not found');
    }

    // Get meal plan items
    const [items] = await this.db.execute(
      `SELECT 
        mpi.id,
        mpi.date,
        mpi.meal_slot,
        mpi.recipe_id,
        mpi.variant_region,
        mpi.servings,
        r.name_vi,
        r.name_en,
        r.image_url,
        r.cook_time_min,
        r.difficulty
      FROM meal_plan_items mpi
      JOIN recipes r ON mpi.recipe_id = r.id
      WHERE mpi.meal_plan_id = ?
      ORDER BY mpi.date, mpi.meal_slot`,
      [mealPlan.id]
    );

    return {
      success: true,
      data: {
        ...mealPlan,
        items: items
      },
    };
  }

  async addMealToPlan(mealPlanId: string, mealData: any) {
    const { date, meal_slot, recipe_id, variant_region, servings } = mealData;

    const [result] = await this.db.execute(
      `INSERT INTO meal_plan_items 
       (meal_plan_id, date, meal_slot, recipe_id, variant_region, servings)
       VALUES (?, ?, ?, ?, ?, ?)
       ON DUPLICATE KEY UPDATE 
       recipe_id = VALUES(recipe_id),
       variant_region = VALUES(variant_region),
       servings = VALUES(servings)`,
      [mealPlanId, date, meal_slot, recipe_id, variant_region, servings]
    );

    return {
      success: true,
      data: { id: (result as any).insertId },
    };
  }

  async removeMealFromPlan(mealPlanId: string, date: string, mealSlot: string) {
    const [result] = await this.db.execute(
      'DELETE FROM meal_plan_items WHERE meal_plan_id = ? AND date = ? AND meal_slot = ?',
      [mealPlanId, date, mealSlot]
    );

    return {
      success: true,
      message: 'Meal removed from plan',
    };
  }

  async generateMealPlan(userId: string, params: any) {
    const {
      week_start,
      region,
      budget_per_meal,
      servings,
      constraints = {}
    } = params;

    // Get user preferences
    const [preferences] = await this.db.execute(
      'SELECT spicy_level, taste_spicy, taste_salty, taste_sweet, taste_light FROM user_preferences WHERE user_id = ?',
      [userId]
    );

    const userPrefs = (preferences as any[])[0] || { spicy_level: 2, taste_spicy: 2, taste_salty: 2, taste_sweet: 2, taste_light: 2 };

    // Get current season
    const currentMonth = new Date().getMonth() + 1;
    const [seasons] = await this.db.execute(
      'SELECT code FROM seasons WHERE FIND_IN_SET(?, months_set) > 0',
      [currentMonth]
    );
    const currentSeason = (seasons as any[])[0]?.code || 'HA';

    // Generate meal plan for 7 days
    const mealSlots = ['BREAKFAST', 'LUNCH', 'DINNER'];
    const days: any[] = [];
    
    for (let i = 0; i < 7; i++) {
      const date = new Date(week_start);
      date.setDate(date.getDate() + i);
      const dateStr = date.toISOString().split('T')[0];
      
      const dayMeals = {};
      
      for (const mealSlot of mealSlots) {
        // Get suggestions for this meal
        const suggestions = await this.getMealSuggestions({
          region,
          season: currentSeason,
          servings,
          budget: budget_per_meal,
          meal_type: mealSlot,
          spice_pref: userPrefs.spicy_level,
          max_time: constraints.max_time || 60
        });

        if (suggestions.length > 0) {
          // Pick a random suggestion (in real app, you'd use more sophisticated logic)
          const selectedRecipe = suggestions[Math.floor(Math.random() * Math.min(3, suggestions.length))];
          
          dayMeals[mealSlot] = {
            recipe_id: selectedRecipe.recipe_id,
            variant_region: region,
            servings: servings,
            estimated_cost: selectedRecipe.total_cost,
            recipe_name: selectedRecipe.name_vi
          };
        }
      }
      
      days.push({
        date: dateStr,
        meals: dayMeals
      });
    }

    return {
      success: true,
      data: {
        week_start,
        region,
        servings,
        budget_per_meal,
        days: days
      },
    };
  }

  private async getMealSuggestions(params: any) {
    // This is a simplified version - in real app, you'd use the SuggestionsService
    const { region, season, servings, budget, meal_type, spice_pref, max_time } = params;

    const [recipes] = await this.db.execute(
      `SELECT 
        r.id as recipe_id,
        r.name_vi,
        r.name_en,
        r.meal_type,
        r.difficulty,
        r.cook_time_min,
        r.spice_level,
        r.rating_avg,
        r.image_url
      FROM recipes r
      WHERE r.is_public = 1 
        AND r.meal_type = ?
        AND r.spice_level <= ?
        AND r.cook_time_min <= ?
      ORDER BY r.rating_avg DESC
      LIMIT 10`,
      [meal_type, spice_pref, max_time]
    );

    // Calculate costs for each recipe
    const suggestions: any[] = [];
    for (const recipe of recipes as any[]) {
      const [ingredients] = await this.db.execute(
        `SELECT 
          ri.quantity,
          ri.unit,
          ip.price_per_unit
        FROM recipe_ingredients ri
        LEFT JOIN ingredient_prices ip ON ri.ingredient_id = ip.ingredient_id AND ip.region = ?
        WHERE ri.recipe_id = ?`,
        [region, recipe.recipe_id]
      );

      let totalCost = 0;
      for (const ingredient of ingredients as any[]) {
        if (ingredient.price_per_unit) {
          totalCost += ingredient.quantity * ingredient.price_per_unit * servings;
        }
      }

      if (totalCost <= budget || !budget) {
        suggestions.push({
          ...recipe,
          total_cost: totalCost
        });
      }
    }

    return suggestions;
  }

  async getUserMealPlans(userId: string) {
    if (!userId) {
      throw new NotFoundException('User ID is required');
    }

    const [mealPlans] = await this.db.execute(
      `SELECT 
        mp.id,
        mp.week_start_date,
        mp.note,
        mp.created_at,
        mp.updated_at,
        COUNT(mpi.id) as meal_count
      FROM meal_plans mp
      LEFT JOIN meal_plan_items mpi ON mp.id = mpi.meal_plan_id
      WHERE mp.user_id = ?
      GROUP BY mp.id
      ORDER BY mp.week_start_date DESC`,
      [userId]
    );

    return {
      success: true,
      data: mealPlans,
    };
  }

  async updateMealPlan(mealPlanId: string, updateData: any) {
    const { note } = updateData;

    const [result] = await this.db.execute(
      'UPDATE meal_plans SET note = ? WHERE id = ?',
      [note, mealPlanId]
    );

    if ((result as any).affectedRows === 0) {
      throw new NotFoundException('Meal plan not found');
    }

    return {
      success: true,
      message: 'Meal plan updated successfully',
    };
  }

  async deleteMealPlan(mealPlanId: string) {
    const [result] = await this.db.execute(
      'DELETE FROM meal_plans WHERE id = ?',
      [mealPlanId]
    );

    if ((result as any).affectedRows === 0) {
      throw new NotFoundException('Meal plan not found');
    }

    return {
      success: true,
      message: 'Meal plan deleted successfully',
    };
  }

  async quickAddToToday(userId: string, mealData: any) {
    const { recipe_id, meal_slot, servings, variant_region } = mealData;
    
    // Get today's date
    const today = new Date();
    const todayStr = today.toISOString().split('T')[0]; // YYYY-MM-DD
    
    // Calculate week start date (Monday)
    const dayOfWeek = today.getDay();
    const diff = dayOfWeek === 0 ? -6 : 1 - dayOfWeek; // If Sunday, go back 6 days, else go to Monday
    const weekStart = new Date(today);
    weekStart.setDate(today.getDate() + diff);
    const weekStartStr = weekStart.toISOString().split('T')[0];
    
    // Find or create meal plan for this week
    let [mealPlans] = await this.db.execute(
      `SELECT id FROM meal_plans WHERE user_id = ? AND week_start_date = ?`,
      [userId, weekStartStr]
    );
    
    let mealPlanId;
    if ((mealPlans as any[]).length === 0) {
      // Create new meal plan for this week
      const [result] = await this.db.execute(
        `INSERT INTO meal_plans (user_id, week_start_date, note) VALUES (?, ?, ?)`,
        [userId, weekStartStr, 'Kế hoạch bữa ăn']
      );
      mealPlanId = (result as any).insertId;
    } else {
      mealPlanId = (mealPlans as any[])[0].id;
    }
    
    // Add meal to today
    await this.db.execute(
      `INSERT INTO meal_plan_items 
       (meal_plan_id, date, meal_slot, recipe_id, variant_region, servings)
       VALUES (?, ?, ?, ?, ?, ?)
       ON DUPLICATE KEY UPDATE 
       recipe_id = VALUES(recipe_id),
       variant_region = VALUES(variant_region),
       servings = VALUES(servings)`,
      [mealPlanId, todayStr, meal_slot, recipe_id, variant_region, servings]
    );
    
    return {
      success: true,
      message: 'Đã thêm món ăn vào hôm nay',
      data: {
        meal_plan_id: mealPlanId,
        date: todayStr,
        meal_slot,
      },
    };
  }
}