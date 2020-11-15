# mbentley/papyruscs

docker image for [papyruscs](https://github.com/mjungnickel18/papyruscs)
based off of ubuntu:18.04

To pull this image:
`docker pull mbentley/papyruscs`

*Warning*: You should really know what you're doing if you're using this image.  You can break your world if you do not properly back it up and pause saving.  See [this issue](https://github.com/mjungnickel18/papyruscs/issues/63)

Example usage:

```
docker run -t --rm --net=none \
  -v /data/minecraft/temp_map_gen/"${MC_SERVER_PATH}":/data/world \
  -v /var/www/minecraft/"${MC_SERVER_PATH}":/data/minecraft \
  mbentley/papyruscs \
  --world /data/world --output /data/minecraft/ --playericons --htmlfile index.html
```
