import { Args, Context, Mutation, Resolver } from '@nestjs/graphql';
import { ContextType } from 'src/auth/interfaces';
import { assertAuthenticated } from 'src/auth/utils/authenticated-context';
import { UseAuth, UseOptionalAuth } from 'src/auth/useAuth';
import { TrackActivityArgs } from '../dto/track-activity.input';
import { ActivityService } from '../service/activity.service';

@Resolver()
export class ActivityResolver {
  constructor(private readonly activityService: ActivityService) {}

  @UseOptionalAuth()
  @Mutation(() => Boolean)
  trackActivity(
    @Args() args: TrackActivityArgs,
    @Context() context: ContextType,
  ) {
    let metadata: Record<string, unknown> = {};
    if (args.metadata) {
      try {
        metadata = JSON.parse(args.metadata) as Record<string, unknown>;
      } catch {
        metadata = { raw: args.metadata };
      }
    }

    return this.activityService
      .track({
        userId: context.userId,
        type: args.type,
        entityId: args.entityId,
        metadata,
      })
      .then(() => true);
  }

  @UseAuth()
  @Mutation(() => Boolean)
  trackActivityAuth(
    @Args() args: TrackActivityArgs,
    @Context() context: ContextType,
  ) {
    const { userId } = assertAuthenticated(context);
    let metadata: Record<string, unknown> = {};
    if (args.metadata) {
      try {
        metadata = JSON.parse(args.metadata) as Record<string, unknown>;
      } catch {
        metadata = { raw: args.metadata };
      }
    }

    return this.activityService
      .track({
        userId,
        type: args.type,
        entityId: args.entityId,
        metadata,
      })
      .then(() => true);
  }
}
