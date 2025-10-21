#!/usr/bin/env node

import { NestFactory } from '@nestjs/core';
import { AppModule } from '../src/app.module';
import { Logger } from '@nestjs/common';
import * as fs from 'fs';
import * as path from 'path';
import csv from 'csv-parser';

interface RecipeData {
  id_key: string;
  title: string;
  cuisine: string;
  region: string;
  servings: string;
  total_minutes: string;
  source_url: string;
  image_url: string;
}

interface IngredientData {
  id_key: string;
  name: string;
  default_unit: string;
  category_id: string;
  shelf_life_days: string;
  perishable: string;
  notes: string;
}

interface RecipeIngredientData {
  recipe_id_key: string;
  ingredient_key: string;
  quantity: string;
  unit: string;
  raw_line: string;
}

interface UnitData {
  code: string;
  name: string;
  type: string;
}

interface TagData {
  name: string;
  type: string;
}

interface RecipeTagData {
  recipe_id_key: string;
  tag_name: string;
}

interface UnitConversionData {
  from_unit: string;
  to_unit: string;
  factor: string;
}

interface IngredientAliasData {
  ingredient_key: string;
  alias: string;
}

class DataImporter {
  private logger = new Logger('DataImporter');
  private db: any;
  private dataPath: string;

  constructor(db: any, dataPath: string) {
    this.db = db;
    this.dataPath = dataPath;
  }

  async importAll() {
    try {
      this.logger.log('🚀 Starting data import process...');

      // Disable foreign key checks temporarily
      await this.db.execute('SET FOREIGN_KEY_CHECKS = 0');

      // Import in correct order to respect foreign key constraints
      await this.importUnits();
      await this.importUnitConversions();
      await this.importIngredients();
      await this.importIngredientAliases();
      await this.importTags();
      await this.importRecipes();
      await this.importRecipeIngredients();
      await this.importRecipeTags();

      // Re-enable foreign key checks
      await this.db.execute('SET FOREIGN_KEY_CHECKS = 1');

      this.logger.log('✅ Data import completed successfully!');
    } catch (error) {
      this.logger.error('❌ Data import failed:', error.stack);
      throw error;
    }
  }

  private async importUnits() {
    this.logger.log('📦 Importing units...');
    const units = await this.readCSV<UnitData>('units.csv');
    
    const BATCH_SIZE = 100;
    let importedCount = 0;
    
    for (let i = 0; i < units.length; i += BATCH_SIZE) {
      const batch = units.slice(i, i + BATCH_SIZE);
      
      try {
        const values = batch.map(unit => [unit.code, unit.name, unit.type]);
        
        const placeholders = values.map(() => '(?, ?, ?)').join(', ');
        const flatValues = values.flat();
        
        await this.db.execute(
          `INSERT INTO units (code, name, type) VALUES ${placeholders}
           ON DUPLICATE KEY UPDATE name = VALUES(name), type = VALUES(type)`,
          flatValues
        );
        
        importedCount += batch.length;
        this.logger.log(`Imported ${importedCount}/${units.length} units`);
      } catch (error) {
        this.logger.warn(`Failed to import units batch ${i}-${i + BATCH_SIZE}: ${error.message}`);
      }
    }
    
    this.logger.log(`✅ Imported ${importedCount} units`);
  }

  private async importUnitConversions() {
    this.logger.log('🔄 Importing unit conversions...');
    const conversions = await this.readCSV<UnitConversionData>('unit_conversions.csv');
    
    const BATCH_SIZE = 100;
    let importedCount = 0;
    
    for (let i = 0; i < conversions.length; i += BATCH_SIZE) {
      const batch = conversions.slice(i, i + BATCH_SIZE);
      
      try {
        const values = batch.map(conversion => [
          conversion.from_unit,
          conversion.to_unit,
          parseFloat(conversion.factor)
        ]);
        
        const placeholders = values.map(() => '(?, ?, ?)').join(', ');
        const flatValues = values.flat();
        
        await this.db.execute(
          `INSERT INTO unit_conversions (from_unit, to_unit, factor) VALUES ${placeholders}`,
          flatValues
        );
        
        importedCount += batch.length;
        this.logger.log(`Imported ${importedCount}/${conversions.length} unit conversions`);
      } catch (error) {
        this.logger.warn(`Failed to import unit conversions batch ${i}-${i + BATCH_SIZE}: ${error.message}`);
      }
    }
    
    this.logger.log(`✅ Imported ${importedCount} unit conversions`);
  }

  private async importIngredients() {
    this.logger.log('🥕 Importing ingredients...');
    const ingredients = await this.readCSV<IngredientData>('ingredients.csv');
    
    // Import all ingredients (no limit)
    const BATCH_SIZE = 100;
    let importedCount = 0;
    
    for (let i = 0; i < ingredients.length; i += BATCH_SIZE) {
      const batch = ingredients.slice(i, i + BATCH_SIZE);
      
      try {
        // Prepare batch data
        const values = batch.map(ingredient => {
          const ingredientId = this.generateUUID();
          this.storeIngredientMapping(ingredient.id_key, ingredientId);
          
          return [
            ingredientId,
            ingredient.name,
            ingredient.default_unit || 'g',
            ingredient.shelf_life_days ? parseInt(ingredient.shelf_life_days) : null,
            ingredient.perishable === '1' ? 1 : 0,
            ingredient.notes || null
          ];
        });
        
        const placeholders = values.map(() => '(?, ?, ?, ?, ?, ?)').join(', ');
        const flatValues = values.flat();
        
        await this.db.execute(
          `INSERT INTO ingredients (id, name, default_unit, shelf_life_days, perishable, notes) 
           VALUES ${placeholders}`,
          flatValues
        );
        
        importedCount += batch.length;
        this.logger.log(`Imported ${importedCount}/${ingredients.length} ingredients`);
      } catch (error) {
        this.logger.warn(`Failed to import ingredients batch ${i}-${i + BATCH_SIZE}: ${error.message}`);
      }
    }
    
    this.logger.log(`✅ Imported ${importedCount} ingredients`);
  }

  private async importIngredientAliases() {
    this.logger.log('🏷️ Importing ingredient aliases...');
    const aliases = await this.readCSV<IngredientAliasData>('ingredient_aliases.csv');
    
    const BATCH_SIZE = 100;
    let importedCount = 0;
    
    for (let i = 0; i < aliases.length; i += BATCH_SIZE) {
      const batch = aliases.slice(i, i + BATCH_SIZE);
      const values: (string | number | null)[][] = [];
      
      for (const alias of batch) {
        try {
          const ingredientId = this.getIngredientIdByKey(alias.ingredient_key);
          if (ingredientId) {
            values.push([
              this.generateUUID(), // id
              ingredientId,
              alias.alias
            ]);
          }
        } catch (error) {
          this.logger.warn(`Failed to process alias ${alias.alias}: ${error.message}`);
        }
      }
      
      if (values.length > 0) {
        try {
          const placeholders = values.map(() => '(?, ?, ?)').join(', ');
          const flatValues = values.flat();
          
          await this.db.execute(
            `INSERT INTO ingredient_aliases (id, ingredient_id, alias) VALUES ${placeholders}`,
            flatValues
          );
          
          importedCount += values.length;
          this.logger.log(`Imported ${importedCount}/${aliases.length} ingredient aliases`);
        } catch (error) {
          this.logger.warn(`Failed to import ingredient aliases batch ${i}-${i + BATCH_SIZE}: ${error.message}`);
        }
      }
    }
    
    this.logger.log(`✅ Imported ${importedCount} ingredient aliases`);
  }

  private async importTags() {
    this.logger.log('🏷️ Importing tags...');
    const tags = await this.readCSV<TagData>('tags.csv');
    
    const BATCH_SIZE = 100;
    let importedCount = 0;
    
    for (let i = 0; i < tags.length; i += BATCH_SIZE) {
      const batch = tags.slice(i, i + BATCH_SIZE);
      
      try {
        const values = batch.map(tag => {
          const tagId = this.generateUUID();
          this.storeTagMapping(tag.name, tagId);
          
          return [
            tagId,
            tag.name,
            tag.type || null
          ];
        });
        
        const placeholders = values.map(() => '(?, ?, ?)').join(', ');
        const flatValues = values.flat();
        
        await this.db.execute(
          `INSERT INTO tags (id, name, type) VALUES ${placeholders}`,
          flatValues
        );
        
        importedCount += batch.length;
        this.logger.log(`Imported ${importedCount}/${tags.length} tags`);
      } catch (error) {
        this.logger.warn(`Failed to import tags batch ${i}-${i + BATCH_SIZE}: ${error.message}`);
      }
    }
    
    this.logger.log(`✅ Imported ${importedCount} tags`);
  }

  private async importRecipes() {
    this.logger.log('🍳 Importing recipes...');
    const recipes = await this.readCSV<RecipeData>('recipes.csv');
    this.logger.log(`Found ${recipes.length} recipes to import`);
    
    // Import all recipes (no limit)
    const BATCH_SIZE = 100;
    let importedCount = 0;
    
    for (let i = 0; i < recipes.length; i += BATCH_SIZE) {
      const batch = recipes.slice(i, i + BATCH_SIZE);
      
      try {
        // Prepare batch data
        const values = batch.map(recipe => {
          const recipeId = this.generateUUID();
          this.storeRecipeMapping(recipe.id_key, recipeId);
          
          // Parse servings
          const servings = this.parseServings(recipe.servings);
          
          // Parse cooking time
          const cookTimeMin = recipe.total_minutes ? parseInt(recipe.total_minutes) : null;
          
          // Map region
          const baseRegion = this.mapRegion(recipe.region);
          
          return [
            recipeId,
            recipe.title,
            null, // name_en
            'LUNCH', // Default meal type
            null, // difficulty
            cookTimeMin,
            baseRegion,
            recipe.image_url || null,
            servings,
            1, // is_public
            new Date(),
            new Date()
          ];
        });
        
        const placeholders = values.map(() => '(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)').join(', ');
        const flatValues = values.flat();
        
        await this.db.execute(
          `INSERT INTO recipes (
            id, name_vi, name_en, meal_type, difficulty, cook_time_min, 
            base_region, image_url, servings, is_public, created_at, updated_at
          ) VALUES ${placeholders}`,
          flatValues
        );
        
        importedCount += batch.length;
        this.logger.log(`Imported ${importedCount}/${recipes.length} recipes`);
      } catch (error) {
        this.logger.error(`Failed to import recipes batch ${i}-${i + BATCH_SIZE}: ${error.message}`);
        this.logger.error(`Error details: ${error.stack}`);
      }
    }
    
    this.logger.log(`✅ Imported ${importedCount} recipes`);
  }

  private async importRecipeIngredients() {
    this.logger.log('🥘 Importing recipe ingredients...');
    const recipeIngredients = await this.readCSV<RecipeIngredientData>('recipe_ingredients.csv');
    
    // Import all recipe ingredients (no limit)
    const BATCH_SIZE = 100;
    let importedCount = 0;
    
    for (let i = 0; i < recipeIngredients.length; i += BATCH_SIZE) {
      const batch = recipeIngredients.slice(i, i + BATCH_SIZE);
      const values: (string | number | null)[][] = [];
      
      for (const ri of batch) {
        try {
          const recipeId = this.getRecipeIdByKey(ri.recipe_id_key);
          const ingredientId = this.getIngredientIdByKey(ri.ingredient_key);
          
          if (recipeId && ingredientId && ri.quantity) {
            values.push([
              this.generateUUID(), // id
              recipeId,
              ingredientId,
              parseFloat(ri.quantity),
              ri.unit || null,
              ri.raw_line || null
            ]);
          }
        } catch (error) {
          this.logger.warn(`Failed to process recipe ingredient: ${error.message}`);
        }
      }
      
      if (values.length > 0) {
        try {
          const placeholders = values.map(() => '(?, ?, ?, ?, ?, ?)').join(', ');
          const flatValues = values.flat();
          
          await this.db.execute(
            `INSERT INTO recipe_ingredients (id, recipe_id, ingredient_id, quantity, unit, note) 
             VALUES ${placeholders}`,
            flatValues
          );
          importedCount += values.length;
          this.logger.log(`Imported ${importedCount}/${recipeIngredients.length} recipe ingredients`);
        } catch (error) {
          this.logger.warn(`Failed to import recipe ingredients batch ${i}-${i + BATCH_SIZE}: ${error.message}`);
        }
      }
    }
    
    this.logger.log(`✅ Imported ${importedCount} recipe ingredients`);
  }

  private async importRecipeTags() {
    this.logger.log('🏷️ Importing recipe tags...');
    const recipeTags = await this.readCSV<RecipeTagData>('recipe_tags.csv');
    
    const BATCH_SIZE = 100;
    let importedCount = 0;
    
    for (let i = 0; i < recipeTags.length; i += BATCH_SIZE) {
      const batch = recipeTags.slice(i, i + BATCH_SIZE);
      const values: (string | number | null)[][] = [];
      
      for (const rt of batch) {
        try {
          const recipeId = this.getRecipeIdByKey(rt.recipe_id_key);
          const tagId = this.getTagIdByName(rt.tag_name);
          
          if (recipeId && tagId) {
            values.push([
              recipeId,
              tagId
            ]);
          }
        } catch (error) {
          this.logger.warn(`Failed to process recipe tag: ${error.message}`);
        }
      }
      
      if (values.length > 0) {
        try {
          const placeholders = values.map(() => '(?, ?)').join(', ');
          const flatValues = values.flat();
          
          await this.db.execute(
            `INSERT INTO recipe_tags (recipe_id, tag_id) VALUES ${placeholders}`,
            flatValues
          );
          
          importedCount += values.length;
          this.logger.log(`Imported ${importedCount}/${recipeTags.length} recipe tags`);
        } catch (error) {
          this.logger.warn(`Failed to import recipe tags batch ${i}-${i + BATCH_SIZE}: ${error.message}`);
        }
      }
    }
    
    this.logger.log(`✅ Imported ${importedCount} recipe tags`);
  }

  // Helper methods
  private async readCSV<T>(filename: string): Promise<T[]> {
    return new Promise((resolve, reject) => {
      const results: T[] = [];
      const filePath = path.join(this.dataPath, filename);
      
      if (!fs.existsSync(filePath)) {
        this.logger.warn(`File ${filename} not found, skipping...`);
        resolve([]);
        return;
      }

      fs.createReadStream(filePath)
        .pipe(csv())
        .on('data', (data) => results.push(data))
        .on('end', () => resolve(results))
        .on('error', reject);
    });
  }

  private generateUUID(): string {
    return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
      const r = Math.random() * 16 | 0;
      const v = c == 'x' ? r : (r & 0x3 | 0x8);
      return v.toString(16);
    });
  }

  private parseServings(servingsStr: string): number | null {
    if (!servingsStr) return null;
    
    const match = servingsStr.match(/(\d+)/);
    return match ? parseInt(match[1]) : null;
  }

  private mapRegion(regionStr: string): string | null {
    if (!regionStr) return null;
    
    const regionMap: { [key: string]: string } = {
      'BAC': 'BAC',
      'TRUNG': 'TRUNG', 
      'NAM': 'NAM',
      'Miền Bắc': 'BAC',
      'Miền Trung': 'TRUNG',
      'Miền Nam': 'NAM'
    };
    
    return regionMap[regionStr] || null;
  }

  // Mapping storage methods - using in-memory maps for better performance
  private ingredientMapping = new Map<string, string>();
  private tagMapping = new Map<string, string>();
  private recipeMapping = new Map<string, string>();

  private storeIngredientMapping(key: string, id: string) {
    this.ingredientMapping.set(key, id);
  }

  private storeTagMapping(name: string, id: string) {
    this.tagMapping.set(name, id);
  }

  private storeRecipeMapping(key: string, id: string) {
    this.recipeMapping.set(key, id);
  }

  private getIngredientIdByKey(key: string): string | null {
    return this.ingredientMapping.get(key) || null;
  }

  private getTagIdByName(name: string): string | null {
    return this.tagMapping.get(name) || null;
  }

  private getRecipeIdByKey(key: string): string | null {
    return this.recipeMapping.get(key) || null;
  }

}

async function importData() {
  const logger = new Logger('DataImportMain');
  
  try {
    const appContext = await NestFactory.createApplicationContext(AppModule);
    const db = appContext.get('DATABASE_CONNECTION');
    
    const dataPath = path.join(process.cwd(), '..', 'data_csv-v2');
    
    if (!fs.existsSync(dataPath)) {
      throw new Error(`Data directory not found: ${dataPath}`);
    }
    
    const importer = new DataImporter(db, dataPath);
    
    // Import all data
    await importer.importAll();
    
    await appContext.close();
    logger.log('🎉 Data import process completed successfully!');
    process.exit(0);
  } catch (error) {
    logger.error('💥 Data import process failed:', error.stack);
    process.exit(1);
  }
}

// Run the import
importData();
