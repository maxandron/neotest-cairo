ci:
	echo "===> Running ci"
	@make deps
	@make test
	@make fmt
	@make lint

fmt:
	echo "===> Formatting"
	stylua lua/ --config-path=stylua.toml

lint:
	echo "===> Linting"
	selene lua/

test:
	echo "===> Testing"
	@nvim -l tests/minit.lua --minitest

deps:
	@nvim -l tests/minit.lua

