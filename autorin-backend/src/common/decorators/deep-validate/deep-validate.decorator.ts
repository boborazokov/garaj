import { Type } from 'class-transformer';
import { ValidateNested } from 'class-validator';

export function DeepValidate(
  ...options: Parameters<typeof ValidateNested>
): PropertyDecorator {
  return (...args) => {
    ValidateNested(...options)(...args);
    Type()(...args);
  };
}
