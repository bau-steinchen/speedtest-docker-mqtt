FROM ubuntu:jammy-20221130

# install curl
RUN apt-get update && \
    apt-get -y install curl apt-utils && \
    curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh | bash && \
    apt-get -y install speedtest

