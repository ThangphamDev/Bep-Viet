import { Controller, Get, Query } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiQuery } from '@nestjs/swagger';
import { RegionsService } from './regions.service';

@ApiTags('Regions')
@Controller('regions')
export class RegionsController {
  constructor(private readonly regionsService: RegionsService) {}

  @Get()
  @ApiOperation({ summary: 'Get all regions' })
  @ApiResponse({ status: 200, description: 'List of regions' })
  async getAllRegions() {
    return this.regionsService.getAllRegions();
  }

  @Get('subregions')
  @ApiOperation({ summary: 'Get subregions' })
  @ApiQuery({ name: 'region', required: false, description: 'Filter by region code' })
  @ApiResponse({ status: 200, description: 'List of subregions' })
  async getSubregions(@Query('region') region?: string) {
    return this.regionsService.getSubregions(region);
  }

  @Get('with-subregions')
  @ApiOperation({ summary: 'Get regions with their subregions' })
  @ApiResponse({ status: 200, description: 'Regions with subregions' })
  async getRegionWithSubregions() {
    return this.regionsService.getRegionWithSubregions();
  }
}