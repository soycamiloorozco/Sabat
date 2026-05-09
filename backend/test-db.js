import pg from 'pg';

const client = new pg.Client({
  user: 'postgres.dyoegznlygzjtwmaqipk',
  host: 'aws-1-us-east-1.pooler.supabase.com',
  database: 'postgres',
  password: 'Sabat2026PW',
  port: 5432,
  ssl: { rejectUnauthorized: false }
});

try {
  await client.connect();
  console.log("Connected successfully!");
  await client.end();
} catch (err) {
  console.error("Connection failed:", err.message);
}
