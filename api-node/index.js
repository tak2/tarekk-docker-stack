const express = require('express');

const app = express();
const port = Number(process.env.PORT) || 3000;
const startedAt = new Date();

app.get('/', (_req, res) => {
  res.json({
    message: 'Hello from Node API!',
    time: new Date().toISOString()
  });
});

app.get('/health', (_req, res) => {
  res.json({
    status: 'ok',
    service: 'node-api',
    startedAt: startedAt.toISOString(),
    uptimeSeconds: Math.round(process.uptime())
  });
});

app.listen(port, () => {
  console.log(`Node API listening on port ${port}`);
});
