#!/usr/bin/env node

import { spawn } from 'child_process';
import { Logger } from '@nestjs/common';
import * as path from 'path';

const logger = new Logger('DataImportRunner');

async function runScript(scriptPath: string, scriptName: string): Promise<void> {
  return new Promise((resolve, reject) => {
    logger.log(`🚀 Running ${scriptName}...`);
    
    const child = spawn('npx', ['ts-node', scriptPath], {
      stdio: 'inherit',
      cwd: path.join(__dirname, '..')
    });

    child.on('close', (code) => {
      if (code === 0) {
        logger.log(`✅ ${scriptName} completed successfully`);
        resolve();
      } else {
        logger.error(`❌ ${scriptName} failed with exit code ${code}`);
        reject(new Error(`${scriptName} failed`));
      }
    });

    child.on('error', (error) => {
      logger.error(`❌ Error running ${scriptName}:`, error);
      reject(error);
    });
  });
}

async function main() {
  try {
    logger.log('🎯 Starting complete data import process...');
    
    // Step 1: Clean database
    await runScript('./scripts/clean-database.ts', 'Database Cleaner');
    
    // Step 2: Import data
    await runScript('./scripts/import-data.ts', 'Data Importer');
    
    logger.log('🎉 Complete data import process finished successfully!');
    process.exit(0);
  } catch (error) {
    logger.error('💥 Data import process failed:', error.message);
    process.exit(1);
  }
}

main();
