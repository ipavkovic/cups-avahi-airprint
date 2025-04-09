FROM alpine:latest

# Install the packages we need. Avahi will be included
RUN echo -e "https://dl-cdn.alpinelinux.org/alpine/edge/testing\nhttps://dl-cdn.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories &&\
    echo -e "https://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories && \
	apk add --update cups \
	cups-libs \
	cups-pdf \
	cups-client \
	cups-filters \
	cups-dev \
	gutenprint \
	gutenprint-libs \
	gutenprint-doc \
	gutenprint-cups \
	ghostscript \
	brlaser \
	hplip \
	avahi \
	inotify-tools \
	python3 \
	python3-dev \
	build-base \
	wget \
	rsync \
 	py3-pycups \
    bash \
	&& rm -rf /var/cache/apk/*

 # download and install Panasonic drivers
 RUN wget http://cs.psn-web.net/support/fax/common/file/Linux_PrnDriver/Driver_Install_files/mccgdi-2.0.8-x86_64.tar.gz &&\
        tar xzf mccgdi-2.0.8-x86_64.tar.gz &&\
        head -n3 mccgdi-2.0.8-x86_64/install-driver &&\
        bash mccgdi-2.0.8-x86_64/install-driver

# This will use port 631
EXPOSE 631

# We want a mount for these
VOLUME /config
VOLUME /services

# Add scripts
ADD root /
RUN chmod +x /root/*

#Run Script
CMD ["/root/run_cups.sh"]

# Baked-in config file changes
RUN sed -i 's/Listen localhost:631/Listen 0.0.0.0:631/' /etc/cups/cupsd.conf && \
	sed -i 's/Browsing Off/Browsing On/' /etc/cups/cupsd.conf && \
 	sed -i 's/IdleExitTimeout/#IdleExitTimeout/' /etc/cups/cupsd.conf && \
	sed -i 's/<Location \/>/<Location \/>\n  Allow All/' /etc/cups/cupsd.conf && \
	sed -i 's/<Location \/admin>/<Location \/admin>\n  Allow All\n  Require user @SYSTEM/' /etc/cups/cupsd.conf && \
	sed -i 's/<Location \/admin\/conf>/<Location \/admin\/conf>\n  Allow All/' /etc/cups/cupsd.conf && \
	sed -i 's/.*enable\-dbus=.*/enable\-dbus\=no/' /etc/avahi/avahi-daemon.conf && \
	echo "ServerAlias *" >> /etc/cups/cupsd.conf && \
	echo "DefaultEncryption Never" >> /etc/cups/cupsd.conf
