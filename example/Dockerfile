FROM ubuntu

ADD sources.list /etc/apt/sources.list
RUN apt-get update
RUN apt-get install supervisor curl bash --force-yes -y
ADD https://github.com/danielwii/docker_base_scripts/archive/0.1.2.tar.gz /init/archive.tar.gz
RUN tar zxvf /init/archive.tar.gz -C /init --xform='s|docker_base_scripts-0.1.2||S' --verbose --show-transformed-names
# RUN git clone --depth=1 https://github.com/danielwii/docker_base_scripts.git /init
CMD ["supervisord", "-c", "/init/supervisord.conf"]
