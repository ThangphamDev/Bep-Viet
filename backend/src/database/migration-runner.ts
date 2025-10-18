#!/usr/bin/env node

import { NestFactory } from '@nestjs/core';
import { AppModule } from '../app.module';
import { MigrationService } from './migration.service';
import { Logger } from '@nestjs/common';

async function bootstrap() {
  const logger = new Logger('MigrationRunner');
  
  try {
    const app = await NestFactory.createApplicationContext(AppModule);
    const migrationService = app.get(MigrationService);

    const command = process.argv[2];

    switch (command) {
      case 'migrate':
        await migrationService.runMigrations();
        break;
      case 'seed':
        await migrationService.runSeeds();
        break;
      case 'reset':
        await migrationService.resetDatabase();
        break;
      case 'fresh':
        await migrationService.resetDatabase();
        await migrationService.runMigrations();
        await migrationService.runSeeds();
        break;
      default:
        logger.log('Usage: npm run migration:migrate|seed|reset|fresh');
        process.exit(1);
    }

    logger.log('Operation completed successfully');
    await app.close();
    process.exit(0);
  } catch (error) {
    logger.error('Operation failed:', error);
    process.exit(1);
  }
}

bootstrap();
