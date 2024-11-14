const express = require('express');
var cors = require('cors')
const app = express();
app.use(cors())
const PORT = 8080; // Define the port
const db_utility = require('./mongodb-utility.js')
const bodyParser = require('body-parser');
const jsonParser = bodyParser.json();
const CORS_ALLOWED_CLIENT = 'assignment3-439821.wl.r.appspot.com';


//Geocoding API
app.get('/backend/coordinates', async (req, res) => {
  let address = req.query.address;
  let state = req.query.state;
  let full_address = `${address} ${state}`;
  try {
    const response = await fetch(`https://maps.googleapis.com/maps/api/geocode/json?address=${encodeURIComponent(full_address)}&extra_computations=ADDRESS_DESCRIPTORS&key=AIzaSyAig7i8JmSejtz8_rdpaDOdcFj4JOxU130`);
    const data = await response.json();
    res.json(data);
  } catch (error) {
    console.error('Error fetching IP info:', error);
    res.status(500).send('Error fetching IP information');
  }
});

app.get('/backend/autocomplete', async (req, res) => {
  let input = req.query.input;
  try {
    const response = await fetch(`https://maps.googleapis.com/maps/api/place/autocomplete/json?input=${encodeURIComponent(input)}&types=locality&key=AIzaSyCzxQQwEMY-kUDuQ_Cz8-7uoXhu8BlhnHA`);
    const data = await response.json();
    res.json(data);
  } catch (error) {
    console.error('Error fetching IP info:', error);
    res.status(500).send('Error fetching IP information');
  }
});

//tomorrow.io API
app.get('/backend/weather', async (req, res) => {
  let coordinates = req.query.coordinates;
  console.log(coordinates);
  let timesteps = req.query.timesteps;
  let weatherDataFields = req.query.weatherDataFields;
  console.log(weatherDataFields);
  let startTime = req.query.startTime;
  let endTime = req.query.endTime;

  const payload = {
    location: coordinates,
    fields: weatherDataFields,
    units: "imperial",
    timesteps: [timesteps],
    timezone: "America/Los_Angeles"
  };

  if (startTime)
    payload['startTime'] = startTime

  if (endTime)
    payload['endTime'] = endTime

  const options = {
    method: 'POST',
    headers: {
      accept: 'application/json',
      'Accept-Encoding': 'gzip',
      'content-type': 'application/json'
    },
    body: JSON.stringify(payload)
  };

  try {
    const response = await fetch('https://api.tomorrow.io/v4/timelines?apikey=lNBRMU7oRzjQAqhOU4qn1YNOOZWXnXit', options)
    const data = await response.json();
    res.json(data);
  } catch (error) {
    console.error('Error fetching IP info:', error);
    res.status(500).send('Error fetching IP information');
  }
});

//add favorite city API
app.post('/backend/add-favorite-city', jsonParser, (req, res) => {
  console.log("Received add request");
  const address = req.body;
  db_utility.addFavoriteAddress(address)
  res.json({
    message: 'New city was added to the list',
  });
});

//delete favorite city API
app.delete('/backend/delete-favorite-city/:city', async function (req, res) {

  const city = req.params.city;
  list = await db_utility.deleteFavoriteAddress(city)
  res.json(list);
});

//show the list of favorite city
app.get('/backend/list-favorite-cities', async function (req, res) {

  list = await db_utility.listFavoriteAddresses()
  console.log("In controller")
  console.log("in promis: " + list)

  res.send(list);
});


app.listen(PORT, () => {
  console.log(`Server running on ${PORT}`);
});


