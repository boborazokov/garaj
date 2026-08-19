import { Scalar, CustomScalar } from '@nestjs/graphql';
import { Kind, ValueNode } from 'graphql';
import { Types } from 'mongoose';

@Scalar('ObjectId')
export class ObjectIdScalar implements CustomScalar<string, Types.ObjectId> {
  description = 'ObjectId custom scalar type for MongoDB';

  parseValue(value: string): Types.ObjectId {
    return new Types.ObjectId(value);
  }

  serialize(value: Types.ObjectId): string {
    return value.toString();
  }

  parseLiteral(ast: ValueNode): Types.ObjectId {
    if (ast.kind === Kind.STRING) {
      return new Types.ObjectId(ast.value);
    }
    throw new Error(
      `ObjectIdScalar can only parse string values, got: ${ast.kind}`,
    );
  }
}
