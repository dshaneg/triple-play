import { createServer } from 'http';
import { hostname } from 'os';
import { message } from '../config/config.json';

const server = createServer((request, response) => {
  response.writeHead(200, { 'Content-Type': 'text/plain' });
  response.end(`${message} on host ${hostname()}\n`);
});

const port = 80;
server.listen(port);

console.log('Server running at http://localhost:%d', port);
