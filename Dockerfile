FROM cedvan/ubuntu
MAINTAINER Cédric Vanet <dev@cedvan.com>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update -qq
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv E1DF1F24 \
 && echo "deb http://ppa.launchpad.net/git-core/ppa/ubuntu trusty main" >> /etc/apt/sources.list \
 && apt-key adv --keyserver keyserver.ubuntu.com --recv C3173AA6 \
 && echo "deb http://ppa.launchpad.net/brightbox/ruby-ng/ubuntu trusty main" >> /etc/apt/sources.list \
 && apt-get update \
 && apt-get install -y supervisor git-core openssh-client ruby2.1 \
      zlib1g libyaml-0-2 libssl1.0.0 \
      libgdbm3 libreadline6 libncurses5 libffi6 \
      libxml2 libxslt1.1 libcurl3 libicu52 \
&& gem install --no-document bundler \
&& rm -rf /var/lib/apt/lists/* # 20140918

# Installe les certificats LXC
RUN apt-get update -qq
RUN apt-get install -qqy iptables ca-certificates lxc

# Installation de docker LXC
RUN apt-get install -qqy apt-transport-https
RUN echo deb https://get.docker.io/ubuntu docker main > /etc/apt/sources.list.d/docker.list
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 36A1D7869245C8950F966E92D8576A8BA88D21E9
RUN apt-get update -qq
RUN apt-get install -qqy lxc-docker

# Installation de curl
RUN apt-get install -qqy curl

# Droits sudo sans password pour gitlab_ci_runner
RUN chmod 755 /etc/sudoers
RUN echo "gitlab_ci_runner ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

ADD assets/setup/ /app/setup/
RUN chmod 755 /app/setup/install
RUN /app/setup/install

ADD assets/init /app/init
RUN chmod 755 /app/init

VOLUME ["/home/gitlab_ci_runner/data"]

# Chargement du docker du host pour lancer du docker dans ce docker
VOLUME /var/lib/docker

ENTRYPOINT ["/app/init"]
CMD ["app:start"]
