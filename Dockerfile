# 构建阶段
FROM node:20-alpine as build-stage

WORKDIR /app

# 设置 npm 镜像源并安装 pnpm
RUN npm config set registry https://registry.npmmirror.com \
  && npm install -g pnpm

# 复制配置文件并安装依赖
COPY .npmrc package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile

# 复制项目源代码并构建
COPY . .
RUN pnpm build

# 生产阶段
FROM nginx:stable-alpine as production-stage

# 将构建结果复制到 Nginx 服务目录
COPY --from=build-stage /app/dist /usr/share/nginx/html

# 暴露 80 端口
EXPOSE 80

# 启动 Nginx
CMD ["nginx", "-g", "daemon off;"]
