# Assumes GSC is passed as argument

all: VM.js

VM.js: VM.scm reactive.scm reactive\#.scm reactive-html\#.scm reactive-html.scm
	$(GSC) -target js -label-namespace "VM" -c -o VM.js VM.scm

#app.js: VM.js main.js reactive.scm reactive-html.scm
#	$(GSC) -target js -label-namespace "app" -exe -warnings -o app.js VM.js main.js

#app.min.js: app.js
#	npx google-closure-compiler --language_in=ECMASCRIPT_2015 --language_out=ECMASCRIPT_2015 --js app.js --js_output_file app.min.js
#	sed -i.tmp -e "s/^'use strict';//" app.min.js
#	gzip -k -9 app.min.js


clean: 
	rm -f VM.js

