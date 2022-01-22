FROM gitpod/workspace-base

RUN sudo apt-get update

RUN curl -fsSL https://deb.nodesource.com/setup_17.x | sudo -E bash -

RUN sudo apt-get install -y nodejs

ADD https://github.com/gohugoio/hugo/releases/download/v0.92.0/hugo_0.92.0_Linux-64bit.deb /tmp/

RUN sudo dpkg -i /tmp/hugo_0.92.0_Linux-64bit.deb

RUN sudo rm -rf /var/lib/apt/lists/*