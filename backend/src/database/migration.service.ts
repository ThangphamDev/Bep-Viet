import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import * as fs from 'fs';
import * as path from 'path';
import { Inject } from '@nestjs/common';

@Injectable()
export class MigrationService {
  private readonly logger = new Logger(MigrationService.name);

  constructor(
    @Inject('DATABASE_CONNECTION') private readonly db: any,
    private readonly configService: ConfigService,
  ) {}

  async runMigrations(): Promise<void> {
    try {
      this.logger.log('Starting database migrations...');
      
      // Read migration files
      const migrationDir = path.join(__dirname, 'migrations');
      const migrationFiles = fs.readdirSync(migrationDir)
        .filter(file => file.endsWith('.sql'))
        .sort();

      for (const file of migrationFiles) {
        this.logger.log(`Running migration: ${file}`);
        const sql = fs.readFileSync(path.join(migrationDir, file), 'utf8');
        await this.db.execute(sql);
        this.logger.log(`Migration ${file} completed successfully`);
      }

      this.logger.log('All migrations completed successfully');
    } catch (error) {
      this.logger.error('Migration failed:', error);
      throw error;
    }
  }

  async runSeeds(): Promise<void> {
    try {
      this.logger.log('Starting database seeding...');
      
      // Read seed files
      const seedDir = path.join(__dirname, 'seeds');
      const seedFiles = fs.readdirSync(seedDir)
        .filter(file => file.endsWith('.sql'))
        .sort();

      for (const file of seedFiles) {
        this.logger.log(`Running seed: ${file}`);
        const sql = fs.readFileSync(path.join(seedDir, file), 'utf8');
        await this.db.execute(sql);
        this.logger.log(`Seed ${file} completed successfully`);
      }

      this.logger.log('All seeds completed successfully');
    } catch (error) {
      this.logger.error('Seeding failed:', error);
      throw error;
    }
  }

  async resetDatabase(): Promise<void> {
    try {
      this.logger.log('Resetting database...');
      
      // Drop all tables
      const dropTablesSql = `
        SET FOREIGN_KEY_CHECKS = 0;
        DROP TABLE IF EXISTS moderation_actions;
        DROP TABLE IF EXISTS recipe_ratings;
        DROP TABLE IF EXISTS recipe_comments;
        DROP TABLE IF EXISTS community_recipe_steps;
        DROP TABLE IF EXISTS community_recipe_ingredients;
        DROP TABLE IF EXISTS community_recipes;
        DROP TABLE IF EXISTS notifications;
        DROP TABLE IF EXISTS pantry_items;
        DROP TABLE IF EXISTS share_invitations;
        DROP TABLE IF EXISTS shopping_shares;
        DROP TABLE IF EXISTS shopping_list_items;
        DROP TABLE IF EXISTS shopping_lists;
        DROP TABLE IF EXISTS meal_plan_items;
        DROP TABLE IF EXISTS meal_plans;
        DROP TABLE IF EXISTS recipe_variant_steps;
        DROP TABLE IF EXISTS recipe_variant_ingredients;
        DROP TABLE IF EXISTS recipe_variants;
        DROP TABLE IF EXISTS favorites;
        DROP TABLE IF EXISTS recipe_tags;
        DROP TABLE IF EXISTS recipe_ingredients;
        DROP TABLE IF EXISTS recipes;
        DROP TABLE IF EXISTS tags;
        DROP TABLE IF EXISTS ingredient_seasonality;
        DROP TABLE IF EXISTS seasons;
        DROP TABLE IF EXISTS ingredient_prices;
        DROP TABLE IF EXISTS ingredient_aliases;
        DROP TABLE IF EXISTS ingredients;
        DROP TABLE IF EXISTS store_sections;
        DROP TABLE IF EXISTS ingredient_categories;
        DROP TABLE IF EXISTS unit_conversions;
        DROP TABLE IF EXISTS units;
        DROP TABLE IF EXISTS family_members;
        DROP TABLE IF EXISTS family_profiles;
        DROP TABLE IF EXISTS subscriptions;
        DROP TABLE IF EXISTS devices;
        DROP TABLE IF EXISTS user_preferences;
        DROP TABLE IF EXISTS users;
        DROP TABLE IF EXISTS geo_subregions;
        DROP TABLE IF EXISTS geo_regions;
        SET FOREIGN_KEY_CHECKS = 1;
      `;
      
      await this.db.execute(dropTablesSql);
      this.logger.log('Database reset completed');
    } catch (error) {
      this.logger.error('Database reset failed:', error);
      throw error;
    }
  }
}
