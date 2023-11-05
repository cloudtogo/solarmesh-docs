FROM node:14
WORKDIR /app
COPY . /app
RUN npm config set registry https://registry.npm.taobao.org
RUN npm install netlify-cli -g
RUN mv hugo /usr/local/bin/hugo
CMD ["npm", "run", "serve"]
