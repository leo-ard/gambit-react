all: run

.PHONY: 

node_modules/ws:
	npm install

run: node_modules/ws .PHONY
	node broadcast.js

clean:
	rm -rf node_modules package-lock.json
	

