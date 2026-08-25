const express = require('express');
const { Client } = require('pg');
require('dotenv').config();

const app = express();
const port = 3000;

const client = new Client({
  user: process.env.DB_USER,
  host: process.env.DB_HOST,
  database: process.env.DB_NAME,
  password: process.env.DB_PASSWORD,
  port: process.env.DB_PORT,
});

async function startServer() {
  try {
    await client.connect();
    console.log('Connected to PostgreSQL');

    app.get('/', (req, res) => {
      res.send('Hello World!');
    });

    app.get('/health', (req, res) => {
      res.send('Healthy GET status 200');
    });

    app.get('/db-test', async (req, res) => {
      try {
        const result = await client.query(
          'SELECT $1::int AS number',
          [1]
        );

        res.json({
          number: result.rows[0].number,
        });
      } catch (error) {
        console.error(error);
        res.status(500).send('Database error');
      }
    });

    app.listen(port, () => {
      console.log(`Server running at http://localhost:${port}`);
    });
  } catch (error) {
    console.error('Failed to connect to PostgreSQL:', error);
  }
}

startServer();