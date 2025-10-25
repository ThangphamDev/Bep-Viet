import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { Logger } from '@nestjs/common';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';

async function bootstrap() {
  const logger = new Logger('Bootstrap');
  
  try {
    const app = await NestFactory.create(AppModule);
    
    // Increase JSON payload size limit for base64 images (20MB)
    app.use(require('express').json({ limit: '20mb' }));
    app.use(require('express').urlencoded({ limit: '20mb', extended: true }));
    
    // Enable CORS
    app.enableCors({
      origin: [
        process.env.CORS_ORIGIN || 'http://localhost:8080',
        'https://gullably-nonpsychological-leisha.ngrok-free.dev/',
        /\.ngrok-free\.dev$/,
        /\.ngrok\.io$/
      ],
      credentials: true,
    });

    // Global prefix
    app.setGlobalPrefix('api');

    // Swagger Documentation
    const config = new DocumentBuilder()
      .setTitle('Bếp Việt API')
      .setDescription('API documentation for Bếp Việt - Vietnamese cooking app')
      .setVersion('1.0')
      .addBearerAuth(
        {
          type: 'http',
          scheme: 'bearer',
          bearerFormat: 'JWT',
          name: 'JWT',
          description: 'Enter JWT token',
          in: 'header',
        },
        'JWT-auth',
      )
      .addTag('Authentication', 'User authentication and authorization')
      .addTag('Users', 'User profile management')
      .addTag('Regions', 'Geographic regions and subregions')
      .addTag('Seasons', 'Seasonal data and calculations')
      .addTag('Ingredients', 'Ingredients and categories')
      .addTag('Prices', 'Ingredient pricing by region')
      .addTag('Recipes', 'Recipe management and variants')
      .addTag('Suggestions', 'Smart recipe suggestions')
      .addTag('Meal Plans', 'Meal planning and scheduling')
      .addTag('Pantry', 'Pantry management and tracking')
      .addTag('Shopping', 'Shopping lists and management')
      .addTag('Community', 'Community recipes and sharing')
      .addTag('Comments', 'Recipe comments and interactions')
      .addTag('Ratings', 'Recipe ratings and reviews')
      .addTag('Family', 'Family profiles and management')
      .addTag('Advisory', 'Nutritional advisory services')
      .addTag('Analytics', 'User and system analytics')
      .addTag('Moderation', 'Content moderation tools')
      .addTag('Subscriptions', 'Premium subscription management')
      .addTag('Notifications', 'Notification management')
      .build();

    const document = SwaggerModule.createDocument(app, config);
    SwaggerModule.setup('api/docs', app, document, {
      swaggerOptions: {
        persistAuthorization: true,
      },
    });

    const port = process.env.PORT || 8080;
    await app.listen(port);
    
    logger.log(`🚀 Backend server is running on http://localhost:${port}`);
    logger.log(`📚 API Documentation available at http://localhost:${port}/api/docs`);
    logger.log(`🔗 API Base URL: http://localhost:${port}/api`);
  } catch (error) {
    logger.error('Failed to start server:', error);
    process.exit(1);
  }
}

bootstrap();