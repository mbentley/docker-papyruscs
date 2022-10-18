# stage 0 - build papyruscs from master
FROM mcr.microsoft.com/dotnet/sdk:3.1-bionic AS build

# cache busting
ARG LAST_COMMIT
ARG TEXTURE_PACK

RUN apt-get update &&\
  apt-get install --no-install-recommends -y ca-certificates jq unzip wget &&\
  cd /tmp &&\
  git clone --depth 1 https://github.com/papyrus-mc/papyruscs.git &&\
  cd papyruscs &&\
  dotnet publish PapyrusCs -c Debug --self-contained --runtime linux-x64 &&\
  cd /tmp/papyruscs/PapyrusCs/bin/Debug/netcoreapp3.1/linux-x64/publish &&\
  chmod +x PapyrusCs &&\
  cd /tmp &&\
  wget -q -O "texturepack.zip" "$(if [ -z "${TEXTURE_PACK}" ]; then wget -q -O - https://api.github.com/repos/Mojang/bedrock-samples/releases/latest | jq -r .zipball_url; else echo "${TEXTURE_PACK}"; fi)" &&\
  unzip texturepack.zip &&\
  rm -rf /tmp/papyruscs/PapyrusCs/bin/Debug/netcoreapp3.1/linux-x64/publish/textures/* &&\
  mv /tmp/Mojang-bedrock-samples-*/resource_pack/textures/terrain_texture.json /tmp/papyruscs/PapyrusCs/bin/Debug/netcoreapp3.1/linux-x64/publish/textures/ &&\
  mv /tmp/Mojang-bedrock-samples-*/resource_pack/textures/blocks /tmp/papyruscs/PapyrusCs/bin/Debug/netcoreapp3.1/linux-x64/publish/textures/

# stage 1 - runtime image for papyruscs
# rebased/repackaged base image that only updates existing packages
FROM mbentley/ubuntu:20.04
LABEL maintainer="Matt Bentley <mbentley@mbentley.net>"

RUN apt-get update &&\
  apt-get install --no-install-recommends -y libgdiplus libc6-dev &&\
  mkdir /opt/papyruscs &&\
  rm -rf /var/lib/apt/lists/*

COPY --from=build /tmp/papyruscs/PapyrusCs/bin/Debug/netcoreapp3.1/linux-x64/publish/ /opt/papyruscs/
ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1

ENTRYPOINT ["/opt/papyruscs/PapyrusCs"]
CMD ["--help"]
