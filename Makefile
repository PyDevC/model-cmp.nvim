.PHONY: test lint fmt ready-commit

test:
	nvim --headless --noplugin -u scripts/minimal_init.vim -c "PlenaryBustedDirectory tests/ {minimal_init = './scripts/minimal_init.vim'}"

fmt:
	stylua lua/ --config-path=./stylua.toml

lint: 
	luacheck lua/ --globals vim

ready-commit:
	git diff
	git add -A
	git commit
