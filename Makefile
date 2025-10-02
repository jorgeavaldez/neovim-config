.PHONY: check lint format typecheck

SRC := lua/ after/ init.lua

check: lint typecheck format-check ## Run all checks

lint: ## Lint with selene
	selene $(SRC)

typecheck: ## Typecheck with lua-language-server
	lua-language-server --check . --logpath /tmp/nvim-config-lls-check

format: ## Format with stylua
	stylua $(SRC)

format-check: ## Check formatting (no writes)
	stylua --check $(SRC)
