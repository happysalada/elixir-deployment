#!/bin/bash
VERSION=$1
source /etc/union/config/.env
docker login --username happysalada --password REPLACE_WITH_PASSWORD
docker pull "happysalada/union:${VERSION}"
# use 30s to monitor for health to take in account startup time
docker service update --image "happysalada/union:${VERSION}" --update-monitor --detach=false 15s union_web
# on staging use
# docker system prune -f
# to not delete cached images
docker system prune -af
