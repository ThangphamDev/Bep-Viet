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
          timezone: '+07:00', // Vietnam timezone (UTC+7)
          dateStrings: false, // Parse dates as Date objects
          // Type cast to ensure dates are in Vietnam timezone
          typeCast: function (field, next) {
            if (field.type === 'DATETIME' || field.type === 'TIMESTAMP') {
              const value = field.string();
              if (value) {
                // MySQL returns datetime in connection timezone (+07:00)
                // Return as is, let JavaScript handle it
                return new Date(value);
              }
              return null;
            }
            return next();
          },
        });

        // Test connection and set timezone globally for all sessions
        try {
          const connection = await pool.getConnection();
          
          // Set session timezone to Vietnam (UTC+7) for this connection
          await connection.query("SET time_zone = '+07:00'");
          
          // Also set global timezone if possible (may fail without privileges)
          try {
            await connection.query("SET GLOBAL time_zone = '+07:00'");
          } catch (e) {
            // Ignore if no privileges
          }
          
          console.log('Database connected successfully');
          console.log('Timezone set to +07:00 (Vietnam)');
          
          connection.release();
        } catch (error) {
          console.warn('Database connection failed:', error.message);
          console.warn('Server will start without database connection');
        }

        // Wrap pool.execute to always set timezone before executing
        const originalExecute = pool.execute.bind(pool);
        pool.execute = async function(sql: any, values?: any) {
          const connection = await pool.getConnection();
          try {
            // Set timezone for this connection
            await connection.query("SET time_zone = '+07:00'");
            // Execute the actual query
            const result = await connection.execute(sql, values);
            connection.release();
            return result;
          } catch (error) {
            connection.release();
            throw error;
          }
        } as any;

        return pool;
      },
      inject: [ConfigService],
    },
    MigrationService,
  ],
  exports: ['DATABASE_CONNECTION', MigrationService],
})
export class DatabaseModule {}
