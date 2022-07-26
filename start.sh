#!/bin/bash

echo "Server start initiated at $(date)" >> /usr/games/minecraft.log
pidof "bedrock_server" &> /dev/null && exit

/usr/games/minecraft-bootstrap

cd /usr/games/minecraft
sudo -u games -g games -- screen -wipe minecraft &> /dev/null
sudo -u games -g games -- screen -dmS minecraft bash -c './bedrock_server 2>> bedrock-errors.log'

echo "Server started at $(date)" >> /usr/games/minecraft.log
