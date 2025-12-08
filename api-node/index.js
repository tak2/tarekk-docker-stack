const express = require('express');
const app = express();
const port = 3000;

app.get('/', (req, res) => {
  res.json({
    message: 'Hello from Node API!',
    time: new Date().toISOString()
  });
});

app.listen(port, () => {
  console.log(`Node API listening on port ${port}`);
});
