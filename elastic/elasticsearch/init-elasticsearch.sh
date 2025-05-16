#!/bin/bash
set -e  # Выход при ошибке

ES_URL="http://localhost:9200"  # Исправлено на HTTP

echo "Ожидание запуска Elasticsearch..."
until curl -s -u elastic:${ELASTIC_PASSWORD} ${ES_URL} >/dev/null; do
  sleep 5
done

echo "Creating API key..."
response=$(curl -s -u elastic:${ELASTIC_PASSWORD} -X POST "${ES_URL}/_security/api_key" \
  -H "Content-Type: application/json" -d'
{
  "name": "app-key",
  "role_descriptors": {
    "springboot-app-role": {
      "cluster": ["monitor"],
      "indices": [
        {
          "names": ["my-app-*"],
          "privileges": ["create_index", "write", "read", "manage"]
        }
      ]
    }
  }
}')

# Сохраняем ключ в файл внутри контейнера (пробуем два пути)
API_KEY_PATH="/usr/share/elasticsearch/config/api-key"
mkdir -p $(dirname "$API_KEY_PATH")  # Создаем директорию, если её нет
echo "$api_key" > "$API_KEY_PATH"
chmod 640 "$API_KEY_PATH"  # Даём права на чтение владельцу и группе

# Дублируем ключ в volume, который подключён к хосту (если нужно)
HOST_KEY_PATH="/usr/share/elasticsearch/data/api-key"
echo "$api_key" > "$HOST_KEY_PATH"

# Выводим ключ в логи (чтобы можно было скопировать вручную)
echo "=============================================="
echo "API Key для Spring Boot (скопируйте это значение):"
echo "$api_key"
echo "=============================================="

# Проверяем, что ключ работает
echo "Проверка API key..."
curl -s -H "Authorization: ApiKey $api_key" "$ES_URL/_cluster/health?pretty"
