# CodyMaze WOM back-end

This repository contains the WOM back-end for the **CodyMaze Flutter web app**: a self-contained web version of the **CodyMaze game**. CodyMaze teaches programming concepts through commands for moving through a maze ([read more about the game](https://www.codyroby.it/metodi/altri-metodi/codymaze/)).

The service generates WOM vouchers on behalf of CodyMaze players. These vouchers reward one minute of social commitment through the [WOM digital social-reward platform](https://wom.social).

CodyMaze was conceived by Alessandro Bogliolo and originally developed by Brendan Paolini, Lorenz Cuno Klopfenstein, and Saverio Delpriori. Back-end and new self-contained web app version of the game by Gian Marco Di Francesco. The project is associated with [DIGIT srl](https://digit.srl/) and the [CodyRoby](https://www.codyroby.it/) teaching methodologies.

## Architecture

Simple web services that exposes one single end-point: `POST /vouchers`. It requests and verifies WOM vouchers for a player, then returns a WOM link, password, and voucher count. A successful response issues **30 WOM vouchers**.

## Configuration and run

Requires Docker Compose, [go-task](https://taskfile.dev/), the external Docker network `web`, and a WOM source's credentials/key. Copy `config.env.template` to `config.env` and set `WOM_DOMAIN` and `SOURCE_ID`. Place the private key at `keys/codymaze.pem` (mounted read-only in the container), then run:

```sh
task up
```

Use `task rebuild` to rebuild and start the service; `task logs` follows its logs.

The API listens on port 80 in the container (override in `src\Backend\Dockerfile`).

Docker Compose configuration provides labels that route `codymaze.wom.social` requests through Traefik.
