# WeChatPadPro-docker

这是一个基于 Docker 的 WeChatPadPro 部署方案。通过 Docker Compose，您可以轻松地构建和运行包含应用、Redis 和 MySQL 的完整环境。

## 项目结构

-   [`docker-compose.yml`](docker-compose.yml): 定义了应用、Redis 和 MySQL 服务。
-   [`Dockerfile`](Dockerfile): 构建应用服务的 Docker 镜像。
-   [`generate_config.sh`](generate_config.sh): 应用启动前用于生成配置的脚本。
-   `assets/`: 存放应用所需的资源文件。
-   `static/`: 存放静态文件，如文档、Swagger UI 等。
-   `mysql/`: 存放 MySQL 相关文件，包括初始化脚本和数据卷。
-   `stay`: 应用的可执行文件。

## 环境要求

在开始之前，请确保您的系统已安装以下软件：

-   [Docker](https://www.docker.com/get-started)
-   [Docker Compose](https://docs.docker.com/compose/install/)

## 构建和运行

请按照以下步骤构建和运行项目：

1.  **克隆仓库**

    如果您还没有克隆本项目，请使用以下命令：

    ```bash
    git clone https://github.com/xiamuceer-j/WeChatPadPro.git
    cd WeChatPadPro
    ```

2.  **构建和启动容器**

    在项目根目录下，运行以下命令使用 Docker Compose 构建镜像并启动所有服务：

    ```bash
    docker-compose up -d --build
    ```

    -   `-d`: 在后台模式下运行容器。
    -   `--build`: 在启动前构建镜像。

3.  **检查服务状态**

    运行以下命令检查容器是否正常运行：

    ```bash
    docker-compose ps
    ```

    您应该看到 `app`, `redis`, 和 `mysql` 服务都在运行中。

4.  **访问应用**

    应用将在本地的 8059 端口上运行。您可以通过浏览器访问 `http://localhost:8059` 来使用应用。

## 配置

应用的一些配置可以通过 [`docker-compose.yml`](docker-compose.yml) 文件中的环境变量进行修改：

-   `REDIS_HOST`: Redis 服务地址 (默认为 `redis`)
-   `REDIS_PORT`: Redis 端口 (默认为 `6379`)
-   `REDIS_PASS`: Redis 密码
-   `MYSQL_CONNECT_STR`: MySQL 连接字符串 (例如: `root:password@tcp(mysql:3306)/database?charset=utf8mb4&parseTime=true&loc=Local`)
-   `PORT`: 应用监听的端口 (默认为 `8059`)
-   `ADMIN_KEY`: 管理员密钥

如果您需要修改这些配置，请编辑 [`docker-compose.yml`](docker-compose.yml) 文件后，重新运行 `docker-compose up -d --build`。

## 注意事项

-   首次运行时，Docker Compose 会创建数据卷来持久化 Redis 和 MySQL 的数据。数据将分别存储在 `./redis/data` 和 `./mysql/data` 目录下。
-   MySQL 数据库会在首次启动时执行 `./mysql/mysql-init` 目录下的初始化脚本。请确保您的初始化脚本正确无误。
-   `stay` 可执行文件需要放置在项目根目录下。
-   `assets` 和 `static` 目录需要包含应用所需的所有文件。
