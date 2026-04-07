import {
  IsString,
  IsNumber,
  IsUrl,
  Min,
  Max,
} from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';
import { Type } from 'class-transformer';

/**
 * Upload Property Gallery Image DTO
 * 
 * Used for POST /properties/:id/gallery
 * Allows sellers to upload property images
 * Supports ordering for gallery display sequence
 */
export class UploadPropertyGalleryDto {
  @ApiProperty({
    description: 'URL where the image is stored (S3, Google Cloud Storage, etc.)',
    example: 'https://s3.amazonaws.com/cleardeed/gallery/property-photo-1.jpg',
  })
  @IsUrl({}, { message: 'image_url must be a valid URL' })
  image_url: string;

  @ApiProperty({
    description: 'Display order in gallery (lower number appears first)',
    type: Number,
    minimum: 1,
    example: 1,
  })
  @Type(() => Number)
  @IsNumber()
  @Min(1, { message: 'display_order must be at least 1' })
  @Max(50, { message: 'display_order must not exceed 50' })
  display_order: number;
}
