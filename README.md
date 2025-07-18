# lidR-container

Docker container with the R [lidR](https://github.com/r-lidar/lidR) and
[lasR](https://github.com/r-lidar/lasR) libraries pre-installed.

## Running Container

```bash
docker run --rm -it --volume '/tmp:/tmp' --volume '/mnt:/mnt' --volume '/home:/home' --volume "$PWD:$PWD" --workdir "$PWD" ghcr.io/vogelerlab/lidr-container:main R
```
