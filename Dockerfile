FROM registry.cn-shenzhen.aliyuncs.com/solarmesh/node:16

WORKDIR /app
COPY . /app

# 更换为阿里云的 Debian 镜像源
RUN sed -i 's/http:\/\/deb.debian.org\/debian/http:\/\/mirrors.aliyun.com\/debian/g' /etc/apt/sources.list \
    && sed -i 's/http:\/\/security.debian.org\/debian-security/http:\/\/mirrors.aliyun.com\/debian-security/g' /etc/apt/sources.list

# 更新软件包索引并安装所需依赖
RUN apt-get update && apt-get install -y \
    build-essential \
    libcairo2-dev \
    libpango1.0-dev \
    libjpeg-dev \
    libgif-dev \
    librsvg2-dev \
    && rm -rf /var/lib/apt/lists/*

# 清理 npm 缓存
RUN npm cache clean --force

# 设置 npm 镜像源
RUN npm config set registry https://registry.npmmirror.com

# 安装 netlify-cli
RUN npm install netlify-cli@16.0.0 -g --unsafe-perm=true --allow-root

# 下载并安装 Hugo
#RUN wget https://github.com/gohugoio/hugo/releases/download/v0.89.4/hugo_extended_0.89.4_Linux-64bit.tar.gz && \
#   tar -zxvf hugo_extended_0.89.4_Linux-64bit.tar.gz -C /usr/local/bin && \
#    rm hugo_extended_0.89.4_Linux-64bit.tar.gz

RUN mv hugo /usr/local/bin/hugo

CMD ["npm", "run", "serve"]
