import { Scalar, CustomScalar } from '@nestjs/graphql';
import { Kind, ValueNode } from 'graphql';
import { Types } from 'mongoose';

@Scalar('ObjectId')
export class ObjectIdScalar
  implements CustomScalar<string | null, Types.ObjectId | null>
{
  description = 'ObjectId custom scalar type for MongoDB';

  parseValue(value: unknown): Types.ObjectId | null {
    if (value == null || value === '') return null;
    if (typeof value !== 'string' || !Types.ObjectId.isValid(value)) {
      throw new Error(`Invalid ObjectId value: ${String(value)}`);
    }
    return new Types.ObjectId(value);
  }

  serialize(value: Types.ObjectId | string | null | undefined): string | null {
    if (value == null) return null;
    return String(value);
  }

  parseLiteral(ast: ValueNode): Types.ObjectId | null {
    if (ast.kind === Kind.NULL) return null;
    if (ast.kind === Kind.STRING) {
      if (!ast.value || !Types.ObjectId.isValid(ast.value)) {
        throw new Error(`Invalid ObjectId literal: ${ast.value}`);
      }
      return new Types.ObjectId(ast.value);
    }
    throw new Error(
      `ObjectIdScalar can only parse string values, got: ${ast.kind}`,
    );
  }
}
