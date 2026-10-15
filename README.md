# sky-take-out

苍穹外卖后端项目。

## Docker 与 Docker Compose

### 文件用途

- `Dockerfile`：把多模块 Maven 项目编译成可执行 JAR，并制作只包含 JRE 和应用 JAR 的运行镜像。其他机器不需要预装 Maven 或 JDK。
- `compose.yaml`：统一描述应用、MySQL、Redis、容器网络、端口、环境变量、健康检查、启动顺序和数据卷。
- `.dockerignore`：阻止 `.env`、Git、IDE 配置和本地构建产物进入镜像。
- `docker/mysql/init`：MySQL 数据卷首次创建时执行的建表和脱敏演示数据。

项目保持 Spring Boot 2.7.3，不使用 Spring Boot 3.1 才提供的
`spring-boot-docker-compose` 开发期依赖。Compose 的生命周期由
`docker compose` 命令直接管理。

### 准备配置

复制 `.env.example` 为 `.env`，填写数据库密码、JWT 密钥和需要使用的第三方服务配置。
`.env` 只保存在本机，不应提交到 Git。

Compose 默认映射以下宿主机端口：

| 服务 | 宿主机端口 | 容器端口 |
| --- | ---: | ---: |
| 后端应用 | 8080 | 8080 |
| MySQL | 3307 | 3306 |
| Redis | 6380 | 6379 |

如端口冲突，可在本地 `.env` 中覆盖：

```dotenv
SKY_APP_HOST_PORT=8080
SKY_MYSQL_HOST_PORT=3307
SKY_REDIS_HOST_PORT=6380
```

### 常用命令

验证 Compose 配置：

```powershell
docker compose config --quiet
```

构建镜像：

```powershell
docker compose build
```

启动应用、MySQL 和 Redis：

```powershell
docker compose up -d
```

查看服务状态：

```powershell
docker compose ps
```

查看应用日志：

```powershell
docker compose logs -f app
```

重新构建并启动应用：

```powershell
docker compose up -d --build app
```

停止容器但保留 MySQL 和 Redis 数据：

```powershell
docker compose down
```

> **警告**
>
> `docker compose down -v` 会永久删除 MySQL 和 Redis 数据卷。日常停止服务不要使用
> `-v`；只有明确需要重置全部容器数据时才执行。

### 初始化数据

MySQL 官方镜像仅在数据卷第一次创建时执行 `docker/mysql/init` 中的 SQL：

1. `01-schema.sql`：全部业务表结构。
2. `02-demo-catalog.sql`：分类、菜品、口味和套餐演示数据。
3. `03-demo-admin.sql`：脱敏管理员账号。

演示管理员：

```text
用户名：admin
密码：123456
```

用户、地址、购物车、订单和订单明细不会导入真实数据。
