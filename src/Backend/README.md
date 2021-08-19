## Build docker

`docker build -t codymaze:latest .`

## Launch

`docker run --rm -p 127.0.0.1:8080:8080 -e WOM_DOMAIN=wom.social -e SOURCE_ID=5f3ab6d898e66631aaeb60f2 -v "/private:/private" codymaze:latest`