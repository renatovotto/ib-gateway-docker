FROM ubuntu:20.04
LABEL maintainer="Renato Votto"

# Environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV USER=docker
ENV DISPLAY=":1"
ENV LIBGL_ALWAYS_INDIRECT=1
ENV IB_GATEWAY_VERSION="stable"

# Build arguments (mandatory)
# --build-arg TRADING_MODE=p
# 'p' for paper, 'l' for live account
ARG TRADING_MODE
ARG ACCOUNT_DIRECTORY

# Assign environment variables
ENV TRADING_MODE=${TRADING_MODE}
ENV ACCOUNT_DIRECTORY=${ACCOUNT_DIRECTORY}

# Create docker user and set working directory
RUN useradd -ms /bin/bash docker
WORKDIR /home/docker

# Install necessary packages
RUN apt-get update && apt-get install -y \
    wget ca-certificates \
    xvfb \
    bc xdotool \
    xauth x11-utils libx11-6 mesa-utils libgl1-mesa-glx \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# IB Gateway installation
USER docker
RUN wget -q https://download2.interactivebrokers.com/installers/ibgateway/$IB_GATEWAY_VERSION-standalone/ibgateway-$IB_GATEWAY_VERSION-standalone-linux-x64.sh \
 && chmod +x ibgateway-$IB_GATEWAY_VERSION-standalone-linux-x64.sh \
 && ./ibgateway-$IB_GATEWAY_VERSION-standalone-linux-x64.sh -q \
 && rm -f ibgateway-$IB_GATEWAY_VERSION-standalone-linux-x64.sh

USER root

# Copy configuration files
COPY jts.ini Jts/
COPY ${TRADING_MODE}.xml Jts/$ACCOUNT_DIRECTORY/ibg.xml
COPY start.sh .

# Assign permissions and ownerships to the user
RUN chmod +x start.sh \
 && chown $USER:$USER Jts/jts.ini \
 && chown -R $USER:$USER Jts/$ACCOUNT_DIRECTORY \
 && chown $USER:$USER start.sh

USER docker

# Expose API ports
EXPOSE 4001
EXPOSE 4002

# Start IB Gateway
ENTRYPOINT ["./start.sh"]
