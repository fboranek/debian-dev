# debian-dev

Docker image for compiling an application for Linux on Mac OS.


## Instalation
Download script [docker-sshd](https://raw.githubusercontent.com/fboranek/debian-dev/master/bin/docker-sshd) and run.

The script launches the docker container with name 'dev' and links several files and directories into the container and make an ssh connection to the container. It links particularly:

- Your home dir to the same location. A project dir is expected there.

- Your ssh settings (**~/.ssh**) to /root. It allows you to connect to container via ssh using the key which is defined in ~/.ssh/authorized_keys

- Your bash settings (**~/.bash_profile**). E.g.
```bash
export DEBFULLNAME="John Doe"
export DEBEMAIL=John.Doe@example.com
```

- Folder **docker-include** from your home. Into this folder will be synchronized any public includes from /usr/include.

