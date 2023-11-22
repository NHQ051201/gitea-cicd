docker stop $(docker ps -aq --filter="name=ci_*")
docker rm $(docker ps -aq --filter="name=ci_*")
docker network rm cicd
docker rmi $(docker images | grep 'docker_*')
sudo rm -rf data/drone/* data/drone-agent/* data/gitea/* data/jenkins/* data/jenkins/.* data/postgres data/app.ini