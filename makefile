# makefile for online Gambit Scheme REPL.

# Copyright (c) 2020-2021 by Marc Feeley, All Rights Reserved.

# GAMBITDIR="/home/leonard/gambit/source/latest"
# GSC = $(GAMBITDIR)/gsc/gsc -:~~bin=$(srcdirpfx)$(GAMBITDIR)/bin,~~lib=$(srcdirpfx)$(GAMBITDIR)/lib,~~include=$(srcdirpfx)$(GAMBITDIR)/include

GSC=gsc
SERVE=nopython

ifeq ($(shell uname -s),Darwin)
OPEN_BROWSER = open
else
OPEN_BROWSER = xdg-open
endif

# serve: app.js
# 	@echo "===== Listening on https://localhost:4443"
# 	./https-server.py

lib/VM.js: lib/*
	cd lib && $(MAKE) GSC='$(GSC)'

serve/demo/%: demo/%
	cd $< && python2 $(PWD)/misc/https-server.py $(PWD)/misc/https-server-certificate.pem

demo/%: lib/VM.js demo/%/* .PHONY
	cd $@ && $(MAKE) GSC='$(GSC)' VM='$(PWD)/lib/VM.js'
ifeq ($(SERVE), nopython)
	cd $@ && $(OPEN_BROWSER) index.html
endif
ifeq ($(SERVE), normal)
	cd $@ && python2 $(PWD)/misc/https-server.py $(PWD)/misc/https-server-certificate.pem
endif
ifeq ($(SERVE), update)
	$(MAKE) .venv-server && . .venv-server/bin/activate && python misc/update-server.py --cwd $@ --watch "*.scm" --watch "../../lib/*.scm" --command "make SERVE=none $@" --commandcwd "../.."
endif

.PHONY: ;

# demo-reactiveButton: lib/VM.js demo/reactiveButton/*
	# cd demo/reactiveButton && $(MAKE) GSC='$(GSC)' VM='$(PWD)/lib/VM.js'
	# cd demo/reactiveButton && python2 $(PWD)/misc/https-server.py $(PWD)/misc/https-server-certificate.pem


.venv-server:
	@echo "generating virtualenv in .venv-server for update-server"
	python3 -m venv .venv-server
	. .venv-server/bin/activate && pip install livereload

test: .PHONY
	for testfile in test/*; do \
		echo "====== TESTING : " $$testfile " ======"; \
		gsi ./lib/ $$testfile; \
	done

websocket-server:
	cd misc/websocket && $(MAKE) run

#serve-update: app.js .venv
#	. .venv/bin/activate && python3 update-server.py

clean:
	cd lib && $(MAKE) clean
	for i in demo/*; do \
	   cd $(PWD)/$$i && $(MAKE) clean; \
	done
	cd misc/websocket && $(MAKE) clean

