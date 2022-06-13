// taken from here : https://stackoverflow.com/questions/3155528/can-i-broadcast-to-all-websocket-clients
const WebSocketServer = require('ws').Server;
const wss = new WebSocketServer({ port: 7777 });

wss.broadcast = function(data) {
  var date = new Date(Date.now());
  var seconds = date.getSeconds();
  var milis = date.getMilliseconds();
  var minutes = date.getMinutes();

  console.log(`[${minutes}:${minutes}.${milis}] Broadcasting to ${wss.clients.size} clients`)
  wss.clients.forEach(client => client.send(data));
};

wss.on('connection', function connection(ws){
  ws.on('message', function message(data){
    wss.broadcast(data);
  });
});

