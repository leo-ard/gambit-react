# makefile for online Gambit Scheme REPL.

# Copyright (c) 2020-2021 by Marc Feeley, All Rights Reserved.

GAMBITDIR="/home/leonard/gambit/source/latest"
GSC= $(GAMBITDIR)/gsc/gsc -:~~bin=$(srcdirpfx)$(GAMBITDIR)/bin,~~lib=$(srcdirpfx)$(GAMBITDIR)/lib,~~include=$(srcdirpfx)$(GAMBITDIR)/include

GSC=gsc

srcdirpfx =

all: app.js


main.js: main.scm
	$(GSC) -target js -label-namespace "main" -c -o main.js -e '(define (##inline-host-statement x) x)' main.scm

VM.js: VM.scm reactive.scm reactive\#.scm reactive-html\#.scm reactive-html.scm
	$(GSC) -target js -label-namespace "VM" -c -o VM.js VM.scm

app.js: VM.js main.js reactive.scm reactive-html.scm
	$(GSC) -target js -label-namespace "app" -exe -warnings -o app.js VM.js main.js

app.min.js: app.js
	npx google-closure-compiler --language_in=ECMASCRIPT_2015 --language_out=ECMASCRIPT_2015 --js app.js --js_output_file app.min.js
	sed -i.tmp -e "s/^'use strict';//" app.min.js
	gzip -k -9 app.min.js

serve: app.js
	@echo "===== Listening on https://localhost:4443"
	./https-server.py

.venv:
	@echo "generating virtualenv in .venv for update-server"
	python3 -m virtualenv .venv
	. .venv/bin/activate && pip install livereload

serve-update: app.js .venv
	. .venv/bin/activate && python3 update-server.py

clean:
	rm -f js.scm js#.scm six-expand.scm six-expand#.scm app.js main.js VM.js
