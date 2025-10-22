import * as mysql from 'mysql2/promise';
import * as bcrypt from 'bcryptjs';
import { randomUUID } from 'crypto';

async function createAdmin() {
  let connection: mysql.Connection | null = null;

  try {
    // Create database connection using docker-compose settings
    connection = await mysql.createConnection({
      host: 'localhost',
      port: 3306,
      user: 'bepviet',
      password: 'secret',
      database: 'bepviet',
    });

    console.log('✅ Connected to database');

    // Admin credentials
    const email = 'admin@gmail.com';
    const password = '88888888';
    const name = 'Admin';
    const region = 'BAC';

    // Check if admin already exists
    const [existingUsers] = await connection.execute(
      'SELECT id, email, role FROM users WHERE email = ?',
      [email]
    );

    if ((existingUsers as any[]).length > 0) {
      const existing = (existingUsers as any[])[0];
      console.log(`⚠️  User with email ${email} already exists!`);
      console.log(`   ID: ${existing.id}`);
      console.log(`   Role: ${existing.role}`);
      
      // Ask if want to update to admin role
      if (existing.role !== 'ADMIN') {
        console.log(`\n🔄 Updating user role to ADMIN...`);
        await connection.execute(
          'UPDATE users SET role = ? WHERE email = ?',
          ['ADMIN', email]
        );
        console.log('✅ User role updated to ADMIN');
      } else {
        console.log('ℹ️  User is already an ADMIN');
      }
      
      return;
    }

    // Hash password
    console.log('🔐 Hashing password...');
    const passwordHash = await bcrypt.hash(password, 12);

    // Create admin user
    const userId = randomUUID();
    
    console.log('👤 Creating admin user...');
    await connection.execute(
      `INSERT INTO users (id, email, password_hash, name, region, subregion, role, is_active)
       VALUES (?, ?, ?, ?, ?, ?, 'ADMIN', 1)`,
      [userId, email, passwordHash, name, region, null]
    );

    // Create user preferences
    console.log('⚙️  Creating user preferences...');
    await connection.execute(
      `INSERT INTO user_preferences (user_id, household_size, spicy_level, taste_spicy, taste_salty, taste_sweet, taste_light)
       VALUES (?, 2, 2, 2, 2, 2, 2)`,
      [userId]
    );

    console.log('\n✅ Admin user created successfully!');
    console.log('==========================================');
    console.log(`📧 Email:    ${email}`);
    console.log(`🔑 Password: ${password}`);
    console.log(`👤 Name:     ${name}`);
    console.log(`🎭 Role:     ADMIN`);
    console.log(`🆔 ID:       ${userId}`);
    console.log('==========================================');

  } catch (error) {
    console.error('❌ Error creating admin user:', error);
    throw error;
  } finally {
    if (connection) {
      await connection.end();
      console.log('\n🔌 Database connection closed');
    }
  }
}

// Run the script
createAdmin()
  .then(() => {
    console.log('\n✨ Script completed successfully');
    process.exit(0);
  })
  .catch((error) => {
    console.error('\n💥 Script failed:', error);
    process.exit(1);
  });

