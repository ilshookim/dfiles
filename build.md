# build macOS

* please refer to https://www.robinwieruch.de/docker-macos

Install the docker dependency with Homebrew after making sure that all Homebrew dependencies are on the latest version:

$ brew update

$ brew install docker

You will also need a MacOS specific environment in which Docker can be used, because natively Docker uses a Linux environment. Therefore, install the docker-machine and virtualbox dependencies:

$ brew install docker-machine

$ brew cask install virtualbox

Note: If the last install fails, check your MacOS' System Preference and verify if System software from developer "Oracle America, inc" was blocked from loading. shows up. If you see it, hit the "Allow"-button and install it again.

Optional: if you want to use Docker Compose later, install the docker-compose dependency with Homebrew:

$ brew install docker-compose

Everything related to Docker and its environment is installed now. Let's get started with using it. First, create an engine for Docker on MacOS. This needs to be done only once, unless you want to create more than one engine by giving them other names than default. Usually one engine should be sufficient.

$ docker-machine create --driver virtualbox default

Using the following command for your Docker Machine, you should see whether your last Docker engine got created and whether you have more than one engine if desired:

$ docker-machine ls

> NAME      ACTIVE   DRIVER       STATE     URL   SWARM   DOCKER    ERRORS
> default   -        virtualbox   Stopped                 Unknown

Usually the Docker engine's STATE should be Running. If it isn't, like it's shown in the last output, you can start the engine with Docker Machine:

$ docker-machine start default

Checking your list of Docker engines again should lead you to one running Docker engine:

$ docker-machine ls
 
> NAME      ACTIVE   DRIVER       STATE     URL                         SWARM   DOCKER     ERRORS
> default   -        virtualbox   Running   tcp://192.168.99.100:2376           v19.03.5

Just for the sake of knowing about it, you can stop your Docker engine anytime too:

$ docker-machine stop default

Make sure that your Docker engine is running for the next steps. Last, we need to configure the environment variables for Docker. Run the following command to find out how:

$ docker-machine env default
 
> export DOCKER_TLS_VERIFY="1"
> export DOCKER_HOST="tcp://192.168.99.100:2376"
> export DOCKER_CERT_PATH="/Users/mydspr/.docker/machine/machines/default"
> export DOCKER_MACHINE_NAME="default"
>
> Run this command to configure your shell:
> eval $(docker-machine env default)

Usually this prints out the command to set all the env variables set for MacOS; which is the following:

$ eval $(docker-machine env default)

Finally, you should be able to start a Docker container with a pre-defined Docker image to check whether everything works as expected:

$ docker run hello-world
 
> Hello from Docker!
> This message shows that your installation appears to be working correctly.

