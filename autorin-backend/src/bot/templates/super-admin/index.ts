import Handlebars from 'handlebars';

const adminInfoTemplateContent = `👤 {{name}}
📞 Phone number: {{phone}}
🆔 Telegram ID: {{tgId}}`;

export const adminInfo = Handlebars.compile<{
  name: string;
  phone: string;
  tgId: number;
}>(adminInfoTemplateContent);
