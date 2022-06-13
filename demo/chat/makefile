all: app.js main.js

main.js: main.scm
	$(GSC) -target js -label-namespace "main" -c -o main.js -e '(define (##inline-host-statement x) x)' main.scm

app.js: main.js $(VM)
	$(GSC) -target js -label-namespace "app" -exe -warnings -o app.js $(VM) main.js

clean: 
	rm -f app.js main.js index.generated.html

