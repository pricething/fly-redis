#!/bin/sh

set -e

sysctl vm.overcommit_memory=1 || true
sysctl net.core.somaxconn=16484 || true

PW_ARG=""
if [[ ! -z "${REDIS_PASSWORD}" ]]; then
  PW_ARG="--requirepass $REDIS_PASSWORD"
fi

# Set maxmemory-policy to 'allkeys-lru' for caching servers that should always evict old keys
: ${MAXMEMORY_POLICY:="volatile-lru"}
: ${APPENDONLY:="no"}
: ${FLY_VM_MEMORY_MB:=256}
if [ "${NOSAVE}" = "" ]; then
  : ${SAVE:="3600 1 300 100 60 10000"}
fi
# Set maxmemory to 90% of available memory
MAXMEMORY=$(($FLY_VM_MEMORY_MB * 90 / 100))

# set an appropriate umask (if one isn't set already)
# - https://github.com/docker-library/redis/issues/305
# - https://github.com/redis/redis/blob/bb875603fb7ff3f9d19aad906bd45d7db98d9a39/utils/systemd-redis_server.service#L37
um="$(umask)"
if [ "$um" = '0022' ]; then
  umask 0077
fi

redis-server $PW_ARG \
  --dir /data/ \
  --maxmemory "${MAXMEMORY}mb" \
  --maxmemory-policy $MAXMEMORY_POLICY \
  --appendonly $APPENDONLY \
  --save "$SAVE" \
  --maxclients 100
