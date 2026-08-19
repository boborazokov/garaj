import { ModelDefinition, SchemaFactory } from '@nestjs/mongoose';
import { COLLECTIONS } from 'src/constants';
import { User } from '../schema';
import * as bcrypt from 'bcrypt';
import * as mongoosePaginate from 'mongoose-paginate-v2';

export const userSchema = SchemaFactory.createForClass(User);

userSchema.plugin(mongoosePaginate);

userSchema.pre('save', async function () {
  if (this.isModified('password')) {
    this.password = await bcrypt.hash(this.password, 10);
  }
});

export const UserModel: ModelDefinition = {
  name: COLLECTIONS.USERS,
  schema: userSchema,
};
