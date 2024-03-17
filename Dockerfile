FROM kasmweb/core-ubuntu-jammy:1.15.0

ARG DEBCONF_NOWARNINGS "yes"
ARG DEBIAN_FRONTEND "noninteractive"
ARG DEBCONF_NONINTERACTIVE_SEEN "true"

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
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY ./src /run/
COPY ./web /var/www/

RUN chmod +x /run/*.sh

VOLUME /storage

ENV CPU_CORES "1"
ENV RAM_SIZE "4G"
ENV DISK_SIZE "32G"
ENV BOOT "https://releases.ubuntu.com/22.04.4/ubuntu-22.04.4-desktop-amd64.iso"

ARG VERSION_ARG "0.0"
RUN echo "$VERSION_ARG" > /run/version

RUN echo "/usr/bin/desktop_ready && /usr/bin/tini -s /run/entry.sh" > $STARTUPDIR/custom_startup.sh \
&& chmod +x $STARTUPDIR/custom_startup.sh

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

#USER 1000


