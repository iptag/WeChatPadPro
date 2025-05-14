# 使用一个包含 shell 和基本工具的 Linux 基础镜像
FROM ubuntu:latest

RUN echo "deb http://mirrors.aliyun.com/ubuntu/ focal main restricted universe multiverse" > /etc/apt/sources.list && \
    echo "deb http://mirrors.aliyun.com/ubuntu/ focal-updates main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb http://mirrors.aliyun.com/ubuntu/ focal-backports main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb http://mirrors.aliyun.com/ubuntu/ focal-security main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb http://mirrors.aliyun.com/ubuntu/ focal-proposed main restricted universe multiverse" >> /etc/apt/sources.list


# 安装 jq (用于更安全的 JSON 处理)
RUN apt-get update && apt-get install -y jq && rm -rf /var/lib/apt/lists/*

# 设置工作目录
WORKDIR /app

# 复制 stay 可执行文件
# 假设 stay 可执行文件在项目根目录
COPY stay .
RUN chmod +x stay

# 复制 assets 目录
COPY ./assets ./assets

COPY ./static ./static

# 复制配置生成脚本
COPY generate_config.sh .

# 使脚本可执行
RUN chmod +x generate_config.sh

# 设置容器启动时执行的命令
# 脚本会先生成配置文件，然后执行 stay
ENTRYPOINT ["./generate_config.sh"]

# 暴露应用程序端口 (根据 setting.json 中的 port: "8848")
EXPOSE 8848
