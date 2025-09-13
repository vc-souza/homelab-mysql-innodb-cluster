ENTRYPOINT_NODE ?= node-1
LEADER_NODE ?= node-1

.PHONY: all
all: run

config.json:
	@cp config.json.template config.json

.env: config.json
	@./scripts/host/gen/gen_env.sh

secrets/db/repl/pass.txt: config.json
	@./scripts/host/gen/gen_secrets.sh

secrets/db/root/pass.txt: config.json
	@./scripts/host/gen/gen_secrets.sh

cnf/node-1.cnf: config.json
	@./scripts/host/gen/gen_conf.sh

cnf/node-2.cnf: config.json
	@./scripts/host/gen/gen_conf.sh

cnf/node-3.cnf: config.json
	@./scripts/host/gen/gen_conf.sh

.PHONY: install
install: .env config.json
install: cnf/node-1.cnf cnf/node-2.cnf cnf/node-3.cnf
install: secrets/db/repl/pass.txt secrets/db/root/pass.txt
	@./scripts/host/bootstrap.sh $(LEADER_NODE)

.PHONY: uninstall
uninstall:
	@docker compose down -v || true
	@rm -f ./conf/node-*.cnf
	@rm -f config.json
	@rm -f .env
	@rm -f secrets/db/repl/pass.txt
	@rm -f secrets/db/root/pass.txt

.PHONY: run
run:
	@./scripts/host/restore.sh $(LEADER_NODE)

.PHONY: stop
stop: 
	@docker compose down

.PHONY: logs
logs:
	@docker compose logs -f

.PHONY: monitor
monitor:
	@./scripts/host/monitor.sh $(ENTRYPOINT_NODE)

.PHONY: create_user
create_user:
	@./scripts/host/dba/users/create.sh
