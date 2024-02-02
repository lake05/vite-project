FROM node:alpine as builder 

WORKDIR /app 

# 单独分离 package.json，是为了安装依赖可最大限度利用缓存
COPY package.json package-lock.json ./
# 此时，yarn 可以利用缓存，如果 yarn.lock 内容没有变化，则不会重新依赖安装
RUN npm install --no-package-lock

# 单独分离 public/src，是为了避免 COPY . /code 时，因为 Readme/nginx.conf 的更改避免缓存生效
# 也是为了 npm run build 可最大限度利用缓存
COPY . ./
RUN npm run build

# 选择更小体积的基础镜像
FROM nginx:alpine
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=builder ./dist /usr/share/nginx/html