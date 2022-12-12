echo "start building the backend api"
docker-compose build

echo "pushing image to docker hub"
docker push mikkoe/speedtest-mqtt