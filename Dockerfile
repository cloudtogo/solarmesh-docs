FROM registry.cn-shenzhen.aliyuncs.com/solarmesh/node:16
WORKDIR /app
COPY . /app
RUN apt-get update && apt-get install -y build-essential libcairo2-dev libpango1.0-dev libjpeg-dev libgif-dev librsvg2-dev
RUN npm cache clean --force
RUN npm config set registry https://registry.npmmirror.com
RUN npm install netlify-cli@16.0.0 -g --unsafe-perm=true --allow-root
RUN wget https://github.com/gohugoio/hugo/releases/download/v0.89.4/hugo_extended_0.89.4_Linux-64bit.tar.gz && \
    tar -zxvf hugo_extended_0.89.4_Linux-64bit.tar.gz -C /usr/local/bin && \
    rm hugo_extended_0.89.4_Linux-64bit.tar.gz
CMD ["npm", "run", "serve"]
