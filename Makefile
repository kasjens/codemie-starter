.PHONY: install check cli-only setup doctor

install: ## Install CodeMie CLI + upgrade supported agents + health check
	./install.sh

check: ## Health check only, change nothing
	./install.sh --check

cli-only: ## Install the CLI only, skip agent upgrades
	./install.sh --no-agents

setup: ## Configure the active CodeMie profile
	codemie setup

doctor: ## Re-run the CodeMie health check
	codemie doctor

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN{FS=":.*?## "}{printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2}'
