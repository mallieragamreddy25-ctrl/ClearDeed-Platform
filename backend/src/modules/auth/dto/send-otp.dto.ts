import { IsString, IsMobilePhone } from 'class-validator';

/**
 * SendOtpDto
 * 
 * Request body for sending OTP to a mobile number
 * Initiates authentication flow
 */
export class SendOtpDto {
  @IsString()
  @IsMobilePhone('en-IN')
  mobile_number: string;
}
