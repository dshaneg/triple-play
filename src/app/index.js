const http = require('http');
const os = require('os');
const bunyan = require('bunyan');
const config = require('../../config/config.json');

const log = bunyan.createLogger({ name: 'double-tap' });

const server = http.createServer((request, response) => {
  response.writeHead(200, { 'Content-Type': 'text/plain' });
  response.end(`${config.message} on host ${os.hostname()}\n`);
});

server.listen(config.port);

log.info('Server running at http://localhost:%d', config.port);
