import { Query, Resolver } from '@nestjs/graphql';
import { Public } from 'src/auth/decorators';
import { ContactInfo } from '../schema';
import { AppSettingsService } from '../service';

@Resolver()
export class AppSettingsResolver {
  constructor(private readonly appSettingsService: AppSettingsService) {}

  @Public()
  @Query(() => ContactInfo)
  contactInfo() {
    return this.appSettingsService.getContactInfo();
  }
}
