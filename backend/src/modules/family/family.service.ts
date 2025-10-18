import { Injectable } from '@nestjs/common';
import { Inject } from '@nestjs/common';

@Injectable()
export class FamilyService {
  constructor(@Inject('DATABASE_CONNECTION') private db: any) {}

  async createFamilyProfile(userId: string, familyData: any) {
    const { name, description, member_count } = familyData;

    const [result] = await this.db.execute(
      `INSERT INTO family_profiles (owner_user_id, name, description, member_count)
       VALUES (?, ?, ?, ?)`,
      [userId, name, description, member_count]
    );

    return {
      success: true,
      data: { id: (result as any).insertId },
    };
  }

  async getUserFamilyProfiles(userId: string) {
    const [profiles] = await this.db.execute(
      `SELECT 
        fp.id,
        fp.name,
        fp.description,
        fp.member_count,
        fp.created_at,
        fp.updated_at
      FROM family_profiles fp
      WHERE fp.owner_user_id = ?
      ORDER BY fp.created_at DESC`,
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
