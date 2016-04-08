#!/bin/bash

BASEDIR=/opt/Restcomm-JBoss-AS7

if [ -n "USE_EXTERNAL_MEDIASERVER" ]; then
  echo "Reconfigure to use external mediaserver"
  
  # disable mediaserver start
  FILE=$BASEDIR/bin/restcomm/start-restcomm.sh
  sed -i 's/^startMediaServer$/#startMediaServer/' $FILE
fi