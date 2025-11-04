FROM alpine:latest
ENV PASSWORD=peplink
RUN echo "http://dl-cdn.alpinelinux.org/alpine/latest-stable/community" >> /etc/apk/repositories && \
    apk add --no-cache \
        xrdp xorgxrdp icewm xfce4-terminal feh \
        xorg-server xf86-video-dummy dbus-x11 \
        shadow sudo && \
    addgroup -S xrdp && adduser -S -D -H -G xrdp xrdp && \
    adduser -D peplink && \
    echo "peplink ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    usermod -aG video,input peplink && \
    mkdir -p /home/peplink/.icewm && \
    printf '#!/bin/sh\nfeh --bg-scale /home/peplink/background.png &\nexec icewm\n' > /home/peplink/.icewm/startup && \
    chmod +x /home/peplink/.icewm/startup && \
    chown -R peplink:peplink /home/peplink/.icewm && \
    printf '#!/bin/sh\nunset SESSION_MANAGER\nunset DBUS_SESSION_BUS_ADDRESS\nexec icewm-session\n' > /etc/xrdp/startwm.sh && \
    chmod +x /etc/xrdp/startwm.sh && \
    printf '#!/bin/sh\nprintf "peplink:${PASSWORD}\\n" | chpasswd\nmkdir -p /var/run/xrdp\nrm -f /var/run/xrdp/*\nxrdp-sesman &\nsleep 1\nexec xrdp --nodaemon\n' > /usr/local/bin/startup.sh && \
    chmod +x /usr/local/bin/startup.sh

COPY background.jpg /home/peplink/background.jpg
RUN chown peplink:peplink /home/peplink/background.jpg

EXPOSE 3389
CMD ["/usr/local/bin/startup.sh"]
