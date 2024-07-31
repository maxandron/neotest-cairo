ci:
	echo "===> Running ci"
	@make deps/mini.nvim
	@make fmt
	@make lint
	@make test

fmt:
	echo "===> Formatting"
	stylua lua/ --config-path=stylua.toml

lint:
	echo "===> Linting"
	selene lua/

test: deps/mini.nvim
	echo "===> Testing"
	nvim --headless --noplugin -u ./scripts/minimal_init.lua -c "lua MiniTest.run()"

deps: deps/mini.nvim deps/neotest deps/nvim-nio deps/nvim-treesitter deps/plenary.nvim

deps/mini.nvim:
	echo "===> Cloning mini.nvim"
	@mkdir -p deps
	git clone --filter=blob:none https://github.com/echasnovski/mini.nvim $@

deps/neotest:
	echo "===> Cloning neotest"
	@mkdir -p deps
	git clone --filter=blob:none https://github.com/nvim-neotest/neotest $@

deps/nvim-nio:
	echo "===> Cloning nvim-nio"
	@mkdir -p deps
	git clone --filter=blob:none https://github.com/nvim-neotest/nvim-nio $@

deps/nvim-treesitter:
	echo "===> Cloning nvim-treesitter"
	@mkdir -p deps
	git clone --filter=blob:none https://github.com/nvim-treesitter/nvim-treesitter $@

deps/plenary.nvim:
	echo "===> Cloning plenary.nvim"
	@mkdir -p deps
	git clone --filter=blob:none https://github.com/nvim-lua/plenary.nvim $@
