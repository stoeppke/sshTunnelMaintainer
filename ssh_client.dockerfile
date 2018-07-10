FROM alpine
RUN apk --update add openssh sshpass autossh

COPY ClientRun.sh /
RUN chmod +x ClientRun.sh

CMD [ "/bin/sh", "/ClientRun.sh" ]