#!/bin/bash

# 使用环境变量，如果未设置则提供默认值
REDIS_HOST=${REDIS_HOST:-"127.0.0.1"}
REDIS_PORT=${REDIS_PORT:-"6379"}
REDIS_PASS=${REDIS_PASS:-""}
MYSQL_CONNECT_STR=${MYSQL_CONNECT_STR:-"user:password@tcp(127.0.0.1:3306)/dbname?charset=utf8mb4&parseTime=true&loc=Local"}
PORT=${PORT:-"8059"}
ADMIN_KEY=${ADMIN_KEY:-"stay33"}

# --- Wait for MySQL to be ready ---
echo "Waiting for MySQL to be ready..."

sleep 15
# --- End Wait for MySQL ---


# 配置文件的路径
CONFIG_FILE="./assets/setting.json"
TEMP_CONFIG_FILE="/tmp/setting.json" # 使用临时文件避免读写同一文件的问题

# 复制原始配置文件到临时文件
if [ -f "$CONFIG_FILE" ]; then
    cp "$CONFIG_FILE" "$TEMP_CONFIG_FILE"
else
    echo "错误：找不到配置文件 $CONFIG_FILE！"
    exit 1
fi

# 检查是否安装了 jq，优先使用 jq 进行 JSON 操作，更安全
if command -v jq &> /dev/null
then
    echo "使用 jq 进行 JSON 操作。"
    jq \
        --arg redis_host "$REDIS_HOST" \
        --arg redis_port "$REDIS_PORT" \
        --arg redis_pass "$REDIS_PASS" \
        --arg mysql_conn_str "$MYSQL_CONNECT_STR" \
        --arg app_port "$PORT" \
        --arg admin_key "$ADMIN_KEY" \
        '.redisConfig.Host = $redis_host | .redisConfig.Port = ($redis_port | tonumber) | .redisConfig.Pass = $redis_pass | .mySqlConnectStr = $mysql_conn_str | .port = $app_port | .adminKey = $admin_key' \
        "$TEMP_CONFIG_FILE" > "$CONFIG_FILE"
    if [ $? -ne 0 ]; then
        echo "错误：jq 修改配置文件失败！"
        exit 1
    fi
else
    echo "未找到 jq，回退到 sed。请确保您的环境变量不包含会破坏 sed 的特殊字符。"
    # 读取原始配置文件内容
    CONFIG_CONTENT=$(cat "$TEMP_CONFIG_FILE")

    # 使用 sed 替换值。请注意 sed 中的特殊字符处理。
    # 对于 JSON 字符串值，确保引号正确处理。
    # 对于数字，不需要引号。

    # 转义 sed 替换字符串中的特殊字符
    REDIS_HOST_ESCAPED=$(echo "$REDIS_HOST" | sed 's/[\/&]/\\&/g')
    REDIS_PASS_ESCAPED=$(echo "$REDIS_PASS" | sed 's/[\/&]/\\&/g')
    MYSQL_CONNECT_STR_ESCAPED=$(echo "$MYSQL_CONNECT_STR" | sed 's/[\/&]/\\&/g')
    PORT_ESCAPED=$(echo "$PORT" | sed 's/[\/&]/\\&/g')
    ADMIN_KEY_ESCAPED=$(echo "$ADMIN_KEY" | sed 's/[\/&]/\\&/g')

    # 替换 Redis Host
    CONFIG_CONTENT=$(echo "$CONFIG_CONTENT" | sed "s/\"Host\": \".*\"/\"Host\": \"$REDIS_HOST_ESCAPED\"/")
    # 替换 Redis Port (假设它是数字，没有引号)
    CONFIG_CONTENT=$(echo "$CONFIG_CONTENT" | sed "s/\"Port\": [0-9]*/\"Port\": $REDIS_PORT/")
    # 替换 Redis Pass
    CONFIG_CONTENT=$(echo "$CONFIG_CONTENT" | sed "s/\"Pass\": \".*\"/\"Pass\": \"$REDIS_PASS_ESCAPED\"/")
    # 替换 MySQL 连接字符串
    # 使用 '#' 作为 sed 的分隔符
    CONFIG_CONTENT=$(echo "$CONFIG_CONTENT" | sed "s#\"mySqlConnectStr\": \".*\"#\"mySqlConnectStr\": \"$MYSQL_CONNECT_STR_ESCAPED\"#")
    # 替换 Port
    CONFIG_CONTENT=$(echo "$CONFIG_CONTENT" | sed "s/\"port\": \".*\"/\"port\": \"$PORT_ESCAPED\"/")
    # 替换 AdminKey
    CONFIG_CONTENT=$(echo "$CONFIG_CONTENT" | sed "s/\"adminKey\": \".*\"/\"adminKey\": \"$ADMIN_KEY_ESCAPED\"/")

    # 将修改后的内容写回配置文件
    echo "$CONFIG_CONTENT" > "$CONFIG_FILE"
fi

# 清理临时文件
rm "$TEMP_CONFIG_FILE"

echo "--- Modified setting.json content ---"
cat "$CONFIG_FILE"
echo "-------------------------------------"

# 执行主应用程序
exec ./stay