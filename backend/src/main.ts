import 'reflect-metadata';
import { NestFactory } from '@nestjs/core';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';
import { AppModule } from './app.module';
import { ValidationPipe } from '@nestjs/common';
import * as dotenv from 'dotenv';

/**
 * NestJS Application Bootstrap
 * 
 * Entry point for the ClearDeed backend API
 * 
 * Initializes:
 * 1. NestJS application
 * 2. Global validation pipe for DTOs
 * 3. Swagger/OpenAPI documentation
 * 4. CORS configuration
 * 5. Global prefix (/v1)
 * 6. HTTP error handling
 */
async function bootstrap() {
  // Load environment variables
  dotenv.config();

  const app = await NestFactory.create(AppModule);

  // Global prefix
  app.setGlobalPrefix('v1');

  // Enable CORS
  app.enableCors({
    origin: process.env.CORS_ORIGIN || '*',
    credentials: true,
  });

  // Global validation pipe for DTO validation
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
      transformOptions: {
        enableImplicitConversion: true,
      },
    }),
  );

  // Swagger documentation
  const config = new DocumentBuilder()
    .setTitle('ClearDeed API')
    .setDescription(
      'End-to-end verified real estate & investment execution platform API',
    )
    .setVersion('1.0.0')
    .addBearerAuth()
    .addServer('http://localhost:3000/v1', 'Development')
    .addServer('https://api.cleardeed.com/v1', 'Production')
    .addTag('Authentication', 'OTP-based authentication endpoints')
    .addTag('Profile', 'User profile management')
    .addTag('Properties', 'Property listings and management')
    .build();

  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup('api/docs', app, document);

  const port = process.env.PORT || 3000;
  const env = process.env.NODE_ENV || 'development';

  await app.listen(port, () => {
    console.log(`
    ╔════════════════════════════════════════════════════════════╗
    ║         ClearDeed API Server Started Successfully           ║
    ║═══════════════════════════════════════════════════════════ ║
    ║ Environment: ${env.toUpperCase().padEnd(43)} ║
    ║ Port: ${port.toString().padEnd(48)} ║
    ║ Swagger Docs: http://localhost:${port}/api/docs               ║
    ║ API Base URL: http://localhost:${port}/v1                   ║
    ╚════════════════════════════════════════════════════════════╝
    `);
  });
}

bootstrap().catch((error) => {
  console.error('Failed to start application:', error);
  process.exit(1);
});
