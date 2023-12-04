# syntax=docker/dockerfile:1

FROM docker.io/steamcmd/steamcmd:latest as base

RUN \
  --mount=type=secret,id=STEAM_USERNAME \
  --mount=type=secret,id=STEAM_PASSWORD \
  --mount=type=secret,id=HEADLESS_CODE \
  /usr/games/steamcmd \
  +force_install_dir /data \
  +login $(cat /run/secrets/STEAM_USERNAME) $(cat /run/secrets/STEAM_PASSWORD) \
  +app_update 2519830 -beta headless -betapassword $(cat /run/secrets/HEADLESS_CODE) \
  +quit

FROM docker.io/library/mono:latest as res

RUN apt-get update && apt-get install -y libopus-dev libopus0 opus-tools libc-dev && rm -rf /var/lib/{apt,cache,dpkg}

# remove expired certificates (details: https://github.com/KSP-CKAN/CKAN/wiki/SSL-certificate-errors#removing-expired-lets-encrypt-certificates)
RUN sed -i 's#^mozilla/DST_Root_CA_X3.crt$#!mozilla/DST_Root_CA_X3.crt#' /etc/ca-certificates.conf && update-ca-certificates && cert-sync /etc/ssl/certs/ca-certificates.crt

COPY --from=base /data /opt/Resonite
# Steam Networking Socket does not support multiple instance.
# COPY --from=base /root/.local/share/Steam/steamcmd/linux64/steamclient.so /root/.steam/sdk64/steamclient.so
RUN mkdir -p /mnt/resonite/{cache,config,data,logs}
COPY ./resonite.sh /usr/local/bin/resonite

STOPSIGNAL SIGINT
CMD [ "/usr/local/bin/resonite" ]
