ifndef LIGO
	LIGO = docker run --rm -v "${PWD}":"${PWD}" -w "${PWD}" ligolang/ligo:0.57.0
endif

default: help

compile = $(LIGO) compile contract ./src/contracts/$(1) -o ./src/compiled/$(2) $(3)

help:
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@echo "  compile - Compile the contract"
	@echo "  clean   - Clean the compiled files"

compile:
	@echo "Compiling contract..."
	@$(call compile,mainrendu.mligo,main.tz)
	@$(call compile,mainrendu.mligo,main.json,--michelson-format json)
	@echo "Compiling contract... Done"

test-ligo = $(LIGO) run test ./src/tests/$(1)
test:
	@echo "Compiling contract..."
	@$(call test-ligo,contract1_test.mligo)
	@echo "Compiling contract... Done"

clean:
	@echo "Cleaning..."
	@rm -rf ./src/compiled/*
	@echo "Cleaning... Done"

deploy-contract:
	@echo "Deploying contract..."
	@npm run deploy

sandbox-start:
	@./scripts/run-sandbox.sh

sandbox-stop:
	@./scripts/stop-sandbox.sh