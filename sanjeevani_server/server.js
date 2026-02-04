const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const { Kafka } = require('kafkajs');
const mongoose = require('mongoose');

const app = express();
app.use(express.json());
app.use(cors());
app.use(bodyParser.json());

/* =========================
   MongoDB Connection
========================= */
mongoose
  .connect('mongodb://127.0.0.1:27017/sanjeevani_db')
  .then(() => console.log('✅ MongoDB Connected'))
  .catch((err) => console.error('❌ MongoDB Connection Error', err));

/* =========================
   Kafka Setup
========================= */
const kafka = new Kafka({
  clientId: 'sanjeevani-server',
  brokers: ['localhost:9092'],
});

const producer = kafka.producer();

const connectKafka = async () => {
  try {
    await producer.connect();
    console.log('✅ Kafka Producer Connected');
  } catch (error) {
    console.error('❌ Kafka Connection Failed', error);
  }
};

connectKafka();

/* =========================
   Routes
========================= */
app.get('/', (req, res) => {
  res.send('Sanjeevani Server is Running');
});

/* =========================
   MongoDB Schema
========================= */
const bloodRequestSchema = new mongoose.Schema({
  name: String,
  bloodType: String,
  units: Number,
  contact: String,
  hospital: String,
  city: String,
  location: {
    latitude: Number,
    longitude: Number,
  },
  timestamp: String,
});

const BloodRequest = mongoose.model('BloodRequest', bloodRequestSchema);

/* =========================
   Blood Request → Kafka + MongoDB
========================= */
app.post('/blood-request', async (req, res) => {
  const {
    name,
    bloodType,
    units,
    contact,
    hospital,
    city,
    latitude,
    longitude,
  } = req.body;

  console.log('📥 Received Blood Request:', req.body);

  if (
    !name ||
    !bloodType ||
    !units ||
    !contact ||
    !hospital ||
    !city ||
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
    hospital,
    city,
    location: {
      latitude,
      longitude,
    },
    timestamp: new Date().toISOString(),
  };

  try {
    // 🔹 Save to MongoDB
    const request = new BloodRequest(payload);
    await request.save();
    console.log('✅ Blood request saved to MongoDB');

    // 🔹 Send to Kafka
    await producer.send({
      topic: 'blood-requests',
      messages: [{ value: JSON.stringify(payload) }],
    });

    console.log('✅ Blood request sent to Kafka');

    res.status(200).json({
      message: 'Blood request saved & sent successfully',
      data: payload,
    });
  } catch (error) {
    console.error('❌ Error:', error);
    res.status(500).json({ message: 'Internal Server Error' });
  }
});

/* =========================
   Appointment Booking
========================= */
app.post('/book-appointment', (req, res) => {
  const { name, phone, date, cartItems } = req.body;

  if (!name || !phone || !date || !cartItems) {
    return res.status(400).json({ message: 'Missing required fields' });
  }

  res.status(200).json({
    message: 'Appointment booked successfully!',
    data: req.body,
  });
});

/* =========================
   Server Start
========================= */
const PORT = 3000;
app.listen(PORT, () =>
  console.log(`✅ Server running on port ${PORT}`)
);