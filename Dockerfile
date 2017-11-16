FROM debian:8

##########################################################################################

# first install some packages we need now (E.g. for downloading repo key) and base packages
RUN apt-get update
RUN apt-get install -y \
 wget apt-utils aptitude nano vim bash-completion inotify-tools rsync \
 git devscripts gcc g++ gdb gdbserver make automake cmake pbuilder \
 autoconf-archive debhelper dh-autoreconf libboost-all-dev libjsoncpp-dev protobuf-compiler \
 librpc-xml-perl libsnappy-dev zlib1g-dev libprotobuf-dev pkg-config libaio-dev libcmph-dev \
 libcrypto++-dev libcxxtools-dev libgeoip-dev libglib2.0-dev libpcre3-dev libpcre++-dev \
 ipcalc python-support python-protobuf python-levenshtein python-pkg-resources python-unittest2 \
 python-werkzeug python-snappy uuid-dev
 

# clang stable
# Fingerprint: 6084 F3CF 814B 57C1 CF12 EFD5 15CF 4D18 AF4F 7421
RUN wget -qO - https://apt.llvm.org/llvm-snapshot.gpg.key | sudo apt-key add -
RUN echo "deb http://apt.llvm.org/jessie/ llvm-toolchain-jessie-5.0 main" > /etc/apt/sources.list.d/llvm-toolchain.list
RUN apt-get update
RUN apt-get install -y clang-5.0 lldb-5.0 lld-5.0 clang-format-5.0 python-clang-5.0
RUN update-alternatives \
 --install /usr/bin/clang      clang        /usr/bin/clang-5.0 80 \
 --slave /usr/bin/clang++      clang++      /usr/bin/clang++-5.0 \
 --slave /usr/bin/clang-format clang-format /usr/bin/clang-format-5.0 \
 --slave /usr/bin/clang-cpp    clang-cpp    /usr/bin/clang-cpp-5.0 \
 --slave /usr/bin/clang-cl     clang-cl     /usr/bin/clang-cl-5.0
 

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
