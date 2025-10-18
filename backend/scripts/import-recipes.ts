#!/usr/bin/env node

import { NestFactory } from '@nestjs/core';
import { AppModule } from '../src/app.module';
import { Logger } from '@nestjs/common';
import * as fs from 'fs';
import * as path from 'path';

async function cleanAndImportRecipes() {
  const logger = new Logger('RecipeImporter');

  try {
    const appContext = await NestFactory.createApplicationContext(AppModule);
    const db = appContext.get('DATABASE_CONNECTION');

    logger.log('🧹 Cleaning recipes table...');
    
    // Clean recipes table
    await db.execute('SET FOREIGN_KEY_CHECKS = 0');
    await db.execute('TRUNCATE TABLE recipes');
    await db.execute('SET FOREIGN_KEY_CHECKS = 1');
    
    logger.log('✅ Recipes table cleaned');

    // Read CSV file
    const csvPath = path.resolve('../recipes_project.csv');
    if (!fs.existsSync(csvPath)) {
      throw new Error(`CSV file not found: ${csvPath}`);
    }

    logger.log('📥 Reading CSV file...');
    // Try different encodings
    let csvContent;
    try {
      csvContent = fs.readFileSync(csvPath, 'utf8');
    } catch (error) {
      try {
        csvContent = fs.readFileSync(csvPath, 'latin1');
      } catch (error2) {
        csvContent = fs.readFileSync(csvPath, 'utf16le');
      }
    }
    const lines = csvContent.split('\n').filter(line => line.trim());
    
    // Skip header row
    const dataLines = lines.slice(1);
    logger.log(`Found ${dataLines.length} recipe records`);

    let importedCount = 0;
    let errorCount = 0;
    const BATCH_SIZE = 100;

    // Process in batches
    for (let batchStart = 0; batchStart < dataLines.length; batchStart += BATCH_SIZE) {
      const batchEnd = Math.min(batchStart + BATCH_SIZE, dataLines.length);
      const batch = dataLines.slice(batchStart, batchEnd);
      
      const batchData: (string | number | null)[][] = [];
      
      // Process batch
      for (let i = 0; i < batch.length; i++) {
        const line = batch[i].trim();
        if (!line) continue;

        try {
          // Split by semicolon and handle quoted fields
          const fields = parseCSVLine(line);
          
          if (fields.length < 21) {
            logger.warn(`Skipping line ${batchStart + i + 2}: insufficient fields (${fields.length})`);
            continue;
          }

          // Map CSV fields to database columns
          const recipeData = {
            id: fields[0] || null,
            name_vi: fields[1] || null,
            name_en: fields[2] || null,
            meal_type: fields[3] || 'DINNER',
            difficulty: fields[4] ? parseInt(fields[4]) : null,
            cook_time_min: fields[5] ? parseInt(fields[5]) : null,
            region: fields[6] || null,
            base_region: fields[7] || null,
            authenticity: fields[8] || 'TRUYEN_THONG',
            spice_level: fields[9] ? parseInt(fields[9]) : 1,
            saltiness: fields[10] ? parseInt(fields[10]) : 2,
            hardness: fields[11] ? parseInt(fields[11]) : 2,
            image_url: fields[12] || null,
            instructions_md: fields[13] || null,
            nutrition_json: fields[14] || '{}',
            is_public: fields[15] ? parseInt(fields[15]) : 1,
            author_id: fields[16] || null,
            rating_avg: fields[17] ? parseFloat(fields[17]) : 0.00,
            rating_count: fields[18] ? parseInt(fields[18]) : 0
          };

          batchData.push([
            recipeData.id, recipeData.name_vi, recipeData.name_en, recipeData.meal_type,
            recipeData.difficulty, recipeData.cook_time_min, recipeData.region, recipeData.base_region,
            recipeData.authenticity, recipeData.spice_level, recipeData.saltiness, recipeData.hardness,
            recipeData.image_url, recipeData.instructions_md, recipeData.nutrition_json, recipeData.is_public,
            recipeData.author_id, recipeData.rating_avg, recipeData.rating_count
          ]);

        } catch (error) {
          errorCount++;
          logger.error(`Error parsing recipe ${batchStart + i + 2}: ${error.message}`);
        }
      }

      // Batch insert
      if (batchData.length > 0) {
        try {
          const placeholders = batchData.map(() => '(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)').join(', ');
          const values = batchData.flat();
          
          await db.execute(
            `INSERT INTO recipes (
              id, name_vi, name_en, meal_type, difficulty, cook_time_min,
              region, base_region, authenticity, spice_level, saltiness, hardness,
              image_url, instructions_md, nutrition_json, is_public, author_id,
              rating_avg, rating_count
            ) VALUES ${placeholders}`,
            values
          );

          importedCount += batchData.length;
          logger.log(`Imported ${importedCount}/${dataLines.length} recipes`);
          
        } catch (error) {
          errorCount += batchData.length;
          logger.error(`Error importing batch ${Math.floor(batchStart / BATCH_SIZE) + 1}: ${error.message}`);
        }
      }
    }

    logger.log(`✅ Recipe import completed!`);
    logger.log(`📊 Imported: ${importedCount} recipes`);
    logger.log(`❌ Errors: ${errorCount} recipes`);

    await appContext.close();
    process.exit(0);
  } catch (error) {
    logger.error('❌ Recipe import failed:', error.stack);
    process.exit(1);
  }
}

function parseCSVLine(line: string): string[] {
  const fields: string[] = [];
  let currentField = '';
  let inQuotes = false;
  
  for (let i = 0; i < line.length; i++) {
    const char = line[i];
    
    if (char === '"') {
      inQuotes = !inQuotes;
    } else if (char === ';' && !inQuotes) {
      fields.push(currentField.trim());
      currentField = '';
    } else {
      currentField += char;
    }
  }
  
  fields.push(currentField.trim());
  return fields;
}

cleanAndImportRecipes();
