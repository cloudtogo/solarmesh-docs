FROM registry.cn-shenzhen.aliyuncs.com/solarmesh/node:14
WORKDIR /app
COPY . /app
RUN npm cache clean --force
RUN npm config set registry https://registry.npmmirror.com
RUN npm install netlify-cli -g --unsafe-perm=true --allow-root
RUN mv hugo /usr/local/bin/hugo
CMD ["npm", "run", "serve"]
