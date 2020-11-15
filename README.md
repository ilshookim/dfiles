# dcache

delete cache utility with dart language.

# docker

Create a Docker image on your system

$ docker build -t dcache .

Line 30 of bin/server.dart causes the server to exit as soon as it is ready to listen for requests.

$ docker run -d -it -p 8088:8088 --name dcache dcache

Time how long it takes to lauch a server

$ time docker run -it -p 8088:8088 --name dcache dcache

Remove the container

$ docker rm -f dcache

Remove the image

$ docker image rm dcache

# docker build

[docker build for macOS](https://github.com/ilshookim/dcache/blob/master/build.md)
