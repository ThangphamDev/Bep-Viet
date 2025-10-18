import { Request, Response } from 'express';
import { pool } from '../config/db';
import { AppError } from '../middlewares/error';

class RegionsService {
  static async getRegions(_req: Request, res: Response): Promise<void> {
    const [regions] = await pool.execute(
      'SELECT code, name FROM geo_regions ORDER BY code'
    );

    res.json({
      success: true,
      data: {
        regions: regions as any[],
      },
    });
  }

  static async getSubregions(req: Request, res: Response): Promise<void> {
    const { id } = req.params;

    if (!id || !['BAC', 'TRUNG', 'NAM'].includes(id)) {
      throw new AppError('Invalid region code', 400, 'INVALID_REGION');
    }

    const [subregions] = await pool.execute(
      'SELECT id, name FROM geo_subregions WHERE region_code = ? ORDER BY name',
      [id]
    );

    res.json({
      success: true,
      data: {
        subregions: subregions as any[],
      },
    });
  }
}

export default RegionsService;
