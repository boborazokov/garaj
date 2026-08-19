import Handlebars from 'handlebars';

const categoryInfoTemplateContent = `📂 Category: {{name}}
🖼️ Icon link: <a href="{{iconUrl}}">click to open</a>`;

export const categoryInfo = Handlebars.compile<{
  name: string;
  iconUrl: string;
}>(categoryInfoTemplateContent);

const advertisementInfoTemplateContent = `📂 Advertisement: <b>{{title}}</b>
🖼️ Banner link: <a href="{{bannerImageUrl}}">click to open</a>`;

export const advertisementInfo = Handlebars.compile<{
  title: string;
  bannerImageUrl: string;
}>(advertisementInfoTemplateContent);
