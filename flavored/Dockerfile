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

# install Resonite Mod Loader
ADD https://github.com/resonite-modding-group/ResoniteModLoader/releases/latest/download/ResoniteModLoader.dll /steamdata/Libraries/
ADD https://github.com/resonite-modding-group/ResoniteModLoader/releases/latest/download/0Harmony.dll /steamdata/rml_libs/

# install Headless Prometheus Exporter
ADD https://g.j4.lc/general-stuff/resonite/headless-prometheus-exporter/-/releases/1.2.4/downloads/HeadlessPrometheusExporter.dll /steamdata/rml_mods/

FROM mcr.microsoft.com/dotnet/runtime:9.0 AS runtime

RUN apt-get update && apt-get install -y libopus-dev libopus0 opus-tools libc-dev && rm -rf /var/lib/{apt,cache,dpkg}

COPY --from=steam /steamdata /opt/Resonite
# Steam Networking Socket does not support multiple instance.
# COPY --from=steam /root/.local/share/Steam/steamcmd/linux64/steamclient.so /root/.steam/sdk64/steamclient.so
RUN mkdir -p /var/lib/resonite/cache /var/lib/resonite/config /var/lib/resonite/data /var/lib/resonite/logs /opt/resonite/rml_config
COPY ./resonite.sh /usr/local/bin/resonite

VOLUME ["/var/lib/resonite/cache", "/var/lib/resonite/config", "/var/lib/resonite/data", "/var/lib/resonite/logs", "/opt/resonite/rml_config"]
STOPSIGNAL SIGINT
ENTRYPOINT [ "/usr/local/bin/resonite" ]
