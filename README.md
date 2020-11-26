# dcache

delete cache utility with dart language.

* 많은 수의 파일이 폴더에 남으면 운영체제가 느려지고 심각한 경우에 중지가 될 수가 있습니다.

* 디캐쉬를 활용하면 지정한 경로와 하위 경로를 모두 감시하고
지정한 수 보다 파일이 많아지면 오래된 순으로 삭제하는 서비스를 제공할 수 있습니다.

* 디캐쉬는 파라메터를 지정하여 가볍게 프로세스로 실행할 수 있는 심플한 REST서버입니다.

* 또한 디캐쉬는 감시할 경로를 볼륨으로 마운트하고 도커 컨테이너로 실행할 수 있습니다.

* 그러므로 curl localhost:8088/stop 또는 curl localhost:8088/start와 같은 호출하여
디캐쉬 서비스를 중지하거나 실행할 수가 있습니다.

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
