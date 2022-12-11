FROM ubuntu:jammy-20221130

# install curl
RUN apt-get update && \
    apt-get -y install curl cron jq mosquitto-clients && \
    curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh | bash && \
    apt-get -y install speedtest

# copy entry scripts
COPY files/ /

#defining EntryScript
ENTRYPOINT [ "/usr/local/bin/entry.sh" ]
# Make help the default if no arguments are given
CMD [ "--help" ]
