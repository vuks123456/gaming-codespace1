FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install desktop environment and tools
RUN apt-get update && apt-get install -y \
    xfce4 xfce4-goodies \
    dbus-x11 x11-xserver-utils \
    tightvncserver \
    wget curl git sudo \
    python3 python3-pip \
    mesa-utils mesa-utils-extra \
    net-tools \
    openjdk-17-jdk \
    pulseaudio \
    firefox \
    software-properties-common \
    && apt-get clean

# Install code-server
RUN curl -fsSL https://code-server.dev/install.sh | sh

# Setup user
RUN useradd -m coder && echo "coder:coder" | chpasswd && adduser coder sudo

USER coder
WORKDIR /home/coder

# Setup VNC password
RUN mkdir -p /home/coder/.vnc
RUN echo "coder" | vncpasswd -f > /home/coder/.vnc/passwd
RUN chmod 600 /home/coder/.vnc/passwd

# Setup startup script
RUN echo '#!/bin/bash\n\
xrdb $HOME/.Xresources\n\
startxfce4 &' > /home/coder/.vnc/xstartup

RUN chmod +x /home/coder/.vnc/xstartup

EXPOSE 8080 5901

CMD ["sh", "-c", "vncserver :1 -geometry 1280x720 -depth 24 && code-server --bind-addr 0.0.0.0:8080 --auth none"]
