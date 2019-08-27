FROM ubuntu:latest
LABEL maintainer="dustinmnemes@gmail.com"

RUN \
  apt update -y && \
  apt install -y \
    bc \
    bsdmainutils \
    curl \
    less \
    jq \
    python && \
  curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py && \
  python get-pip.py && \
  pip install yq

ADD kbk.sh /usr/local/bin/kbk
ADD .bashrc /root/.bashrc

CMD ["/bin/bash"]
