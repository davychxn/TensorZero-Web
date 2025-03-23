REM Pull required containers
ECHO Uncomment below hidden lines to pull containers
REM docker pull clickhouse/clickhouse-server
REM docker pull clickhouse/clickhouse-client
REM docker pull tensorzero/gateway

REM Load User Settings
call ./config/user_settings.cmd

REM Create network for inter-containers requests
ECHO Uncomment below hidden line to create network
REM docker network create %YOUR_NETWORD_NAME%

REM Start clickhouse-server
REM Might need extra effort to make it working, I struggled here a few hours
docker run -d --name clickhouse-server --network %YOUR_NETWORD_NAME% -e CLICKHOUSE_DB="%YOUR_DB_NAME%" -e CLICKHOUSE_USER="%YOUR_DB_USER_NAME%" -e CLICKHOUSE_DEFAULT_ACCESS_MANAGEMENT=1 -e CLICKHOUSE_PASSWORD="%YOUR_DB_PASSWORD%" -p 8123:8123 -p 9000:9000/tcp clickhouse/clickhouse-server

ECHO Waiting for clickhouse-server to load...
@ping -n 10 127.0.0.1 > nul

ECHO Uncomment below hidden line to check Clickhouse connectivity
REM docker exec -it clickhouse-server clickhouse-client --user %YOUR_DB_USER_NAME%

REM Start tensorzero/gateway
docker run -d --name tensorzero-gateway --network %YOUR_NETWORD_NAME% -p 3000:3000  -v "%YOUR_MOUNT_PATH%:/app/config:ro" -e TENSORZERO_CLICKHOUSE_URL="http://%YOUR_DB_USER_NAME%:%YOUR_DB_PASSWORD%@clickhouse-server:8123/tensorzero" -e AZURE_OPENAI_API_KEY="%AZURE_SERVICE_KEY%" tensorzero/gateway --config-file "/app/config/tensorzero.toml"

REM Start Proxy Server
call ./src/start_proxy_server.cmd
