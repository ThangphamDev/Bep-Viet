import { Injectable } from '@nestjs/common';
import { Inject } from '@nestjs/common';
import { GeminiService } from '../gemini/gemini.service';

@Injectable()
export class AnalyticsService {
  constructor(
    @Inject('DATABASE_CONNECTION') private db: any,
    private geminiService: GeminiService,
  ) {}

  async getUserAnalytics(userId: string) {
    if (!userId) {
      throw new Error('User ID is required');
    }

    const [stats] = await this.db.execute(
      `SELECT 
        COUNT(DISTINCT mp.id) as meal_plans_count,
        COUNT(DISTINCT pi.id) as pantry_items_count,
        COUNT(DISTINCT sl.id) as shopping_lists_count,
        COUNT(DISTINCT cr.id) as community_recipes_count,
        COUNT(DISTINCT rr.id) as ratings_given_count,
        COUNT(DISTINCT fp.id) as family_profiles_count,
        COUNT(DISTINCT fm.id) as family_members_count
      FROM users u
      LEFT JOIN meal_plans mp ON u.id = mp.user_id
      LEFT JOIN pantry_items pi ON u.id = pi.user_id
      LEFT JOIN shopping_lists sl ON u.id = sl.owner_id
      LEFT JOIN community_recipes cr ON u.id = cr.author_user_id
      LEFT JOIN recipe_ratings rr ON u.id = rr.user_id
      LEFT JOIN family_profiles fp ON u.id = fp.user_id
      LEFT JOIN family_members fm ON fp.id = fm.family_id
      WHERE u.id = ?`,
      [userId]
    );

    return {
      success: true,
      data: (stats as any[])[0],
    };
  }

  async getWeeklyReport(userId: string, weekStart?: string) {
    if (!userId) {
      throw new Error('User ID is required');
    }

    // Calculate week start and end dates
    let startDate: Date;
    let endDate: Date;

    if (weekStart) {
      startDate = new Date(weekStart);
      endDate = new Date(startDate);
      endDate.setDate(endDate.getDate() + 7);
    } else {
      // Current week (Monday to Sunday)
      const today = new Date();
      const dayOfWeek = today.getDay();
      const diff = dayOfWeek === 0 ? -6 : 1 - dayOfWeek; // Adjust to Monday
      startDate = new Date(today);
      startDate.setDate(today.getDate() + diff);
      startDate.setHours(0, 0, 0, 0);
      endDate = new Date(startDate);
      endDate.setDate(startDate.getDate() + 7);
    }

    // 1. Get meal plans with recipes and ingredients
    const [mealPlans] = await this.db.execute(
      `SELECT 
        mp.id as plan_id,
        mpi.id as item_id,
        mpi.date as meal_date,
        mpi.meal_slot as meal_type,
        r.id as recipe_id,
        r.name_vi as recipe_name,
        r.nutrition_json
      FROM meal_plans mp
      JOIN meal_plan_items mpi ON mp.id = mpi.meal_plan_id
      LEFT JOIN recipes r ON mpi.recipe_id = r.id
      WHERE mp.user_id = ? 
        AND mp.week_start_date >= ? 
        AND mp.week_start_date < ?
      ORDER BY mpi.date, mpi.meal_slot`,
      [userId, startDate, endDate]
    );

    const meals = (mealPlans as any[]).map(meal => {
      const nutrition = meal.nutrition_json || {};
      return {
        ...meal,
        calories: nutrition.calories || 0,
        protein: nutrition.protein || 0,
        carbs: nutrition.carbs || 0,
        sodium: nutrition.sodium || 0,
      };
    });
    const totalMeals = meals.length;

    // 2. Get recipe ingredients for conflict detection
    const recipeIds = [...new Set(meals.map(m => m.recipe_id).filter(Boolean))];
    let recipeIngredients: any[] = [];

    if (recipeIds.length > 0) {
      const placeholders = recipeIds.map(() => '?').join(',');
      const [ingredients] = await this.db.execute(
        `SELECT 
          ri.recipe_id,
          i.id as ingredient_id,
          i.name as ingredient_name,
          ic.name as category_name
        FROM recipe_ingredients ri
        JOIN ingredients i ON ri.ingredient_id = i.id
        LEFT JOIN ingredient_categories ic ON i.category_id = ic.id
        WHERE ri.recipe_id IN (${placeholders})`,
        recipeIds
      );
      recipeIngredients = ingredients as any[];
    }

    // 3. Get family members with allergies and diet restrictions
    const [familyMembers] = await this.db.execute(
      `SELECT 
        fm.id,
        fm.name,
        fm.age_group,
        fm.spice_tolerance,
        fm.allergies_json,
        fm.diet_json,
        fm.note
      FROM family_profiles fp
      JOIN family_members fm ON fp.id = fm.family_id
      WHERE fp.user_id = ?`,
      [userId]
    );

    const members = familyMembers as any[];

    // 4. Analyze conflicts between meals and family restrictions
    const conflicts: any[] = [];
    for (const meal of meals) {
      if (!meal.recipe_id) continue;

      const mealIngredients = recipeIngredients.filter(
        ri => ri.recipe_id === meal.recipe_id
      );

      for (const member of members) {
        // Check allergies
        if (member.allergies_json && member.allergies_json.items) {
          const allergies = member.allergies_json.items || [];
          for (const allergy of allergies) {
            const conflict = mealIngredients.find(ing =>
              ing.ingredient_name.toLowerCase().includes(allergy.toLowerCase()) ||
              ing.category_name?.toLowerCase().includes(allergy.toLowerCase())
            );
            if (conflict) {
              conflicts.push({
                member_name: member.name,
                recipe_name: meal.recipe_name,
                ingredient: conflict.ingredient_name,
                type: 'allergy',
                severity: 'high',
                description: `${member.name} dị ứng ${allergy}, món ${meal.recipe_name} chứa ${conflict.ingredient_name}`,
              });
            }
          }
        }

        // Check diet restrictions
        if (member.diet_json && member.diet_json.items) {
          const restrictions = member.diet_json.items || [];
          for (const restriction of restrictions) {
            const conflict = mealIngredients.find(ing =>
              ing.ingredient_name.toLowerCase().includes(restriction.toLowerCase()) ||
              ing.category_name?.toLowerCase().includes(restriction.toLowerCase())
            );
            if (conflict) {
              conflicts.push({
                member_name: member.name,
                recipe_name: meal.recipe_name,
                ingredient: conflict.ingredient_name,
                type: 'diet',
                severity: 'medium',
                description: `${member.name} hạn chế ${restriction}, món ${meal.recipe_name} chứa ${conflict.ingredient_name}`,
              });
            }
          }
        }
      }
    }

    // 5. Calculate nutrition averages
    const nutritionSums = meals.reduce((acc, meal) => ({
      calories: acc.calories + (meal.calories || 0),
      protein: acc.protein + (meal.protein || 0),
      carbs: acc.carbs + (meal.carbs || 0),
      sodium: acc.sodium + (meal.sodium || 0),
    }), { calories: 0, protein: 0, carbs: 0, sodium: 0 });

    const avgNutrition = {
      calories: totalMeals > 0 ? Math.round(nutritionSums.calories / totalMeals) : 1800,
      protein: totalMeals > 0 ? Math.round(nutritionSums.protein / totalMeals) : 80,
      carbs: totalMeals > 0 ? Math.round(nutritionSums.carbs / totalMeals) : 200,
      sodium: totalMeals > 0 ? Math.round(nutritionSums.sodium / totalMeals) : 2000,
    };

    // 6. Use Gemini AI to generate intelligent recommendations
    let recommendations: any[] = [];
    try {
      const analysisPrompt = `Bạn là chuyên gia dinh dưỡng. Hãy phân tích dữ liệu bữa ăn tuần này và đưa ra 3-4 khuyến nghị cụ thể.

Dữ liệu:
- Tổng số bữa ăn: ${totalMeals}
- Trung bình calories: ${avgNutrition.calories} kcal/bữa
- Trung bình protein: ${avgNutrition.protein}g/bữa
- Trung bình carbs: ${avgNutrition.carbs}g/bữa
- Trung bình sodium: ${avgNutrition.sodium}mg/bữa
- Số thành viên gia đình: ${members.length}
- Số cảnh báo dị ứng/hạn chế: ${conflicts.length}

${conflicts.length > 0 ? `Cảnh báo cụ thể:\n${conflicts.slice(0, 3).map(c => `- ${c.description}`).join('\n')}` : ''}

Trả về JSON với format:
{
  "recommendations": [
    {"icon": "eco|warning_amber|water_drop|local_fire_department", "title": "Tiêu đề ngắn gọn", "description": "Mô tả cụ thể dựa trên data"}
  ],
  "health_score": 7.5
}`;

      const response = await fetch(
        `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent?key=${process.env.GEMINI_API_KEY}`,
        {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            contents: [{ parts: [{ text: analysisPrompt }] }]
          }),
        }
      );

      if (response.ok) {
        const data = await response.json();
        const text = data.candidates?.[0]?.content?.parts?.[0]?.text || '';
        const jsonMatch = text.match(/\{[\s\S]*\}/);
        if (jsonMatch) {
          const aiResult = JSON.parse(jsonMatch[0]);
          recommendations = aiResult.recommendations || [];
        }
      }
    } catch (error) {
      console.warn('Gemini AI recommendations failed, using fallback');
    }

    // Fallback recommendations if AI fails
    if (recommendations.length === 0) {
      recommendations = [
        { icon: 'eco', title: 'Tăng rau xanh', description: 'Thêm rau củ vào bữa ăn' },
        { icon: 'water_drop', title: 'Giảm muối', description: `Sodium trung bình ${avgNutrition.sodium}mg, nên giảm xuống` },
        { icon: 'local_fire_department', title: 'Cân bằng calories', description: `Trung bình ${avgNutrition.calories} kcal/bữa` },
      ];
    }

    // 7. Calculate health score
    let healthScore = 8.0;
    if (conflicts.length > 0) healthScore -= conflicts.length * 0.3;
    if (avgNutrition.sodium > 2000) healthScore -= 0.5;
    if (avgNutrition.calories > 2500) healthScore -= 0.5;
    if (avgNutrition.protein < 50) healthScore -= 0.5;
    healthScore = Math.max(5, Math.min(10, healthScore));

    return {
      success: true,
      data: {
        week_start: startDate.toISOString().split('T')[0],
        week_end: endDate.toISOString().split('T')[0],
        total_meals: totalMeals,
        warning_count: conflicts.length,
        health_score: parseFloat(healthScore.toFixed(1)),
        nutrition: avgNutrition,
        warnings: conflicts.map(c => ({
          member_name: c.member_name,
          recipe_name: c.recipe_name,
          type: c.type,
          severity: c.severity,
          description: c.description,
        })),
        recommendations: recommendations,
      },
    };
  }

  async getSystemAnalytics() {
    // Use separate queries to avoid Cartesian product
    const [userCount] = await this.db.execute('SELECT COUNT(*) as count FROM users');
    const [recipeCount] = await this.db.execute('SELECT COUNT(*) as count FROM recipes');
    const [communityRecipeCount] = await this.db.execute('SELECT COUNT(*) as count FROM community_recipes');
    const [ratingCount] = await this.db.execute('SELECT COUNT(*) as count FROM recipe_ratings');
    const [mealPlanCount] = await this.db.execute('SELECT COUNT(*) as count FROM meal_plans');
    const [ingredientCount] = await this.db.execute('SELECT COUNT(*) as count FROM ingredients');
    const [pantryItemCount] = await this.db.execute('SELECT COUNT(*) as count FROM pantry_items');
    const [shoppingListCount] = await this.db.execute('SELECT COUNT(*) as count FROM shopping_lists');

    // Get top recipes
    const [topRecipes] = await this.db.execute(
      `SELECT r.id, r.name_vi as name, COALESCE(r.rating_avg, 0) as rating_avg, r.rating_count
       FROM recipes r
       WHERE r.rating_count > 0
       ORDER BY r.rating_avg DESC, r.rating_count DESC
       LIMIT 5`
    );

    // Get recent activity
    const [recentActivity] = await this.db.execute(
      `SELECT 
        'community_recipe' as type,
        cr.id,
        cr.title as name,
        cr.created_at,
        u.name as user_name
       FROM community_recipes cr
       JOIN users u ON cr.author_user_id = u.id
       ORDER BY cr.created_at DESC
       LIMIT 10`
    );

    return {
      success: true,
      data: {
        total_users: (userCount as any[])[0].count,
        total_recipes: (recipeCount as any[])[0].count,
        total_community_recipes: (communityRecipeCount as any[])[0].count,
        total_ratings: (ratingCount as any[])[0].count,
        total_meal_plans: (mealPlanCount as any[])[0].count,
        total_ingredients: (ingredientCount as any[])[0].count,
        total_pantry_items: (pantryItemCount as any[])[0].count,
        total_shopping_lists: (shoppingListCount as any[])[0].count,
        top_recipes: topRecipes,
        recent_activity: recentActivity
      },
    };
  }
}
