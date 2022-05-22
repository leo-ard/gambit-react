# makefile for online Gambit Scheme REPL.

# Copyright (c) 2020-2021 by Marc Feeley, All Rights Reserved.

GAMBITDIR="/home/leonard/gambit/source/latest"
GSC = $(GAMBITDIR)/gsc/gsc -:~~bin=$(srcdirpfx)$(GAMBITDIR)/bin,~~lib=$(srcdirpfx)$(GAMBITDIR)/lib,~~include=$(srcdirpfx)$(GAMBITDIR)/include

# GSC=gsc
# srcdirpfx =

# serve: app.js
# 	@echo "===== Listening on https://localhost:4443"
# 	./https-server.py

lib/VM.js: lib/*
	cd lib && $(MAKE) GSC='$(GSC)'

demo-conceptNet: lib/VM.js demo/conceptNet/*
	cd demo/conceptNet && $(MAKE) GSC='$(GSC)' VM='$(PWD)/lib/VM.js'
	cd demo/conceptNet && python2 $(PWD)/misc/https-server.py $(PWD)/misc/https-server-certificate.pem

.venv:
	@echo "generating virtualenv in .venv for update-server"
	python3 -m virtualenv .venv
	. .venv/bin/activate && pip install livereload

#serve-update: app.js .venv
#	. .venv/bin/activate && python3 update-server.py

clean:
	cd lib && $(MAKE) clean
	for i in demo/*; do \
	   cd $$i && $(MAKE) clean; \
	done

