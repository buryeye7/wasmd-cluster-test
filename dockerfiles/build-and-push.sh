#!/bin/bash

cd friday-seed
pwd
docker build --no-cache --tag buryeye7/friday-seed:latest .
docker push buryeye7/friday-seed:latest

cd ..
cd friday-node
pwd
docker build --no-cache --tag buryeye7/friday-node:latest .
docker push buryeye7/friday-node:latest

