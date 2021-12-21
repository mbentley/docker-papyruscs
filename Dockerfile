# start from base image & upgrade all packages
FROM ubuntu:18.04 AS base
MAINTAINER Matt Bentley <mbentley@mbentley.net>

RUN apt-get update &&\
  apt-get upgrade -y &&\
  apt-get dist-upgrade -y &&\
   rm -rf /var/lib/apt/lists/*

# copy over the contents into a new image and add my customizations
FROM scratch
COPY --from=base / /

RUN apt-get update &&\
  apt-get install -y libgdiplus libc6-dev unzip wget &&\
  cd /tmp &&\
  wget -O "/tmp/papyruscs.zip" "https://github.com/mjungnickel18/papyruscs/releases/download/v0.5.1/papyruscs-dotnetcore-0.5.1-linux64.zip" &&\
  mkdir /opt/papyruscs &&\
  cd /opt/papyruscs &&\
  unzip /tmp/papyruscs.zip &&\
  rm /tmp/papyruscs.zip &&\
  chmod +x PapyrusCs &&\
  wget -O "/tmp/texturepack.zip" "https://aka.ms/resourcepacktemplate" &&\
  mkdir /tmp/texturepack &&\
  cd /tmp/texturepack &&\
  unzip /tmp/texturepack.zip &&\
  rm -rf /opt/papyruscs/textures/* &&\
  mv /tmp/texturepack/textures/terrain_texture.json /opt/papyruscs/textures/ &&\
  mv /tmp/texturepack/textures/blocks /opt/papyruscs/textures/ &&\
  cd / &&\
  rm -rf /tmp/* &&\
  apt-get purge -y unzip wget &&\
  apt-get autoremove -y &&\
  rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["/opt/papyruscs/PapyrusCs"]
CMD [""]
