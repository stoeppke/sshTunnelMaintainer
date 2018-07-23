FROM ubuntu

ENV TERM xterm

RUN apt-get update

RUN apt-get -yq install openssh-server; \
  mkdir -p /var/run/sshd; \
  mkdir /root/.ssh && chmod 700 /root/.ssh; \
  touch /root/.ssh/authorized_keys

RUN useradd --home /restricted/directory restricted_user && mkdir -p /restricted/directory/ && chown -R restricted_user /restricted/

COPY bin/* /usr/local/bin/
COPY InitialRun.sh /InitialRun.sh
# COPY sshd_config /etc/ssh/sshd_config
# COPY autossh-jump-rtunnel.service /restricted/directory/autossh-jump-rtunnel.service

EXPOSE 22

ENTRYPOINT ["ssh-start"]
CMD ["ssh-server"]
