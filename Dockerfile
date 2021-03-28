# syntax=docker/dockerfile:1.2

FROM google/dart:2.12.2 as dartimage

# dependencies
RUN apt -y update && apt -y install libseccomp2 make gcc procps curl apt-transport-https software-properties-common build-essential

# copy repo
COPY ./ /root/home/data
WORKDIR /root/home/data

# compile project
RUN pub get && /usr/lib/dart/bin/dart compile exe bin/main.dart -o backup_runtime.sh && chmod +x backup_runtime.sh
RUN /root/home/data/backup_runtime.sh prepare --path /root/home/data/.backup.json
#RUN /root/home/data/backup_runtime.sh make --name test
