import { Injectable, Logger } from '@nestjs/common';
import { Inject } from '@nestjs/common';
import { AllergenConflict, CheckAllergensResponse } from './dto/check-allergens.dto';

@Injectable()
export class FamilyService {
  private readonly logger = new Logger(FamilyService.name);

  constructor(@Inject('DATABASE_CONNECTION') private db: any) {}

  async createFamilyProfile(userId: string, familyData: any) {
    const { name, note } = familyData;

    // Generate UUID
    const [uuidResult] = await this.db.execute('SELECT UUID() as id');
    const familyId = (uuidResult as any[])[0].id;

    await this.db.execute(
      `INSERT INTO family_profiles (id, user_id, name, note)
       VALUES (?, ?, ?, ?)`,
      [familyId, userId, name, note ?? null]
    );

    // Return the created profile with full data
    return {
      success: true,
      data: {
        id: familyId,
        name: name,
        note: note ?? null,
        members: [],
      },
    };
  }

  async getUserFamilyProfiles(userId: string) {
    if (!userId) {
      throw new Error('User ID is required');
    }

    const [profiles] = await this.db.execute(
      `SELECT 
        fp.id,
        fp.name,
        fp.note
      FROM family_profiles fp
      WHERE fp.user_id = ?
      ORDER BY fp.id DESC`,
      [userId]
    );

    // Get members for each profile
    for (const profile of profiles as any[]) {
      const [members] = await this.db.execute(
        `SELECT 
          id,
          name,
          age_group,
          spice_tolerance,
          diet_json,
          allergies_json,
          note
        FROM family_members
        WHERE family_id = ?`,
        [profile.id]
      );
      
      // Parse JSON fields - MySQL already parses JSON columns
      profile.members = (members as any[]).map((member) => ({
        ...member,
        diet_json: member.diet_json || null,
        allergies_json: member.allergies_json || null,
      }));
    }

    return {
      success: true,
      data: profiles,
    };
  }

  async addFamilyMember(familyId: string, memberData: any) {
    const { name, age_group, spice_tolerance, diet_json, allergies_json, note } = memberData;

    // Generate UUID
    const [uuidResult] = await this.db.execute('SELECT UUID() as id');
    const memberId = (uuidResult as any[])[0].id;

    await this.db.execute(
      `INSERT INTO family_members 
       (id, family_id, name, age_group, spice_tolerance, diet_json, allergies_json, note)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
      [
        memberId,
        familyId, 
        name, 
        age_group ?? null, 
        spice_tolerance ?? 1,
        diet_json ? JSON.stringify(diet_json) : null,
        allergies_json ? JSON.stringify(allergies_json) : null,
        note ?? null
      ]
    );

    // Return the created member with full data
    return {
      success: true,
      data: {
        id: memberId,
        name: name,
        age_group: age_group ?? null,
        spice_tolerance: spice_tolerance ?? 1,
        diet_json: diet_json ?? null,
        allergies_json: allergies_json ?? null,
        note: note ?? null,
      },
    };
  }

  async updateFamilyMember(memberId: string, memberData: any) {
    const { name, age_group, spice_tolerance, diet_json, allergies_json, note } = memberData;

    await this.db.execute(
      `UPDATE family_members 
       SET name = ?, age_group = ?, spice_tolerance = ?, diet_json = ?, allergies_json = ?, note = ?
       WHERE id = ?`,
      [
        name,
        age_group ?? null,
        spice_tolerance ?? 1,
        diet_json ? JSON.stringify(diet_json) : null,
        allergies_json ? JSON.stringify(allergies_json) : null,
        note ?? null,
        memberId
      ]
    );

    // Return the updated member data
    return {
      success: true,
      data: {
        id: memberId,
        name: name,
        age_group: age_group ?? null,
        spice_tolerance: spice_tolerance ?? 1,
        diet_json: diet_json ?? null,
        allergies_json: allergies_json ?? null,
        note: note ?? null,
      },
    };
  }

  async deleteFamilyMember(memberId: string) {
    await this.db.execute(
      `DELETE FROM family_members WHERE id = ?`,
      [memberId]
    );

    return {
      success: true,
      message: 'Family member deleted successfully',
    };
  }

  /**
   * Check if recipe ingredients conflict with family members' allergens
   * Premium Family feature
   */
  async checkRecipeAllergens(userId: string, recipeId: string): Promise<CheckAllergensResponse> {
    try {
      // 1. Check if user has active Premium subscription
      const [subscriptions] = await this.db.execute(
        `SELECT s.plan 
         FROM subscriptions s
         WHERE s.user_id = ? 
           AND s.status = 'ACTIVE'
           AND (s.ended_at IS NULL OR s.ended_at > NOW())
         ORDER BY s.started_at DESC
         LIMIT 1`,
        [userId]
      );

      // Check if user has Premium or Family plan (both can use allergen checking)
      const userPlan = (subscriptions as any[])[0]?.plan;
      if ((subscriptions as any[]).length === 0 || (userPlan !== 'PREMIUM' && userPlan !== 'FAMILY')) {
        return {
          success: true,
          hasConflicts: false,
          conflicts: [],
          message: 'Premium or Family subscription required for allergen checking',
        };
      }

      // 2. Get family members with allergens
      const [profiles] = await this.db.execute(
        `SELECT fp.id FROM family_profiles fp WHERE fp.user_id = ? LIMIT 1`,
        [userId]
      );

      if ((profiles as any[]).length === 0) {
        return {
          success: true,
          hasConflicts: false,
          conflicts: [],
          message: 'No family profile found',
        };
      }

      const familyId = (profiles as any[])[0].id;

      const [members] = await this.db.execute(
        `SELECT id, name, age_group, allergies_json
         FROM family_members
         WHERE family_id = ? AND allergies_json IS NOT NULL`,
        [familyId]
      );

      if ((members as any[]).length === 0) {
        return {
          success: true,
          hasConflicts: false,
          conflicts: [],
          message: 'No family members with allergens',
        };
      }

      // 3. Get recipe ingredients WITH category info
      const [ingredients] = await this.db.execute(
        `SELECT 
          ri.ingredient_id,
          i.name as ingredient_name,
          i.category_id,
          ic.name as category_name
         FROM recipe_ingredients ri
         JOIN ingredients i ON i.id = ri.ingredient_id
         LEFT JOIN ingredient_categories ic ON i.category_id = ic.id
         WHERE ri.recipe_id = ?`,
        [recipeId]
      );

      if ((ingredients as any[]).length === 0) {
        return {
          success: true,
          hasConflicts: false,
          conflicts: [],
          message: 'Recipe has no ingredients',
        };
      }

      // 4. Check conflicts
      const conflicts: AllergenConflict[] = [];

      for (const member of members as any[]) {
        const allergiesJson = member.allergies_json;
        
        // allergies_json structure: {"items": ["Hải sản", "Sữa", "Trứng", ...]}
        // Parse the allergen items (can be category names or ingredient names)
        const allergenItems: string[] = allergiesJson?.items || [];

        if (allergenItems.length === 0) continue;

        // Find conflicts by matching allergen names with ingredient names or categories
        const conflictingIngredients: any[] = [];
        
        for (const ing of ingredients as any[]) {
          for (const allergen of allergenItems) {
            const allergenLower = allergen.toLowerCase().trim();
            const ingredientNameLower = ing.ingredient_name.toLowerCase().trim();
            const categoryNameLower = ing.category_name?.toLowerCase().trim() || '';

            // Match if allergen matches category or ingredient name
            if (
              allergenLower === categoryNameLower ||
              allergenLower === ingredientNameLower ||
              ingredientNameLower.includes(allergenLower) ||
              allergenLower.includes(ingredientNameLower)
            ) {
              // Check if already added
              if (!conflictingIngredients.find(ci => ci.ingredientId === ing.ingredient_id)) {
                conflictingIngredients.push({
                  ingredientId: ing.ingredient_id,
                  ingredientName: ing.ingredient_name,
                });
              }
              break;
            }
          }
        }

        if (conflictingIngredients.length > 0) {
          conflicts.push({
            memberId: member.id,
            memberName: member.name,
            memberAgeGroup: member.age_group || 'ADULT',
            conflictingIngredients: conflictingIngredients,
          });
        }
      }

      return {
        success: true,
        hasConflicts: conflicts.length > 0,
        conflicts: conflicts,
      };
    } catch (error) {
      this.logger.error(`Error checking recipe allergens: ${error.message}`);
      return {
        success: false,
        hasConflicts: false,
        conflicts: [],
        message: error.message,
      };
    }
  }
}
