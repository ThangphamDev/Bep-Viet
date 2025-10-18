import { Module } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import * as mysql from 'mysql2/promise';
import { MigrationService } from './migration.service';

@Module({
  providers: [
    {
      provide: 'DATABASE_CONNECTION',
      useFactory: async (configService: ConfigService) => {
        const pool = mysql.createPool({
          host: configService.get('DB_HOST'),
          port: configService.get('DB_PORT'),
          user: configService.get('DB_USER'),
          password: configService.get('DB_PASS'),
          database: configService.get('DB_NAME'),
          waitForConnections: true,
          connectionLimit: 10,
          queueLimit: 0,
          charset: 'utf8mb4',
        });

        // Test connection
        try {
          const connection = await pool.getConnection();
          console.log('Database connected successfully');
          connection.release();
        } catch (error) {
          console.warn('Database connection failed:', error.message);
          console.warn('Server will start without database connection');
        }

        return pool;
      },
      inject: [ConfigService],
    },
    MigrationService,
  ],
  exports: ['DATABASE_CONNECTION', MigrationService],
})
export class DatabaseModule {}
