.PHONY: check lint format typecheck

SRC := lua/ after/ init.lua

check: lint typecheck format-check ## Run all checks

lint: ## Lint with selene
	selene $(SRC)

typecheck: ## Typecheck with lua-language-server
	@config="$$(mktemp)" && \
		trap 'rm -f "$$config"' EXIT && \
		nvim --clean --headless --cmd 'lua local config = vim.json.decode(table.concat(vim.fn.readfile(".luarc.json"), "\n")); vim.list_extend(config.workspace.library, vim.fn.glob(vim.fn.stdpath("data") .. "/lazy/*/lua", false, true)); io.write(vim.json.encode(config))' +qa > "$$config" && \
		VIMRUNTIME="$$(nvim --clean --headless --cmd 'lua io.write(vim.env.VIMRUNTIME)' +qa 2>/dev/null)" \
		lua-language-server --check . --configpath "$$config" --logpath /tmp/nvim-config-lls-check

format: ## Format with stylua
	stylua $(SRC)

format-check: ## Check formatting (no writes)
	stylua --check $(SRC)
