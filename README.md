# GambitReact

Demonstration of how to use Gambit to build web apps.

## Run demos

To run demos, simply do : 

`make demo/[my demo]`

Demos are available [here](./demo)

You can also run demos in "update mode" meaning that changes in dependencies to generate the demo will automatically reload the page. To do so, simply do : 

`make SERVE=update demo/[my demo]`

For example, to run the chat, do : 

`make SERVE=update demo/chat`
