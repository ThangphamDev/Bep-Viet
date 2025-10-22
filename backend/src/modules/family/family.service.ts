import { Injectable } from '@nestjs/common';
import { Inject } from '@nestjs/common';

@Injectable()
export class FamilyService {
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
}
