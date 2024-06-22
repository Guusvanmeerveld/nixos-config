caddy_container_id=$(docker ps | grep intranet-caddy | awk '{print $1;}')
docker exec -w /etc/caddy $caddy_container_id caddy reload
