# syntax=docker/dockerfile:1

FROM docker.io/steamcmd/steamcmd:latest AS steam

# Binary files of Resonite are given by Github Actions
RUN \
--mount=type=secret,id=STEAM_USERNAME \
--mount=type=secret,id=STEAM_PASSWORD \
--mount=type=secret,id=HEADLESS_CODE \
/usr/games/steamcmd \
+force_install_dir /steamdata \
+login $(cat /run/secrets/STEAM_USERNAME) $(cat /run/secrets/STEAM_PASSWORD) \
+app_update 2519830 -beta headless -betapassword $(cat /run/secrets/HEADLESS_CODE) \
+quit



FROM mcr.microsoft.com/dotnet/runtime:10.0 AS runtime

RUN apt-get update && apt-get install -y libopus-dev libopus0 opus-tools libc-dev && rm -rf /var/lib/{apt,cache,dpkg}

COPY --from=steam /steamdata /opt/Resonite
# Steam Networking Socket does not support multiple instance.
# COPY --from=steam /root/.local/share/Steam/steamcmd/linux64/steamclient.so /root/.steam/sdk64/steamclient.so
RUN mkdir -p /var/lib/resonite/cache /var/lib/resonite/config /var/lib/resonite/data /var/lib/resonite/logs
COPY ./resonite.sh /usr/local/bin/resonite

VOLUME ["/var/lib/resonite/cache", "/var/lib/resonite/config", "/var/lib/resonite/data", "/var/lib/resonite/logs"]
HEALTHCHECK --interval=5s --timeout=10s --start-period=60s --retries=4 CMD test "$(cat /va/lib/resonite/watchdog)" != "$(cat /var/lib/resonite/_watchdog)" || exit 1; cat /var/lib/resonite/watchdog > /var/lib/resonite/_watchdog
STOPSIGNAL SIGINT
WORKDIR "/opt/Resonite/Headless"
ENTRYPOINT [ "/usr/local/bin/resonite" ]
