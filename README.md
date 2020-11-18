# dcache

delete cache utility with dart language.

# docker

Create a Docker image on your system

$ docker build -t dcache .

Line 30 of bin/server.dart causes the server to exit as soon as it is ready to listen for requests.

$ docker run -d -it -p 8088:8088 --name dcache dcache

Time how long it takes to lauch a server

$ time docker run -it -p 8088:8088 --name dcache dcache

The server using default root changed from invalid DCACHE_ROOT

$ touch dcache.env <br/>
$ vi dcache.env <br/>
DCACHE_PORT=8086 <br/>
DCACHE_COUNT=5 <br/>
DCACHE_ROOT=/app/dcache/mounted <br/>
DCACHE_PRINT_ALL=true <br/>

$ docker run -d -it -p 8088:8086 --env-file=dcache.env --name dcache dcache

The server using volume mounted DCACHE_ROOT for ~/mounted

$ mkdir ~/mounted

$ docker run -d -it -p 8088:8086 --env-file=dcache.env -v ~/mounted:/app/dcache/mounted --name dcache dcache

Watch logs such as tail

$ docker logs -t -f dcache

Remove the container

$ docker rm -f dcache

Remove the image

$ docker image rm dcache

# docker build on docker-machine

[docker build on docker-machine for macOS](https://github.com/ilshookim/dcache/blob/master/docker-machine.md)
