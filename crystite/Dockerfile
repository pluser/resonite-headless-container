# syntax=docker/dockerfile:1

FROM docker.io/steamcmd/steamcmd:latest AS steam
RUN \
--mount=type=secret,id=STEAM_USERNAME \
--mount=type=secret,id=STEAM_PASSWORD \
--mount=type=secret,id=HEADLESS_CODE \
/usr/games/steamcmd \
+force_install_dir /steamdata \
+login $(cat /run/secrets/STEAM_USERNAME) $(cat /run/secrets/STEAM_PASSWORD) \
+app_update 2519830 -beta headless -betapassword $(cat /run/secrets/HEADLESS_CODE) \
+quit



FROM mcr.microsoft.com/dotnet/sdk:9.0 AS crystite
RUN git clone --depth 1 https://github.com/Nihlus/Crystite.git
WORKDIR /Crystite
RUN dotnet publish -f net8.0 -c Release -r linux-x64 --self-contained false -o bin/crystite Crystite/Crystite.csproj
RUN dotnet publish -f net8.0 -c Release -r linux-x64 --self-contained false -o bin/crystitectl Crystite.Control/Crystite.Control.csproj



FROM mcr.microsoft.com/dotnet/aspnet:9.0-bookworm-slim AS runtime
RUN apt-get update && apt-get install -y wget libassimp5 libfreeimage3 libfreetype6 libopus0 libbrotli1 zlib1g yt-dlp jq yq unzip && rm -rf /var/lib/{apt,cache,dpkg}

COPY --from=steam /steamdata /opt/Resonite
# Steam Networking Socket does not support multiple instance.
# COPY --from=steam /root/.local/share/Steam/steamcmd/linux64/steamclient.so /root/.steam/sdk64/steamclient.so
RUN mkdir -p /var/lib/resonite/cache /var/lib/resonite/data /var/lib/resonite/logs
COPY ./crystite.sh /usr/local/bin/resonite

COPY --from=crystite /Crystite/bin/crystite /Crystite/bin/crystitectl /usr/local/lib/crystite
COPY ./appsettings.json /etc/crystite/appsettings.json
RUN \
ln -s /usr/local/lib/crystite/crystite /usr/local/bin/crystite && \
ln -s /usr/local/lib/crystitectl/crystitectl /usr/local/bin/crystitectl && \
mkdir -p /etc/crystite/conf.d

VOLUME ["/var/lib/resonite/cache", "/var/lib/resonite/data", "/var/lib/resonite/logs", "/etc/crystite/conf.d"]
STOPSIGNAL SIGINT
ENTRYPOINT [ "/usr/local/bin/resonite" ]
