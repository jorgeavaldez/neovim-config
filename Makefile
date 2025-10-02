# Makefile for Neovim configuration linting and formatting
# Requires: stylua, selene
# Install with: cargo install stylua selene

.PHONY: help check lint format format-check format-fix fix install-tools

# Default target
.DEFAULT_GOAL := help

# Color output
CYAN := \033[36m
GREEN := \033[32m
YELLOW := \033[33m
RED := \033[31m
RESET := \033[0m

help: ## Show this help message
	@echo "$(CYAN)Neovim Config - Available Commands:$(RESET)"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-15s$(RESET) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(YELLOW)First time setup:$(RESET)"
	@echo "  Run 'make install-tools' to install stylua and selene"

install-tools: ## Install required tools (stylua, selene via cargo)
	@echo "$(CYAN)Installing linting and formatting tools...$(RESET)"
	@if ! command -v cargo &> /dev/null; then \
		echo "$(RED)Error: cargo not found. Install Rust first: https://rustup.rs/$(RESET)"; \
		exit 1; \
	fi
	cargo install stylua selene
	@echo "$(GREEN)✓ Tools installed successfully$(RESET)"

check: lint format-check ## Run all checks (lint + format check)
	@echo "$(GREEN)✓ All checks passed!$(RESET)"

lint: ## Run selene linter to check for issues
	@echo "$(CYAN)Running selene linter...$(RESET)"
	@if ! command -v selene &> /dev/null; then \
		echo "$(RED)Error: selene not found. Run 'make install-tools' first.$(RESET)"; \
		exit 1; \
	fi
	selene lua/ after/ init.lua
	@echo "$(GREEN)✓ Linting complete$(RESET)"

format-check: ## Check if files are formatted correctly (no changes)
	@echo "$(CYAN)Checking formatting with stylua...$(RESET)"
	@if ! command -v stylua &> /dev/null; then \
		echo "$(RED)Error: stylua not found. Run 'make install-tools' first.$(RESET)"; \
		exit 1; \
	fi
	stylua --check lua/ after/ init.lua
	@echo "$(GREEN)✓ Format check complete$(RESET)"

format-fix: ## Format all Lua files with stylua
	@echo "$(CYAN)Formatting Lua files with stylua...$(RESET)"
	@if ! command -v stylua &> /dev/null; then \
		echo "$(RED)Error: stylua not found. Run 'make install-tools' first.$(RESET)"; \
		exit 1; \
	fi
	stylua lua/ after/ init.lua
	@echo "$(GREEN)✓ Formatting complete$(RESET)"

format: format-fix ## Alias for format-fix

fix: format-fix ## Auto-fix all issues (currently just formatting)
	@echo "$(GREEN)✓ All auto-fixes applied!$(RESET)"

# Verify Lua typings setup
check-types: ## Verify lazydev and lua_ls are configured for Neovim typings
	@echo "$(CYAN)Checking Lua type setup...$(RESET)"
	@if grep -q "lazydev" lua/jorge/lazy.lua; then \
		echo "$(GREEN)✓ lazydev is configured$(RESET)"; \
	else \
		echo "$(YELLOW)⚠ lazydev not found in lazy.lua$(RESET)"; \
	fi
	@if grep -q "lua_ls" lua/jorge/lazy.lua; then \
		echo "$(GREEN)✓ lua_ls is referenced$(RESET)"; \
	else \
		echo "$(YELLOW)⚠ lua_ls not found in lazy.lua$(RESET)"; \
	fi
	@echo "$(CYAN)To get full Neovim API completion:$(RESET)"
	@echo "  1. Ensure lazydev.nvim is installed (check lua/jorge/lazy.lua)"
	@echo "  2. Ensure lua_ls LSP is configured"
	@echo "  3. lazydev automatically adds Neovim runtime to lua_ls library"
