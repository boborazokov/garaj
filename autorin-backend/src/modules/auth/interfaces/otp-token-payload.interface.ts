import { SignUpInput } from '../dto';

export interface OtpTokenPayload {
  code: string;
  data: SignUpInput;
}
