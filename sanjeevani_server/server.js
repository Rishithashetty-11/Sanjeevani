const express = require('express');
const cors = require('cors');
const { Kafka } = require('kafkajs');
const mongoose = require('mongoose');

const app = express();
app.use(express.json());
app.use(cors());

/* =========================
   MongoDB Connection
========================= */
mongoose
  .connect('mongodb://127.0.0.1:27017/sanjeevani_db')
  .then(() => console.log('✅ MongoDB Connected'))
  .catch((err) => console.error('❌ MongoDB Connection Error:', err));

/* =========================
   Kafka Setup
========================= */
const kafka = new Kafka({
  clientId: 'sanjeevani-server',
  brokers: ['localhost:9092'], // use same everywhere
});

const producer = kafka.producer();

/* =========================
   MongoDB Schema
========================= */
const bloodRequestSchema = new mongoose.Schema({
  name: String,
  bloodType: String,
  units: Number,
  contact: String,
  urgency: String,
  location: {
    latitude: Number,
    longitude: Number,
  },
  timestamp: String,
});

const BloodRequest = mongoose.model('BloodRequest', bloodRequestSchema);

/* =========================
   Routes
========================= */
app.get('/', (req, res) => {
  res.send('Sanjeevani Server is Running');
});

/* =========================
   Blood Request → Kafka + MongoDB
========================= */
app.post('/blood-request', async (req, res) => {
  const {
    name,
    bloodType,
    units,
    contact,
    urgency,
    latitude,
    longitude,
  } = req.body;

  console.log('📥 Received Blood Request:', req.body);

  if (
    !name ||
    !bloodType ||
    !units ||
    !contact ||
    !urgency||
    latitude === undefined ||
    longitude === undefined
  ) {
    return res.status(400).json({ message: 'Missing required fields' });
  }

  const payload = {
    name,
    bloodType,
    units,
    contact,
    urgency,
    location: {
      latitude,
      longitude,
    },
    timestamp: new Date().toISOString(),
  };

  /* 🔹 1️⃣ Send to Kafka FIRST */
  try {
    await producer.send({
      topic: 'blood-requests',
      messages: [{ value: JSON.stringify(payload) }],
    });

    console.log('✅ Blood request sent to Kafka');
  } catch (error) {
    console.error('❌ Kafka Send Error:', error);
  }

  /* 🔹 2️⃣ Save to MongoDB (separate) */
  try {
    const request = new BloodRequest(payload);
    await request.save();
    console.log('✅ Blood request saved to MongoDB');
  } catch (error) {
    console.error('❌ MongoDB Save Error:', error);
  }

  res.status(200).json({
    message: 'Blood request processed',
    data: payload,
  });
});

/* =========================
   Server Start (Kafka first)
========================= */
const PORT = 3000;

const startServer = async () => {
  try {
    await producer.connect();
    console.log('✅ Kafka Producer Connected');

    app.listen(PORT, () =>
      console.log(`✅ Server running on port ${PORT}`)
    );
  } catch (error) {
    console.error('❌ Kafka Connection Failed:', error);
  }
};

startServer();
