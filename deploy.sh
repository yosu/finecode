#!/usr/bin/env bash
set -eu

APP=app-$(date +%Y%m%d-%H%M%S)-$(git log --pretty=format:"%H" -1 | cut -c 1-12)

docker build --platform linux/amd64 -t finecode:latest .
docker create --name dummy finecode:latest
docker cp dummy:/app ~/tmp/$APP
docker rm dummy

cd ~/tmp
tar --format ustar -zcf $APP.tar.gz $APP
rm -r $APP
scp $APP.tar.gz $HOST:~/deploy
rm $APP.tar.gz

ssh $HOST /bin/bash << EOF
cd ~/deploy
tar zxvf $APP.tar.gz
rm $APP.tar.gz
sudo chown -R www-data:www-data $APP
sudo mv $APP /var/www/fine-code.com
cd /var/www/fine-code.com
sudo ln -snf $APP app
sudo systemctl restart fine-code-server
sudo systemctl status fine-code-server
EOF
