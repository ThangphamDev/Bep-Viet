import { Injectable } from '@nestjs/common';
import { Inject } from '@nestjs/common';

@Injectable()
export class RegionsService {
  constructor(@Inject('DATABASE_CONNECTION') private db: any) {}

  async getAllRegions() {
    const [regions] = await this.db.execute(
      'SELECT code, name FROM geo_regions ORDER BY code'
    );

    return {
      success: true,
      data: regions,
    };
  }

  async getSubregions(regionCode?: string) {
    let query = 'SELECT id, region_code, name FROM geo_subregions';
    let params: any[] = [];

    if (regionCode) {
      query += ' WHERE region_code = ?';
      params.push(regionCode);
    }

    query += ' ORDER BY region_code, name';

    const [subregions] = await this.db.execute(query, params);

    return {
      success: true,
      data: subregions,
    };
  }

  async getRegionWithSubregions() {
    const [regions] = await this.db.execute(
      `SELECT 
        r.code, 
        r.name,
        GROUP_CONCAT(
          JSON_OBJECT('id', s.id, 'name', s.name) 
          ORDER BY s.name SEPARATOR ','
        ) as subregions
       FROM geo_regions r
       LEFT JOIN geo_subregions s ON r.code = s.region_code
       GROUP BY r.code, r.name
       ORDER BY r.code`
    );

    const formattedRegions = (regions as any[]).map(region => ({
      code: region.code,
      name: region.name,
      subregions: region.subregions 
        ? region.subregions.split(',').map((sub: string) => JSON.parse(sub))
        : []
    }));

    return {
      success: true,
      data: formattedRegions,
    };
  }
}