#!/bin/sh
set -eu

umask 077

# 优先使用挂载的配置文件（本地 docker-compose 场景）。
if [ -f "${GROK2API_CONFIG_SOURCE}" ]; then
  cp "${GROK2API_CONFIG_SOURCE}" /app/config.yaml
else
  # 无挂载文件时，允许通过环境变量注入配置内容（Render 等无 bind mount 的平台）。
  if [ -n "${GROK2API_CONFIG_BASE64:-}" ]; then
    printf '%s' "${GROK2API_CONFIG_BASE64}" | base64 -d > /app/config.yaml
  elif [ -n "${GROK2API_CONFIG_CONTENT:-}" ]; then
    printf '%s' "${GROK2API_CONFIG_CONTENT}" > /app/config.yaml
  else
    echo "missing config: ${GROK2API_CONFIG_SOURCE}" >&2
    echo "mount config.yaml to /run/grok2api/config.yaml, or set GROK2API_CONFIG_BASE64 / GROK2API_CONFIG_CONTENT" >&2
    exit 1
  fi
fi
chown grok2api:grok2api /app/config.yaml
chmod 0600 /app/config.yaml

exec su-exec grok2api:grok2api "$@"

