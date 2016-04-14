## Enrichment Map Tutorial Docker

This docker build creates an image that contains all programs and libraries required to run the basic EM analysis described in the Enrichment Map Protocol.

### Build steps
1. Install Docker. For OS X (with VMWare installed), you can use [Homebrew](http://brew.sh/):

        $ /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
        $ brew install docker docker-compose docker-machine
   
1. For Mac osx follow the instruction [from docker](https://docs.docker.com/engine/installation/mac/)

1. For windows follow the instructions [from docker](https://docs.docker.com/windows/step_one/)

1. Create a Docker machine: 

        $ docker-machine create --driver vmwarefusion
1. Build Enrichment Map Tutorial Docker.Run the below command from the directory that contains your Dockerfile. This should take several minutes: 

        $ docker build -t emtutorial/emtutorial .

### Running
1. To run the above docker image you need modify the below to contain the ip of the computer you are working on.  Change 192.168.0.10 to your IP.

        $ docker run --rm -it -p 8888:8888  --add-host="localhost:192.168.0.10" -v "$(pwd)/notebooks:/home/jovyan/work" emtutorial/emtutorial

1. Get IP of docker image

        $ docker-machine ip

1. You can now access the Enrichment Map Tutorial Docker from you browser: http://ip-of-docker-machine:8888 
	
