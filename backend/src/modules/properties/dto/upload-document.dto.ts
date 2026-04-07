import {
  IsString,
  IsNumber,
  IsEnum,
  IsUrl,
  Min,
  Max,
} from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

/**
 * Upload Property Document DTO
 * 
 * Used for POST /properties/:id/documents
 * Allows sellers to upload verification documents
 */
export class UploadPropertyDocumentDto {
  @ApiProperty({
    enum: ['title_deed', 'survey', 'tax_proof', 'approval_letter'],
    description: 'Type of document being uploaded',
    example: 'title_deed',
  })
  @IsEnum(['title_deed', 'survey', 'tax_proof', 'approval_letter'], {
    message: 'Document type must be one of: title_deed, survey, tax_proof, approval_letter',
  })
  document_type: string;

  @ApiProperty({
    description: 'URL where the document is stored (S3, Google Cloud Storage, etc.)',
    example: 'https://s3.amazonaws.com/cleardeed/docs/document-123.pdf',
  })
  @IsUrl({}, { message: 'file_url must be a valid URL' })
  file_url: string;
}
