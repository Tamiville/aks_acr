var express = require('express');
var app = express();

app.get('/', function (req, res) {
  res.send('!Hello World/n santa must be dead cuz I didnt get any present this xmas!');
});

var server = app.listen(3000, function () {
  var host = server.address().address;
  var port = server.address().port;

  console.log('Example app listening on port %s', port);
});