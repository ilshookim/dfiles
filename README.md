# dcache

cache file deletion utility with dart language.

# docker

This example builds a server using [dart2native](https://dart. dev/tools/dart2native) to run in a container.

Create a Docker image on your system

$ docker build -t dcache .

Time how long it takes to lauch a server

$ time docker run -d -it -p 8088:8088 --name dcache dcache

Line 30 of bin/server.dart causes the server to exit as soon as it is ready to listen for requests.

Remove the container

$ docker rm -f dcache

Remove the image

$ docker image rm dcache
