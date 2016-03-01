#!/bin/bash 


docker rm -f restomm

VERSION=7.5.0.800

docker build -t restcomm:$VERSION .

docker tag -f restcomm:$VERSION hamsterksu/restcomm:$VERSION

docker push hamsterksu/restcomm:$VERSION
