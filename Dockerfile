#!/usr/bin/env docker build --tag fboranek/debian-dev:bullseye . -f
FROM debian:bullseye

##########################################################################################

# first install some packages we need now (E.g. for downloading repo key) and base packages
RUN apt-get update && \
 apt-get install -y \
  wget apt-utils aptitude nano vim bash-completion inotify-tools rsync \
  git devscripts gcc g++ gdb gdbserver make automake cmake pbuilder \
  autoconf-archive debhelper dh-autoreconf libboost-all-dev libjsoncpp-dev protobuf-compiler \
  librpc-xml-perl libsnappy-dev zlib1g-dev libprotobuf-dev pkg-config libaio-dev libcmph-dev \
  libcrypto++-dev libcxxtools-dev libgeoip-dev libglib2.0-dev libpcre3-dev libpcre++-dev \
  ipcalc python3-protobuf python3-levenshtein python3-pkg-resources python3-unittest2 \
  python3-werkzeug python3-snappy uuid-dev


# clang stable
# Fingerprint: 6084 F3CF 814B 57C1 CF12 EFD5 15CF 4D18 AF4F 7421
RUN wget -qO - https://apt.llvm.org/llvm-snapshot.gpg.key | sudo apt-key add -                                             \
 && echo "deb http://apt.llvm.org/bullseye/ llvm-toolchain-bullseye-15 main" > /etc/apt/sources.list.d/llvm-toolchain.list \
 && apt-get update                                                                                                         \
 && apt-get install -y clang-15 clangd-15 lld-15 lldb-15 clang-format-15 clang-tidy-15                                     \ 
 && update-alternatives                                                                                                    \
 --install /usr/bin/clang      clang        /usr/bin/clang-15 80                                                           \
 --slave /usr/bin/clang++      clang++      /usr/bin/clang++-15                                                            \
 --slave /usr/bin/clang-format clang-format /usr/bin/clang-format-15                                                       \
 --slave /usr/bin/clang-cpp    clang-cpp    /usr/bin/clang-cpp-15                                                          \
 --slave /usr/bin/clang-cl     clang-cl     /usr/bin/clang-cl-15                                                           \
 --slave /usr/bin/clang-tidy   clang-tidy   /usr/bin/clang-tidy-15
 

##########################################################################################
# SSH service
##########################################################################################

# use the same RSA keys
COPY src/sshd/* /etc/ssh/ 
RUN chmod go-rwx /etc/ssh/ssh_host_*
RUN chmod go+r   /etc/ssh/ssh_host_*.pub

# the password can be hardcoded like
#   RUN echo 'root:secret' | chpasswd
# but better is:
#  - start image with argument to map .ssh with authorized_keys: -v ${HOME}/.ssh:/root/.ssh
#  - change password in running image
#      docker exec -it inspiring_newton passwd

RUN apt-get install -y openssh-server
RUN mkdir /var/run/sshd
RUN sed -i -E -e 's/^PermitRootLogin.*$/PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

EXPOSE 22
##########################################################################################


COPY src/bin/* /usr/bin/
COPY src/home/bashrc       /root/.bashrc
COPY src/home/bash_history /root/.bash_history

CMD ["/usr/bin/srv-docker-entrypoint"]
