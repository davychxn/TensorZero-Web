const express = require('express');
const { createProxyMiddleware } = require('http-proxy-middleware');

const app = express();

// CORS middleware to handle preflight requests
app.use((req, res, next) => {
  res.header('Access-Control-Allow-Origin', '*');
  res.header('Access-Control-Allow-Methods', 'GET,PUT,POST,DELETE,OPTIONS');
  res.header('Access-Control-Allow-Headers', 'Content-Type, Authorization, Content-Length, X-Requested-With');
  
  // Intercept OPTIONS method
  if ('OPTIONS' === req.method) {
    res.sendStatus(200);
  } else {
    next();
  }
});

// Proxy middleware options
const options = {
  target: 'http://localhost:3000', // target host
  changeOrigin: true, // needed for virtual hosted sites
};

// Create the proxy
const proxy = createProxyMiddleware(options);

// Use the proxy middleware
app.use('/api', proxy);

// Start the server
const PORT = 4000;
app.listen(PORT, () => {
  console.log(`Proxy server is running on http://localhost:${PORT}`);
});