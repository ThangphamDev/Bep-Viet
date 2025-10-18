import { Injectable } from '@nestjs/common';
import { Inject } from '@nestjs/common';

@Injectable()
export class SeasonsService {
  constructor(@Inject('DATABASE_CONNECTION') private db: any) {}

  async getAllSeasons() {
    const [seasons] = await this.db.execute(
      'SELECT code, name, months_set FROM seasons ORDER BY code'
    );

    return {
      success: true,
      data: seasons,
    };
  }

  async getCurrentSeason() {
    const currentMonth = new Date().getMonth() + 1; // 1-12
    
    const [seasons] = await this.db.execute(
      'SELECT code, name, months_set FROM seasons WHERE FIND_IN_SET(?, months_set) > 0',
      [currentMonth]
    );

    const currentSeason = (seasons as any[])[0];

    return {
      success: true,
      data: currentSeason || null,
    };
  }

  async getSeasonByCode(code: string) {
    const [seasons] = await this.db.execute(
      'SELECT code, name, months_set FROM seasons WHERE code = ?',
      [code]
    );

    const season = (seasons as any[])[0];

    return {
      success: true,
      data: season || null,
    };
  }

  async getIngredientSeasonality(ingredientId: string, region?: string) {
    let query = `
      SELECT 
        s.code as season_code,
        s.name as season_name,
        ise.availability_percent,
        ise.price_index,
        ise.quality
      FROM seasons s
      LEFT JOIN ingredient_seasonality ise ON s.code = ise.season_code AND ise.ingredient_id = ?
    `;
    
    let params: any[] = [ingredientId];

    if (region) {
      query += ' AND ise.region = ?';
      params.push(region);
    }

    query += ' ORDER BY s.code';

    const [seasonality] = await this.db.execute(query, params);

    return {
      success: true,
      data: seasonality,
    };
  }
}