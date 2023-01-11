echo "start building the speedtest image"
docker-compose build

echo "pushing image to docker hub"
docker push mikkoe/speedtest-mqtt