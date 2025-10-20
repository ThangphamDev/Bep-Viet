import { Injectable } from '@nestjs/common';
import { Inject } from '@nestjs/common';

@Injectable()
export class FamilyService {
  constructor(@Inject('DATABASE_CONNECTION') private db: any) {}

  async createFamilyProfile(userId: string, familyData: any) {
    const { name, note } = familyData;

    const [result] = await this.db.execute(
      `INSERT INTO family_profiles (user_id, name, note)
       VALUES (?, ?, ?)`,
      [userId, name, note]
    );

    return {
      success: true,
      data: { id: (result as any).insertId },
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

    return {
      success: true,
      data: profiles,
    };
  }

  async addFamilyMember(familyId: string, memberData: any) {
    const { name, age, dietary_restrictions, allergies } = memberData;

    const [result] = await this.db.execute(
      `INSERT INTO family_members 
       (family_id, name, age, dietary_restrictions, allergies)
       VALUES (?, ?, ?, ?, ?)`,
      [familyId, name, age, dietary_restrictions, allergies]
    );

    return {
      success: true,
      data: { id: (result as any).insertId },
    };
  }
}
