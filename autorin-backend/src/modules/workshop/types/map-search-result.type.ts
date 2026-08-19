import { Field, ObjectType } from '@nestjs/graphql';
import { Part } from 'src/modules/part/schema';
import { AutoService } from 'src/modules/service/schema/service.schema';
import { Workshop } from 'src/modules/workshop/schema/workshop.schema';

@ObjectType()
export class MapSearchResult {
  @Field(() => [Workshop])
  workshops: Workshop[];

  @Field(() => [AutoService])
  services: AutoService[];

  @Field(() => [Part])
  parts: Part[];
}
