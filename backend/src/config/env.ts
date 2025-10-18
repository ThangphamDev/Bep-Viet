import dotenv from 'dotenv';
import { z } from 'zod';

// Load environment variables
dotenv.config();

// Environment validation schema
const envSchema = z.object({
  NODE_ENV: z.enum(['development', 'production', 'test']).default('development'),
  PORT: z.string().transform(Number).default(8080),
  DB_HOST: z.string().default('localhost'),
  DB_PORT: z.string().transform(Number).default(3306),
  DB_USER: z.string().default('root'),
  DB_PASS: z.string().default(''),
  DB_NAME: z.string().default('bepviet'),
  JWT_SECRET: z.string().min(32).default('supersecretkey123456789012345678901234567890'),
  JWT_EXPIRES: z.string().transform(Number).default(3600),
  REFRESH_SECRET: z.string().min(32).default('refreshsecretkey123456789012345678901234567890'),
  REFRESH_EXPIRES: z.string().transform(Number).default(604800),
  RATE_LIMIT_WINDOW_MS: z.string().transform(Number).default(900000),
  RATE_LIMIT_MAX_REQUESTS: z.string().transform(Number).default(100),
  CORS_ORIGIN: z.string().default('http://localhost:3000'),
  LOG_LEVEL: z.enum(['error', 'warn', 'info', 'debug']).default('info'),
});

// Validate environment variables
const env = envSchema.parse(process.env);

export default env;
