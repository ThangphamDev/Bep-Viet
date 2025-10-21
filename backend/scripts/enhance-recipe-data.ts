import { NestFactory } from '@nestjs/core';
import { AppModule } from '../src/app.module';

interface Recipe {
  id: string;
  name_vi: string;
  difficulty: number;
  cook_time_min: number | null;
  base_region: string | null;
}

async function enhanceRecipeData() {
  console.log('🚀 Starting recipe data enhancement...');
  
  const app = await NestFactory.createApplicationContext(AppModule);
  const db = app.get('DATABASE_CONNECTION');
  
  try {
    // Get all recipes
    const [recipes] = await db.execute(`
      SELECT id, name_vi, difficulty, cook_time_min, base_region 
      FROM recipes 
      WHERE cook_time_min IS NULL OR base_region IS NULL OR base_region = ''
    `);
    
    console.log(`📊 Found ${recipes.length} recipes to enhance`);
    
    let updated = 0;
    
    for (const recipe of recipes) {
      const updates: string[] = [];
      const values: any[] = [];
      
      // Generate cook_time_min based on difficulty and recipe name
      if (!recipe.cook_time_min) {
        let cookTime = 30; // default
        
        // Adjust based on recipe name patterns
        const name = recipe.name_vi.toLowerCase();
        if (name.includes('luộc') || name.includes('hấp')) {
          cookTime = 20;
        } else if (name.includes('xào') || name.includes('chiên')) {
          cookTime = 15;
        } else if (name.includes('nướng') || name.includes('quay')) {
          cookTime = 60;
        } else if (name.includes('kho') || name.includes('hầm')) {
          cookTime = 90;
        } else if (name.includes('canh') || name.includes('súp')) {
          cookTime = 25;
        }
        
        // Adjust based on difficulty
        cookTime += (recipe.difficulty - 1) * 10;
        
        updates.push('cook_time_min = ?');
        values.push(cookTime);
      }
      
      // Generate base_region based on recipe name patterns
      if (!recipe.base_region || recipe.base_region === '') {
        let region = 'BAC'; // default
        
        const name = recipe.name_vi.toLowerCase();
        if (name.includes('bún bò') || name.includes('bánh xèo') || name.includes('cà phê')) {
          region = 'TRUNG';
        } else if (name.includes('bún riêu') || name.includes('bánh mì') || name.includes('chả cá')) {
          region = 'BAC';
        } else if (name.includes('bún mắm') || name.includes('bánh tráng') || name.includes('gỏi cuốn')) {
          region = 'NAM';
        }
        
        updates.push('base_region = ?');
        values.push(region);
      }
      
      if (updates.length > 0) {
        values.push(recipe.id);
        await db.execute(`
          UPDATE recipes 
          SET ${updates.join(', ')} 
          WHERE id = ?
        `, values);
        
        updated++;
        
        if (updated % 1000 === 0) {
          console.log(`✅ Enhanced ${updated} recipes...`);
        }
      }
    }
    
    console.log(`🎉 Successfully enhanced ${updated} recipes!`);
    
    // Verify results
    const [stats] = await db.execute(`
      SELECT 
        COUNT(*) as total,
        COUNT(CASE WHEN cook_time_min IS NOT NULL THEN 1 END) as with_cook_time,
        COUNT(CASE WHEN base_region IS NOT NULL AND base_region != '' THEN 1 END) as with_region
      FROM recipes
    `);
    
    console.log('📊 Final stats:', stats[0]);
    
  } catch (error) {
    console.error('❌ Error enhancing recipe data:', error);
  } finally {
    await app.close();
  }
}

enhanceRecipeData().catch(console.error);
