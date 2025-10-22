import * as Joi from 'joi';

export const validationSchema = Joi.object({
  NODE_ENV: Joi.string()
    .valid('development', 'production', 'test')
    .default('development'),
  PORT: Joi.number().default(8080),
  DB_HOST: Joi.string().default('localhost'),
  DB_PORT: Joi.number().default(3306),
  DB_USER: Joi.string().default('root'),
  DB_PASS: Joi.string().default(''),
  DB_NAME: Joi.string().default('bepviet'),
  JWT_SECRET: Joi.string().min(32).required(),
  JWT_EXPIRES: Joi.number().default(3600),
  REFRESH_SECRET: Joi.string().min(32).required(),
  REFRESH_EXPIRES: Joi.number().default(604800),
  RATE_LIMIT_WINDOW_MS: Joi.number().default(900000),
  RATE_LIMIT_MAX_REQUESTS: Joi.number().default(100),
  CORS_ORIGIN: Joi.string().default('http://localhost:3000'),
  LOG_LEVEL: Joi.string()
    .valid('error', 'warn', 'info', 'debug')
    .default('info'),
  GEMINI_API_KEY: Joi.string().optional(),
  GOOGLE_CLIENT_ID: Joi.string().optional(),
});
