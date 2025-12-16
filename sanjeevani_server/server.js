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
  const { name, bloodGroup, hospital, contact } = req.body;
  console.log('Received Blood Request:', req.body);

  res.status(200).json({
    message: 'Blood request received successfully!',
    data: req.body,
  });
});

const PORT = 3000;
app.listen(PORT, () => console.log(`✅ Server running on port ${PORT}`));
