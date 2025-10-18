import { Request, Response } from 'express';
import { pool } from '../config/db';

class SeasonsService {
  static async getSeasons(req: Request, res: Response): Promise<void> {
    const [seasons] = await pool.execute(
      'SELECT code, name, months_set FROM seasons ORDER BY code'
    );

    res.json({
      success: true,
      data: {
        seasons: seasons as any[],
      },
    });
  }
}

export default SeasonsService;
