import mysql from 'mysql2/promise';
import env from './env';
import logger from './logger';

// Create connection pool
const pool = mysql.createPool({
  host: env.DB_HOST,
  port: env.DB_PORT,
  user: env.DB_USER,
  password: env.DB_PASS,
  database: env.DB_NAME,
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,
  charset: 'utf8mb4',
});

// Test connection
pool.getConnection()
  .then((connection) => {
    logger.info('Database connected successfully');
    connection.release();
  })
  .catch((error) => {
    logger.error('Database connection failed:', error);
    process.exit(1);
  });

// Graceful shutdown
process.on('SIGINT', async () => {
  logger.info('Closing database connections...');
  await pool.end();
  process.exit(0);
});

export { pool };
export default pool;
