## simple cache layer using an nginx proxy



1. build
docker build . -t nginx-cache:latest --build-arg REMOTE_HOST=10.0.0.1


2. run
docker run -p80:80 -d --cpus=".5" --memory="128m" --memory-swap="-1" nginx-cache 