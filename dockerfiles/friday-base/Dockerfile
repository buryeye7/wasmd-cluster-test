FROM buryeye7/centos7-hdac-base

USER root
ENV HOME=/root
ENV LD_LIBRARY_PATH=/usr/local/lib:/usr/lib:/usr/local/lib64:/usr/lib64
ENV GOPATH=$HOME/go
ENV GOROOT=/usr/local/go
ENV PATH=$PATH:$HOME/.cargo/bin:$GOPATH/bin:$GOROOT/bin

RUN cmake -version
RUN gcc --version
RUN rustc --version

RUN yum -y update
RUN yum -y upgrade
RUN yum -y install expect
RUN yum -y install vim 
RUN yum -y install telnet
RUN yum -y install net-tools 
RUN yum -y install python3

WORKDIR $GOPATH/src
#RUN git clone https://github.com/rizon-world/friday
RUN git clone https://github.com/CosmWasm/wasmd.git
WORKDIR $GOPATH/src/wasmd
RUN git checkout v0.10.0
RUN make install

RUN wasmd version --long
RUN wasmcli  version --long
