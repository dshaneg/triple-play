const http = require('http');
const os = require('os');
const config = require('../config/config.json');

const server = http.createServer((request, response) => {
  response.writeHead(200, { 'Content-Type': 'text/plain' });
  response.end(`${config.message} on host ${os.hostname()}\n`);
});

const port = 80;
server.listen(port);

console.log('Server running at http://localhost:%d', port);
