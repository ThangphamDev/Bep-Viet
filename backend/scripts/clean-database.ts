#!/usr/bin/env node

import { NestFactory } from '@nestjs/core';
import { AppModule } from '../src/app.module';
import { Logger } from '@nestjs/common';

async function cleanDatabase() {
  const logger = new Logger('DatabaseCleaner');

  try {
    const appContext = await NestFactory.createApplicationContext(AppModule);
    const db = appContext.get('DATABASE_CONNECTION');

    logger.log('🧹 Starting database cleanup...');

    // Disable foreign key checks temporarily
    await db.execute('SET FOREIGN_KEY_CHECKS = 0');

    // Get all table names
    const [tables] = await db.execute(`
      SELECT TABLE_NAME 
      FROM INFORMATION_SCHEMA.TABLES 
      WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_TYPE = 'BASE TABLE'
    `);

    // Clean all tables
    for (const table of tables as any[]) {
      const tableName = table.TABLE_NAME;
      logger.log(`Cleaning table: ${tableName}`);
      await db.execute(`TRUNCATE TABLE ${tableName}`);
    }

    // Re-enable foreign key checks
    await db.execute('SET FOREIGN_KEY_CHECKS = 1');

    logger.log('✅ Database cleanup completed successfully!');
    await appContext.close();
    process.exit(0);
  } catch (error) {
    logger.error('❌ Database cleanup failed:', error.stack);
    process.exit(1);
  }
}

cleanDatabase();
