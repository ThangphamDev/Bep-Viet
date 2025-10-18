import { Injectable } from '@nestjs/common';
import { Inject } from '@nestjs/common';

@Injectable()
export class AdvisoryService {
  constructor(@Inject('DATABASE_CONNECTION') private db: any) {}

  async createAdvisory(userId: string, advisoryData: any) {
    const { title, content, category, priority } = advisoryData;

    const [result] = await this.db.execute(
      `INSERT INTO advisories (user_id, title, content, category, priority, status)
       VALUES (?, ?, ?, ?, ?, 'PENDING')`,
      [userId, title, content, category, priority]
    );

    return {
      success: true,
      data: { id: (result as any).insertId },
    };
  }

  async getUserAdvisories(userId: string) {
    const [advisories] = await this.db.execute(
      `SELECT 
        a.id,
        a.title,
        a.content,
        a.category,
        a.priority,
        a.status,
        a.created_at,
        a.updated_at
      FROM advisories a
      WHERE a.user_id = ?
      ORDER BY a.created_at DESC`,
      [userId]
    );

    return {
      success: true,
      data: advisories,
    };
  }
}
