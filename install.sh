#!/bin/bash

# get information for Gitea installation
echo "----- Gitea installation -----"
echo "Please provide some information for the setup"
echo "----- Database infomation -----"
printf "Username for database: "
read -r DBUSERNAME
export DBUSERNAME="$DBUSERNAME"
printf "Password for database: "
read -r -s DBPASSWORD
echo ""
export DBPASSWORD="$DBPASSWORD"
echo ""

echo "----- Admin information -----"
printf "Gitea admin username: "
read -r GITUSERNAME
printf "Gitea admin password: "
read -r -s GITPASSWORD
echo ""
printf "Gitea admin email (please provide right email format): "
read -r GITEMAIL
echo ""
export IPADDR=$(hostname -I | awk '{print $1}')

cat ./gitea/app-default.ini > ./gitea/app.ini
sed -i "s/\$IPADDR/$IPADDR/g" "./gitea/app.ini"
cp gitea/app.ini data/app.ini
cat ./docker-compose-gitea-default.yaml > ./install/docker-compose-gitea.yaml
sed -i "s/\$DBUSERNAME/$DBUSERNAME/g" "./install/docker-compose-gitea.yaml"
sed -i "s/\$DBPASSWORD/$DBPASSWORD/g" "./install/docker-compose-gitea.yaml"
sed -i "s/\$IPADDR/$IPADDR/g" "./install/docker-compose-gitea.yaml"

# install gitea
docker-compose -f ./install/docker-compose-gitea.yaml up -d
# shred -u install/docker-compose-gitea.yaml gitea/app.ini
sleep 5
docker exec -it -u git ci_gitea bash -c "gitea admin user create --username $GITUSERNAME --password $GITPASSWORD --email $GITEMAIL --admin"

echo ""
echo "Gitea has been installed please log in with the admin account and create new OAuth2 Application to get information for drone CI installation. 
-- Following this link: http://$IPADDR:3000/user/settings/applications
"

# get information for drone ci installation
echo "----- CI server installation -----"
echo "Please provide some information for the setup"
printf "Gitea client ID: "
read -r GITEAID
export GITEAID="$GITEAID"
printf "Gitea client SECRET: "
read -r -s GITEASECRET
export GITEASECRET="$GITEASECRET"
echo ""
printf "CI server IP: "
read -r CI_IP
export CI_IP="$CI_IP"
DRONE_SECRET=$(openssl rand -hex 16)
echo ""

cat ./docker-compose-ci-server-default.yaml > ./install/docker-compose-ci-server.yaml
sed -i "s/\$GITEAID/$GITEAID/g" "./install/docker-compose-ci-server.yaml"
sed -i "s/\$GITEASECRET/$GITEASECRET/g" "./install/docker-compose-ci-server.yaml"
sed -i "s/\$IPADDR/$IPADDR/g" "./install/docker-compose-ci-server.yaml"
sed -i "s/\$CI_IP/$CI_IP/g" "./install/docker-compose-ci-server.yaml"
sed -i "s/\$DRONE_SECRET/$DRONE_SECRET/g" "./install/docker-compose-ci-server.yaml"

#install CI server
docker-compose -f ./install/docker-compose-ci-server.yaml up -d
# shred -u install/docker-compose-ci-server.yaml
sleep 20
echo "Drone has been created please following this link: http://$CI_IP:8001"
echo "Jenkins has been created please following this link: http://$CI_IP:8081"

# clean up after installation
echo "Finishing installation"