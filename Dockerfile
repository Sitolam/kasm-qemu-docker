FROM kasmweb/core-ubuntu-jammy:1.15.0

ARG DEBCONF_NOWARNINGS="yes"
ARG DEBIAN_FRONTEND="noninteractive"
ARG DEBCONF_NONINTERACTIVE_SEEN="true"

ENV HOME /home/kasm-default-profile
ENV STARTUPDIR /dockerstartup
ENV INST_SCRIPTS $STARTUPDIR/install
WORKDIR $HOME

USER root

RUN apt-get update \
    && apt-get --no-install-recommends -y install \
        tini \
        wget \
        ovmf \
        swtpm \
        procps \
        iptables \
        iproute2 \
        apt-utils \
        dnsmasq \
        net-tools \
        qemu-utils \
        ca-certificates \
        netcat-openbsd \
        qemu-system-x86 \
        qemu-system-gui \
        sudo \
        mpg123 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY ./src /run/
COPY ./web /var/www/

RUN chmod +x /run/*.sh
#RUN echo 'kasm-user ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers <-- not needed now... Will be relevant later maybe, when container does not need root

RUN mkdir /storage
VOLUME /storage
RUN chown -R 1000:1000 /storage

ENV CPU_CORES="1"
ENV RAM_SIZE="4G"
ENV DISK_SIZE="16G"
ENV BOOT="https://dl-cdn.alpinelinux.org/alpine/v3.19/releases/x86_64/alpine-virt-3.19.1-x86_64.iso"

ARG VERSION_ARG="0.0"
RUN echo "$VERSION_ARG" > /run/version

#COPY /custom_startup.sh $STARTUPDIR/custom_startup.sh
COPY /custom_startup.sh /root/start.sh

# Update the desktop environment to be optimized for a single application
RUN cp $HOME/.config/xfce4/xfconf/single-application-xfce-perchannel-xml/* $HOME/.config/xfce4/xfconf/xfce-perchannel-xml/
#RUN cp /usr/share/backgrounds/bg_kasm.png /usr/share/backgrounds/bg_default.png
#RUN apt-get remove -y xfce4-panel

ENV QEMUDISPLAY "gtk,full-screen=on"

RUN chown 1000:0 $HOME
RUN $STARTUPDIR/set_user_permission.sh $HOME

ENV HOME /home/kasm-user
WORKDIR $HOME
RUN mkdir -p $HOME && chown -R 1000:0 $HOME

USER 1000