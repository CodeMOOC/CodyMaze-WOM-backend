SHELL := /bin/bash

include config.env
export

DC := docker-compose -f docker-compose.yml -f docker-compose.custom.yml
DC_RUN := ${DC} run --rm

.PHONY: confirmation
confirmation:
	@echo -n 'Are you sure? [y|N] ' && read ans && [ $$ans == y ]

.PHONY: cmd
cmd:
	@echo 'Docker-Compose command:'
	@echo '${DC}'

.PHONY: up
up:
	${DC} up -d backend
	${DC} ps
	@echo
	@echo 'Service is now up'
	@echo

.PHONY: ps
ps:
	${DC} ps

.PHONY: rs
rs:
	${DC} restart

.PHONY: rebuild
rebuild:
	${DC} rm -sf backend
	${DC} up -d --build backend

.PHONY: stop
stop:
	${DC} stop

.PHONY: rm
rm rmc: stop
	${DC} rm -f

.PHONY: logs
logs:
	docker logs -f $(shell ${DC} ps -q backend)
