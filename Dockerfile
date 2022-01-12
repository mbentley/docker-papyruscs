# stage 0 - build papyruscs from master
FROM mcr.microsoft.com/dotnet/sdk:3.1-bionic AS build

RUN apt-get update &&\
  apt-get install -y unzip wget &&\
  cd /tmp &&\
  git clone --depth 1 https://github.com/papyrus-mc/papyruscs.git &&\
  cd papyruscs &&\
  dotnet publish PapyrusCs -c Debug --self-contained --runtime linux-x64 &&\
  cd /tmp/papyruscs/PapyrusCs/bin/Debug/netcoreapp3.1/linux-x64/publish &&\
  chmod +x PapyrusCs &&\
  cd /tmp &&\
  wget -O "/tmp/texturepack.zip" "https://aka.ms/resourcepacktemplate" &&\
  mkdir /tmp/texturepack &&\
  cd /tmp/texturepack &&\
  unzip /tmp/texturepack.zip &&\
  rm -rf /tmp/papyruscs/PapyrusCs/bin/Debug/netcoreapp3.1/linux-x64/publish/textures/* &&\
  mv /tmp/texturepack/textures/terrain_texture.json /tmp/papyruscs/PapyrusCs/bin/Debug/netcoreapp3.1/linux-x64/publish/textures/ &&\
  mv /tmp/texturepack/textures/blocks /tmp/papyruscs/PapyrusCs/bin/Debug/netcoreapp3.1/linux-x64/publish/textures/

# stage 1 - runtime image for papyruscs
# rebased/repackaged base image that only updates existing packages
FROM mbentley/ubuntu:18.04
LABEL maintainer="Matt Bentley <mbentley@mbentley.net>"

RUN apt-get update &&\
  apt-get install -y libgdiplus libc6-dev &&\
  mkdir /opt/papyruscs &&\
  rm -rf /var/lib/apt/lists/*

COPY --from=build /tmp/papyruscs/PapyrusCs/bin/Debug/netcoreapp3.1/linux-x64/publish/ /opt/papyruscs/

ENTRYPOINT ["/opt/papyruscs/PapyrusCs"]
CMD ["--help"]
