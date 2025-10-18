import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { Logger } from '@nestjs/common';

async function bootstrap() {
  const logger = new Logger('Bootstrap');
  
  try {
    const app = await NestFactory.create(AppModule);
    
    // Enable CORS
    app.enableCors({
      origin: process.env.CORS_ORIGIN || 'http://localhost:3000',
      credentials: true,
    });

    // Global prefix
    app.setGlobalPrefix('api/v1');

    const port = process.env.PORT || 8080;
    await app.listen(port);
    
    logger.log(`🚀 Backend server is running on http://localhost:${port}`);
    logger.log(`📚 API Documentation available at http://localhost:${port}/api/v1`);
  } catch (error) {
    logger.error('Failed to start server:', error);
    process.exit(1);
  }
}

bootstrap();