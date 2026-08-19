import { Composer } from 'telegraf';
import { Types } from 'mongoose';
import { SceneContext, WizardContext } from 'telegraf/typings/scenes';
import { Markup } from 'telegraf';

export type AnyContext = WizardContext & SceneContext;

export type ParamSchema = Record<
  string,
  typeof String | typeof Number | typeof Boolean | typeof Types.ObjectId
>;

export type InferSchema<T extends ParamSchema> = {
  [K in keyof T]: T[K] extends StringConstructor
    ? string
    : T[K] extends NumberConstructor
      ? number
      : T[K] extends BooleanConstructor
        ? boolean
        : T[K] extends typeof Types.ObjectId
          ? Types.ObjectId
          : never;
};

export type ActionKeyboardRenderProps<TParams extends ParamSchema> = {
  context: AnyContext;
} & InferSchema<TParams>;

export type PaginationResult = {
  hasNextPage: boolean;
  hasPrevPage: boolean;
};

type BaseActionHandler<TParams extends ParamSchema = {}> = {
  id: string;
  getTitle: (props: ActionKeyboardRenderProps<TParams>) => string;
  handler: (ctx: AnyContext, params: InferSchema<TParams>) => Promise<void>;
  params: TParams;
  matcher: RegExp;
  buildCallback: (params: InferSchema<TParams>) => string;
};

type WithPagination<TParams extends ParamSchema> =
  InferSchema<TParams> extends { page: number }
    ? {
        makePaginationKeyboard: (opts: {
          pagination: PaginationResult;
          params: InferSchema<TParams>;
        }) => Parameters<typeof Markup.inlineKeyboard>[0];
      }
    : {};

export type ActionHandler<TParams extends ParamSchema = {}> =
  BaseActionHandler<TParams> & WithPagination<TParams>;

function compressParams<T extends ParamSchema>(
  schema: T,
  params: InferSchema<T>,
): string {
  return Object.keys(schema)
    .map((key, index) => `${index}=${encodeURIComponent(String(params[key]))}`)
    .join('-');
}

function decompressParams<T extends ParamSchema>(
  schema: T,
  compressed: string,
): Record<string, string> {
  const keys = Object.keys(schema);
  const parts = compressed.split('-');
  const result: Record<string, string> = {};

  parts.forEach((part, index) => {
    const [, value] = part.split('=');
    result[keys[index]] = decodeURIComponent(value);
  });

  return result;
}

export class ActionsHandler {
  static create<T extends ParamSchema>(config: {
    id: string;
    params: T;
    getTitle: (props: ActionKeyboardRenderProps<T>) => string;
    handler: (ctx: AnyContext, params: InferSchema<T>) => Promise<void>;
    paginationEnabled?: InferSchema<T> extends { page: number }
      ? boolean
      : never;
  }): ActionHandler<T> {
    const matcher = new RegExp(`^${config.id}:(.*)?$`);

    const baseHandler = {
      ...config,
      matcher,
      buildCallback: () => {
        throw new Error(
          'buildCallback not initialized. Call initForComposer first.',
        );
      },
    } as unknown as ActionHandler<T>;

    const hasPage = 'page' in config.params && config.params.page === Number;

    if (config.paginationEnabled && hasPage) {
      (baseHandler as any).makePaginationKeyboard = ({
        pagination,
        params,
      }: any) => {
        const { hasNextPage, hasPrevPage } = pagination;
        const { page } = params;
        const buttons: Parameters<typeof Markup.inlineKeyboard>[0] = [];

        if (hasPrevPage) {
          buttons.push({
            text: '◀️',
            callback_data: baseHandler.buildCallback({
              ...params,
              page: page - 1,
            }),
          });
        }

        if (hasNextPage) {
          buttons.push({
            text: '▶️',
            callback_data: baseHandler.buildCallback({
              ...params,
              page: page + 1,
            }),
          });
        }

        return buttons.length ? [buttons] : [];
      };
    }

    return baseHandler;
  }
}

export class ActionsScope<
  THandlers extends Record<string, ActionHandler<any>>,
> {
  private readonly handlers: THandlers;
  private readonly keys: (keyof THandlers)[];

  constructor(handlers: THandlers) {
    this.handlers = handlers;
    this.keys = Object.keys(handlers) as (keyof THandlers)[];
  }

  public size(): number {
    return this.keys.length;
  }

  public initForComposer(composer: Composer<AnyContext>) {
    this.keys.forEach((key) => {
      const handler = this.handlers[key];

      handler.buildCallback = (params: any) => {
        const compressed = compressParams(handler.params, params);
        return `${handler.id}:${compressed}`;
      };

      composer.action(handler.matcher, async (ctx) => {
        try {
          const match = ctx.match;
          if (!match) return;

          const compressed = match[1] || '';
          const rawParams = decompressParams(handler.params, compressed);
          const typed = this.castParams(handler.params, rawParams);
          await handler.handler(ctx, typed);
        } catch (err) {
          console.error(`Action handler failed`, err);
        }
      });
    });
  }

  public makeKeyboard<TKeys extends keyof THandlers>(
    ctx: AnyContext,
    keys: TKeys[],
    params: {
      [K in TKeys]: InferSchema<THandlers[K]['params']>;
    },
  ) {
    return keys.map((key) => {
      const handler = this.handlers[key];
      const props = { context: ctx, ...params[key] };
      return {
        text: handler.getTitle(props),
        callback_data: handler.buildCallback(params[key]),
      };
    });
  }

  public getHandler<K extends keyof THandlers>(key: K): THandlers[K] {
    return this.handlers[key];
  }

  private castParams<T extends ParamSchema>(
    schema: T,
    raw: Record<string, string>,
  ): InferSchema<T> {
    const result = {} as InferSchema<T>;
    for (const key in schema) {
      const type = schema[key];
      const val = raw[key];
      if (type === String) result[key] = val as any;
      else if (type === Number) result[key] = parseFloat(val) as any;
      else if (type === Boolean) result[key] = (val === 'true') as any;
      else if (type === Types.ObjectId)
        result[key] = new Types.ObjectId(val) as any;
      else throw new Error(`Unsupported type for key: ${key}`);
    }
    return result;
  }
}

export function messageEditor<T extends AnyContext>(ctx: T): T['reply'] {
  return (ctx.message ? ctx.reply : ctx.editMessageText).bind(ctx);
}
