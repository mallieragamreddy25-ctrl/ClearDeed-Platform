import { IsString, IsMobilePhone, Length } from 'class-validator';

/**
 * VerifyOtpDto
 * 
 * Request body for verifying OTP
 * Completes authentication and generates JWT token
 */
export class VerifyOtpDto {
  @IsString()
  @IsMobilePhone('en-IN')
  mobile_number: string;

  @IsString()
  @Length(4, 6)
  otp: string;
}
