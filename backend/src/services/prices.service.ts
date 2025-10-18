import { Request, Response } from 'express';
import { pool } from '../config/db';

class PricesService {
  static async getPrices(req: Request, res: Response): Promise<void> {
    const { ingredient_id, region, on } = req.query;
    
    let whereClause = '';
    let queryParams: any[] = [];

    if (ingredient_id) {
      whereClause += ' WHERE ip.ingredient_id = ?';
      queryParams.push(ingredient_id);
    }

    if (region) {
      whereClause += whereClause ? ' AND ip.region = ?' : ' WHERE ip.region = ?';
      queryParams.push(region);
    }

    const [prices] = await pool.execute(
      `SELECT ip.id, ip.ingredient_id, ip.region, ip.unit, ip.price_per_unit, ip.currency, ip.last_updated,
              i.name as ingredient_name
       FROM ingredient_prices ip
       JOIN ingredients i ON ip.ingredient_id = i.id
       ${whereClause}
       ORDER BY i.name, ip.region`,
      queryParams
    );

    res.json({
      success: true,
      data: {
        prices: prices as any[],
      },
    });
  }

  static async createPrice(req: Request, res: Response): Promise<void> {
    res.json({ success: true, message: 'Create price - TODO' });
  }

  static async updatePrice(req: Request, res: Response): Promise<void> {
    res.json({ success: true, message: 'Update price - TODO' });
  }

  static async deletePrice(req: Request, res: Response): Promise<void> {
    res.json({ success: true, message: 'Delete price - TODO' });
  }
}

export default PricesService;
