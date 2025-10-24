import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { S3Client, PutObjectCommand, DeleteObjectCommand, GetObjectCommand } from '@aws-sdk/client-s3';
import { getSignedUrl } from '@aws-sdk/s3-request-presigner';
import { v4 as uuidv4 } from 'uuid';

export interface UploadResult {
  key: string;
  url: string;
  publicUrl: string;
}

@Injectable()
export class StorageService {
  private readonly logger = new Logger(StorageService.name);
  private s3Client: S3Client;
  private bucketName: string;
  private publicUrl: string;
  private isEnabled: boolean;

  constructor(private configService: ConfigService) {
    this.isEnabled = this.configService.get<string>('R2_ENABLED', 'false') === 'true';

    if (!this.isEnabled) {
      this.logger.warn('R2 Storage is disabled. Image uploads will not work.');
      return;
    }

    const accountId = this.configService.get<string>('R2_ACCOUNT_ID');
    const accessKeyId = this.configService.get<string>('R2_ACCESS_KEY_ID');
    const secretAccessKey = this.configService.get<string>('R2_SECRET_ACCESS_KEY');
    this.bucketName = this.configService.get<string>('R2_BUCKET_NAME', 'bepviet-images');
    this.publicUrl = this.configService.get<string>('R2_PUBLIC_URL', '');

    if (!accountId || !accessKeyId || !secretAccessKey) {
      this.logger.error('R2 credentials not configured. Please set R2_ACCOUNT_ID, R2_ACCESS_KEY_ID, and R2_SECRET_ACCESS_KEY');
      this.isEnabled = false;
      return;
    }

    // Cloudflare R2 uses S3-compatible API
    this.s3Client = new S3Client({
      region: 'auto',
      endpoint: `https://${accountId}.r2.cloudflarestorage.com`,
      credentials: {
        accessKeyId,
        secretAccessKey,
      },
    });

    this.logger.log('R2 Storage initialized successfully');
  }

  /**
   * Upload image to R2
   */
  async uploadImage(
    file: Express.Multer.File,
    folder: string = 'community',
  ): Promise<UploadResult> {
    if (!this.isEnabled) {
      throw new Error('R2 Storage is not enabled');
    }

    try {
      // Generate unique filename
      const fileExtension = file.originalname.split('.').pop();
      const fileName = `${uuidv4()}.${fileExtension}`;
      const key = `${folder}/${fileName}`;

      // Upload to R2
      const command = new PutObjectCommand({
        Bucket: this.bucketName,
        Key: key,
        Body: file.buffer,
        ContentType: file.mimetype,
        CacheControl: 'public, max-age=31536000', // 1 year cache
      });

      await this.s3Client.send(command);

      // Generate public URL
      const publicUrl = this.publicUrl 
        ? `${this.publicUrl}/${key}` 
        : `https://${this.bucketName}.r2.dev/${key}`;

      this.logger.log(`Image uploaded successfully: ${key}`);

      return {
        key,
        url: publicUrl,
        publicUrl,
      };
    } catch (error) {
      this.logger.error('Failed to upload image to R2:', error);
      throw new Error(`Failed to upload image: ${error.message}`);
    }
  }

  /**
   * Upload base64 image to R2
   */
  async uploadBase64Image(
    base64Data: string,
    folder: string = 'community',
    mimeType: string = 'image/jpeg',
  ): Promise<UploadResult> {
    if (!this.isEnabled) {
      throw new Error('R2 Storage is not enabled');
    }

    try {
      // Remove data URL prefix if present
      const base64String = base64Data.replace(/^data:image\/\w+;base64,/, '');
      const buffer = Buffer.from(base64String, 'base64');

      // Detect mime type from data URL if present
      const mimeMatch = base64Data.match(/^data:image\/(\w+);base64,/);
      if (mimeMatch) {
        mimeType = `image/${mimeMatch[1]}`;
      }

      // Generate unique filename
      const fileExtension = mimeType.split('/')[1] || 'jpg';
      const fileName = `${uuidv4()}.${fileExtension}`;
      const key = `${folder}/${fileName}`;

      // Upload to R2
      const command = new PutObjectCommand({
        Bucket: this.bucketName,
        Key: key,
        Body: buffer,
        ContentType: mimeType,
        CacheControl: 'public, max-age=31536000',
      });

      await this.s3Client.send(command);

      // Generate public URL
      const publicUrl = this.publicUrl 
        ? `${this.publicUrl}/${key}` 
        : `https://${this.bucketName}.r2.dev/${key}`;

      this.logger.log(`Base64 image uploaded successfully: ${key}`);

      return {
        key,
        url: publicUrl,
        publicUrl,
      };
    } catch (error) {
      this.logger.error('Failed to upload base64 image to R2:', error);
      throw new Error(`Failed to upload base64 image: ${error.message}`);
    }
  }

  /**
   * Delete image from R2
   */
  async deleteImage(key: string): Promise<void> {
    if (!this.isEnabled) {
      this.logger.warn('R2 Storage is not enabled. Skip delete.');
      return;
    }

    try {
      const command = new DeleteObjectCommand({
        Bucket: this.bucketName,
        Key: key,
      });

      await this.s3Client.send(command);
      this.logger.log(`Image deleted successfully: ${key}`);
    } catch (error) {
      this.logger.error(`Failed to delete image from R2: ${key}`, error);
      // Don't throw error, just log it
    }
  }

  /**
   * Get signed URL for private images (optional, for future use)
   */
  async getSignedUrl(key: string, expiresIn: number = 3600): Promise<string> {
    if (!this.isEnabled) {
      throw new Error('R2 Storage is not enabled');
    }

    try {
      const command = new GetObjectCommand({
        Bucket: this.bucketName,
        Key: key,
      });

      return await getSignedUrl(this.s3Client, command, { expiresIn });
    } catch (error) {
      this.logger.error(`Failed to generate signed URL for: ${key}`, error);
      throw new Error(`Failed to generate signed URL: ${error.message}`);
    }
  }

  /**
   * Check if storage is enabled
   */
  isStorageEnabled(): boolean {
    return this.isEnabled;
  }

  /**
   * Extract key from URL
   */
  extractKeyFromUrl(url: string): string | null {
    try {
      if (url.includes(this.publicUrl)) {
        return url.replace(`${this.publicUrl}/`, '');
      }
      
      // Try to extract from r2.dev URL
      const match = url.match(/\.r2\.dev\/(.+)$/);
      return match ? match[1] : null;
    } catch (error) {
      this.logger.error('Failed to extract key from URL:', error);
      return null;
    }
  }
}

