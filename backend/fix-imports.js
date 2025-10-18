const fs = require('fs');
const path = require('path');

console.log('🔧 Fixing .js imports in TypeScript files...');

// Find all .ts files in src directory
function findTsFiles(dir) {
  const files = [];
  const items = fs.readdirSync(dir);
  
  for (const item of items) {
    const fullPath = path.join(dir, item);
    const stat = fs.statSync(fullPath);
    
    if (stat.isDirectory()) {
      files.push(...findTsFiles(fullPath));
    } else if (item.endsWith('.ts')) {
      files.push(fullPath);
    }
  }
  
  return files;
}

// Fix imports in a file
function fixImports(filePath) {
  let content = fs.readFileSync(filePath, 'utf8');
  
  // Replace .js imports with no extension
  content = content.replace(/from ['"](\.\/[^'"]+)\.js['"]/g, "from '$1'");
  content = content.replace(/import ['"](\.\/[^'"]+)\.js['"]/g, "import '$1'");
  
  fs.writeFileSync(filePath, content);
  console.log(`✅ Fixed: ${path.relative(__dirname, filePath)}`);
}

// Fix all TypeScript files
const srcDir = path.join(__dirname, 'src');
const tsFiles = findTsFiles(srcDir);

tsFiles.forEach(fixImports);

console.log('🎉 All imports fixed!');
