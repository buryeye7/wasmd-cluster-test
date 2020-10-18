#!/bin/bash

docker build --no-cache --tag buryeye7/friday-base:latest .
docker push buryeye7/friday-base:latest
