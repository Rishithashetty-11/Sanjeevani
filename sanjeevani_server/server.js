const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');

const app = express();
app.use(cors());
app.use(bodyParser.json());

app.get('/', (req, res) => {
  res.send('Sanjeevani Server is Running');
});

app.post('/blood-request', (req, res) => {
  // Updated to match the fields sent from the Flutter app
  const { name, bloodType, units, contact, purpose } = req.body;
  console.log('Received Blood Request:', req.body);

  // Basic validation to ensure required fields are present
  if (!name || !bloodType || !units || !contact || !purpose) {
    return res.status(400).json({ message: 'Missing required fields' });
  }

  res.status(200).json({
    message: 'Blood request received successfully!',
    data: req.body,
  });
});

app.post('/book-appointment', (req, res) => {
  const { name, phone, date, cartItems } = req.body;
  console.log('Received Appointment Booking:', req.body);

  if (!name || !phone || !date || !cartItems) {
    return res.status(400).json({ message: 'Missing required fields' });
  }

  res.status(200).json({
    message: 'Appointment booked successfully!',
    data: req.body,
  });
});

const PORT = 3000;
app.listen(PORT, () => console.log(`✅ Server running on port ${PORT}`));
