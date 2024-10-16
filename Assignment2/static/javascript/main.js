//creating a mapping for the weather code along with the status
weatherCard = {
  "0": "Unknown",
  "1000": "Clear, Sunny",
  "1001": "Cloudy",
  "1100": "Mostly Clear",
  "1101": "Partly Cloudy",
  "1102": "Mostly Cloudy",
  "2000": "Fog",
  "2100": "Light Fog",
  "4000": "Drizzle",
  "4001": "Rain",
  "4200": "Light Rain",
  "4201": "Heavy Rain",
  "5000": "Snow",
  "5001": "Flurries",
  "5100": "Light Snow",
  "5101": "Heavy Snow",
  "6000": "Freezing Drizzle",
  "6001": "Freezing Rain",
  "6200": "Light Freezing Rain",
  "6201": "Heavy Freezing Rain",
  "7000": "Ice Pellets",
  "7101": "Heavy Ice Pellets",
  "7102": "Light Ice Pellets",
  "8000": "Thunderstorm"
  };

  //mapping for the precipitation status based on the value in the data field
  precipitationType = {
      "0": "N/A",
      "1": "Rain",
      "2": "Snow",
      "3": "Freezing Rain",
      "4": "Ice Pellets"
  };


//checking the checkbox status
let checkbox = document.getElementById("getGeolocation");
checkbox.addEventListener('change', function() {
  if (this.checked) {
    document.getElementById("addressForm").reset();
    document.getElementById("street").disabled = true;
    document.getElementById("city").disabled = true;
    document.getElementById("state").disabled = true;
    document.getElementById("getGeolocation").checked = true;
  } else {
    document.getElementById("street").disabled = false;
    document.getElementById("city").disabled = false;
    document.getElementById("state").disabled = false;
  }
});

//applying eventlistner on submit button
//also applying validation on the form 
document.getElementById('submitbtn').addEventListener('click', function () {
  var form = document.getElementById('addressForm');
  if (form.checkValidity()) {
    document.getElementById("weather-info").hidden = true;
    document.getElementById("weeklyWeatherData").hidden = true;
    document.getElementById("dailyWeatherDetail").hidden = true;
    document.getElementById("temperatureGraph").hidden = true;
    document.getElementById("hourlyGraph").hidden = true;
    document.getElementById("upArrow").hidden = true;
  
    document.getElementById("noRecordFound").hidden = true;
    var tableId = document.getElementById('weeklyWeatherData');
    var tBody = tableId.getElementsByTagName('tbody')[0];
    tBody.innerHTML='';
      // If form is valid, submit the form or trigger your weather fetching logic
    loadWeatherCard();
  } else {
      // If form is not valid, manually trigger validation message display
      form.reportValidity();
  }
});

//Clicking the clear button should clear the entire canvas
var clearCanvas = function () {
  
  document.getElementById("addressForm").reset();
  document.getElementById("weather-info").hidden = true;
  document.getElementById("weeklyWeatherData").hidden = true;
  document.getElementById("dailyWeatherDetail").hidden = true;
  document.getElementById("temperatureGraph").hidden = true;
  document.getElementById("hourlyGraph").hidden = true;
  document.getElementById("upArrow").hidden = true;

  document.getElementById("noRecordFound").hidden = true;
  var tableId = document.getElementById('weeklyWeatherData');
  var tBody = tableId.getElementsByTagName('tbody')[0];
  tBody.innerHTML='';
  document.getElementById("street").disabled = false;
  document.getElementById("city").disabled = false;
  document.getElementById("state").disabled = false;
};

//applying eventlistener on clear button
document.getElementById('clearBtn').addEventListener('click', clearCanvas);


//fetching the coordinates for the location using google geocoding API
//if the checkbox is checked then use the ipinfo API to fetch the location coordinates
//otherwise use the geocoding API to get the street, city, and state and getting the coordinates
function loadWeatherCard(){
    
  var xhttp = new XMLHttpRequest();
  
  var checkBox = document.getElementById("getGeolocation");
  
  if (checkBox.checked == true){
    xhttp.onreadystatechange = function(){
      if (this.readyState == 4 && this.status == 200){
        coordinate_response = JSON.parse(xhttp.responseText)
        const location = coordinate_response.loc;
        document.getElementById("coordinates").value = location;
        document.getElementById("weathercardAddress").innerHTML = coordinate_response.city + ", " + coordinate_response.region;
        loadWeatherCardData(location);
        loadWeatherCardDailyData(location);

      }
    };
    xhttp.open("GET", "/geolocationCoordinate", true);
    xhttp.send();
  } else {
    
    var street = document.getElementById("street").value;
    var city = document.getElementById("city").value;
    var state = document.getElementById("state").value;
    
    var address = street.concat(" ",city)
    xhttp.onreadystatechange = function(){
      if (this.readyState == 4 && this.status == 200){
        coordinate_response = JSON.parse(xhttp.responseText)
        const coordinates = coordinate_response.results[0].geometry.location;
        const latitude = coordinates.lat;
        const longitude = coordinates.lng;
        var location = "".concat(latitude,",",longitude);
        loadWeatherCardData(location);
        loadWeatherCardDailyData(location);
        document.getElementById("coordinates").value = location;
        document.getElementById("weathercardAddress").innerHTML = coordinate_response.results[0].formatted_address;

      }
    };
    xhttp.open("GET", "/coordinates?address="+address+"&state="+state, true);
    xhttp.send();
  }
  
}

//fetching the weather card details 
//based on the coordinates fetch the weather data from the tomorrow.io API 
//if some random/bogus street and city is given
//it still fetches the state and gives the weather data of that state
function loadWeatherCardData(coordinates) {
    var xhttp = new XMLHttpRequest();
  
    xhttp.onreadystatechange = function() {
      if (this.readyState == 4 && this.status == 200) {
        // document.getElementById("demo").innerHTML = this.responseText;
        // const xhr = new XMLHttpRequest();
        var weather_response = JSON.parse(xhttp.responseText)
        if("Too Many Calls" == weather_response.type){
            document.getElementById("noRecordFound").hidden = false;
            return;
        }
        document.getElementById("noRecordFound").hidden = true;
        const weatherData = weather_response.data.timelines[0].intervals[0].values;
        const temperature = weatherData.temperature;
        const humidity = weatherData.humidity;
        const pressure = weatherData.pressureSeaLevel;
        const wind_speed = weatherData.windSpeed;
        const visibility = weatherData.visibility;
        const cloud_cover = weatherData.cloudCover;
        const uv_= weatherData.uvIndex;
        const weatherCode = weatherData.weatherCode; 

        // Display the weather information without the respective image
        document.getElementById("humidity").innerHTML = `<p>${humidity}%</p>`;
        document.getElementById("pressure").innerHTML = `<p>${pressure} inHg</p>`;
        document.getElementById("wind_speed").innerHTML = `<p>${wind_speed} mph</p>`;
        document.getElementById("visibility").innerHTML = `<p>${visibility}mi</p>`;
        document.getElementById("cloud_cover").innerHTML = `<p>${cloud_cover}%</p>`;
        document.getElementById("uv_level").innerHTML = `<p>${uv_}</p>`;
        document.getElementById("temperature").innerHTML = `${temperature}&deg;`;
        document.getElementById("weatherConditionName").innerHTML = `<span>${weatherCard[weatherCode]}</span>`;
        document.getElementById("weatherConditionIcon").src = `static/image/WeatherSymbolsforWeatherCodes/${weatherCode}.svg`;
        
        document.getElementById("weather-info").hidden = false;



      }
    };
    var weatherDataFields = ["temperature","temperatureApparent","temperatureMin","temperatureMax","windSpeed","windDirection","humidity","pressureSeaLevel","uvIndex","weatherCode","precipitationProbability","precipitationType","visibility","cloudCover"]; 
    xhttp.open("GET", "/weather?coordinates="+coordinates+"&timesteps=1h&weatherDataFields="+JSON.stringify(weatherDataFields), true);
    xhttp.send();
}

//formating the date for the table in the desired format
function formatDate(dateString) {
  const date = new Date(dateString);
  
  // Get the components of the date
  const options = { weekday: 'long', year: 'numeric', month: 'short', day: 'numeric' };
  const weekday = date.toLocaleDateString('en-US', { weekday: 'long' });
  const day = date.getDate(); // Get day of the month
  const month = date.toLocaleDateString('en-US', { month: 'short' });
  const year = date.getFullYear(); // Get full year

  // Construct the formatted date string
  return `${weekday}, ${day} ${month} ${year}`;
}

//loading the daily details in the table 
//We take the daily of whole day and display it for the waether fields as instructed
function loadWeatherCardDailyData(coordinates) {
  var xhttp = new XMLHttpRequest();
  xhttp.onreadystatechange = function() {
    if (this.readyState == 4 && this.status == 200) {
      // document.getElementById("demo").innerHTML = this.responseText;
      // const xhr = new XMLHttpRequest();
      var weather_response = JSON.parse(xhttp.responseText);
      if("Too Many Calls" == weather_response.type){
        document.getElementById("noRecordFound").hidden = false;
        return;
      }
      document.getElementById("noRecordFound").hidden = true;

      const intervals = weather_response.data.timelines[0].intervals;
      var weeklyWeatherData = document.getElementById("weeklyWeatherData");
      var tBody = weeklyWeatherData.getElementsByTagName('tbody')[0];
      intervals.forEach(element => {
        let newRow = tBody.insertRow(-1);
        newRow.className= "tableRow";

        var createClickHandler = function(row) {
          return function() {
            weeklyWeatherData.hidden=true;
            document.getElementById("weather-info").hidden = true;
            loadDailyWeatherDetails(coordinates,element.startTime);
          };
        };
        newRow.onclick = createClickHandler(newRow);

        // Format the date
        let formattedDate = formatDate(element.startTime); // Use the custom formatDate function

        let dateCell = newRow.insertCell(0);
        dateCell.innerText = formattedDate; // Use the formatted date
        let status = newRow.insertCell(1);
        var image = document.createElement('img');
        image.src=`static/image/WeatherSymbolsforWeatherCodes/${element.values.weatherCode}.svg`;
        image.style.height="70px";
        image.style.verticalAlign = "middle"; 
        status.appendChild(image);
        var statusText = document.createTextNode(`${weatherCard[element.values.weatherCode]}`);
        status.appendChild(statusText);

        let tempHigh = newRow.insertCell(2);
        tempHigh.innerText=element.values.temperatureMax;
        let tempLow = newRow.insertCell(3);
        tempLow.innerText=element.values.temperatureMin;
        let windSpeed = newRow.insertCell(4);
        windSpeed.innerText=element.values.windSpeed;
      });
      weeklyWeatherData.hidden=false;
      


    }
  };
  var weatherDataFields = ["temperature","temperatureApparent","temperatureMin","temperatureMax","windSpeed","windDirection","humidity","pressureSeaLevel","uvIndex","weatherCode","precipitationProbability","precipitationType","visibility","cloudCover"]; 
  xhttp.open("GET", "/weather?coordinates="+coordinates+"&timesteps=1d&weatherDataFields="+JSON.stringify(weatherDataFields), true);
  xhttp.send();
} 



function formatTime(timeString) {
  const date = new Date(timeString);
  
  
  let hours = date.getHours();
  const minutes = date.getMinutes();
  const ampm = hours >= 12 ? 'PM' : 'AM';

  
  hours = hours % 12;
  hours = hours ? hours : 12; 
  const minutesString = minutes < 10 ? '0' + minutes : minutes;

  return `${hours}:${minutesString} ${ampm}`;
}

//Clicking on the daily details should direct to this card
//this card contains the weather details of the selected day
function loadDailyWeatherDetails(coordinates,startTime) {
  var xhttp = new XMLHttpRequest();

  xhttp.onreadystatechange = function() {
    if (this.readyState == 4 && this.status == 200) {
      var weather_response = JSON.parse(xhttp.responseText);
      if("Too Many Calls" == weather_response.type){
        document.getElementById("noRecordFound").hidden = false;
        return;
      }
      document.getElementById("noRecordFound").hidden = true;
      const weatherData = weather_response.data.timelines[0].intervals[0].values;
      const formattedDate = formatDate(startTime);
      document.getElementById("dailyWeatherDetailDate").innerHTML = formattedDate;
      document.getElementById("dailyWeatherDetailStatus").innerHTML = `${weatherCard[weatherData.weatherCode]}`;
      document.getElementById("dailyWeatherDetailTemperature").innerHTML = `${weatherData.temperatureMin}°F/${weatherData.temperatureMax}°F`;
      document.getElementById("dailyWeatherDetailText").innerHTML = `<div><span>Precipitation</span>: <span>${precipitationType[weatherData.precipitationType]}</span></div>`;
      document.getElementById("dailyWeatherDetailText").innerHTML += `<div><span>Chance of Rain</span>: <span>${weatherData.precipitationProbability}%</span></div>`;
      document.getElementById("dailyWeatherDetailText").innerHTML += `<div><span>Wind Speed</span>: <span>${weatherData.windSpeed}mph</span></div>`;
      document.getElementById("dailyWeatherDetailText").innerHTML += `<div><span>Humidity</span>: <span>${weatherData.humidity}%</span></div>`;
      document.getElementById("dailyWeatherDetailText").innerHTML += `<div><span>Visibility</span>: <span>${weatherData.visibility} mi</span></div>`;
      document.getElementById("dailyWeatherDetailText").innerHTML += `<div><span>Sunrise/Sunset</span>: <span>${formatTime(weatherData.sunriseTime)}/${formatTime(weatherData.sunsetTime)}</span></div>`;

      document.getElementById("dailyWeatherDetailDateIcon").src = `static/image/WeatherSymbolsforWeatherCodes/${weatherData.weatherCode}.svg`;
      

      
      const dailyWeatherDetail = document.getElementById('dailyWeatherDetail');
      dailyWeatherDetail.hidden = false;
      dailyWeatherDetail.focus();
      dailyWeatherDetail.scrollIntoView({ behavior: 'auto' });
        
      document.getElementById("downArrow").hidden = false;
    }
  };
  var weatherDataFields = ["temperature","temperatureApparent","temperatureMin","temperatureMax","windSpeed","windDirection","humidity","pressureSeaLevel","uvIndex","weatherCode","precipitationProbability","precipitationType","visibility","cloudCover","sunriseTime","sunsetTime"]; 
  xhttp.open("GET", "/weather?coordinates="+coordinates+"&timesteps=1d&weatherDataFields="+JSON.stringify(weatherDataFields)+"&startTime="+startTime, true);
  xhttp.send();
}

//clicking the downarrow should display the charts
function onDownArrowClick(downArrowElement) {
  displayTemperatureGraph(downArrowElement);
  displayHourlyData(downArrowElement);
} 

//first the temperature range graph is shown
//highchart is used to display the data feteched from weather API
//the data fields required are max temperature and min temperature
function displayTemperatureGraph(downArrowElement){
  var xhttp = new XMLHttpRequest();
  xhttp.onreadystatechange = function(){
    if (this.readyState == 4 && this.status == 200){
      temperatureRange = []
      const intervals = JSON.parse(xhttp.responseText).data.timelines[0].intervals;
      intervals.forEach(element => {
        var chartElement = [Date.parse(element.startTime),element.values.temperatureMin,element.values.temperatureMax];
        temperatureRange.push(chartElement);
      });

      //clicking the down arrow should display the graph 
      //we should get up arrow instead of down arrow here
      downArrowElement.hidden = true;
      document.getElementById("upArrow").hidden = false;

      // Set margin-left and margin-right for the chart container
      document.getElementById("temperatureGraph").style.marginLeft = "320px"; 
  
      Highcharts.chart('temperatureGraph', {
        chart: {
            type: 'arearange',
            zooming: {
                type: 'x'
            },
            scrollablePlotArea: {
                minWidth: 600,
                scrollPositionX: 1
            }
        },
        title: {
            text: 'Temperature Ranges (Min, Max)'
        },
        xAxis: {
            type: 'datetime',
            accessibility: {
                rangeDescription: 'Range: Jan 1st 2017 to Dec 31 2017.'
            }
        },
        yAxis: {
            title: {
                text: null
            }
        },
        tooltip: {
            crosshairs: true,
            shared: true,
            valueSuffix: '°F',
            xDateFormat: '%A, %b %e'
        },
        legend: {
            enabled: false
        },
        series: [{
            name: 'Temperatures',
            data: temperatureRange,
            color: {
                linearGradient: {
                    x1: 0,
                    x2: 0,
                    y1: 0,
                    y2: 1
                },
                stops: [
                    [0, '#E8AF58'],
                    [1, '#CDE9FC']
                ]
            }
        }]
    });

      document.getElementById("temperatureGraph").hidden = false;
      const temperatureGraph = document.getElementById('temperatureGraph');
        if (temperatureGraph) {
          temperatureGraph.hidden = false;
          temperatureGraph.focus();
          temperatureGraph.scrollIntoView({ behavior: 'auto' });
        }
    }
  }
  var weatherDataFields = ["temperatureMin","temperatureMax"];
  const coordinates = document.getElementById("coordinates").value;
  xhttp.open("GET", "/weather?coordinates="+coordinates+"&timesteps=1d&weatherDataFields="+JSON.stringify(weatherDataFields)+"&startTime=now"+"&endTime=nowPlus5d", true);
  xhttp.send();
}

function onUpArrowClick(upArrowElement) {
  upArrowElement.hidden = true;
  document.getElementById("downArrow").hidden = false;
  document.getElementById("temperatureGraph").hidden = true;
  document.getElementById("hourlyGraph").hidden = true;
  const dailyWeatherDetail = document.getElementById('dailyWeatherDetail');
  if (dailyWeatherDetail) {
    dailyWeatherDetail.hidden = false;
    dailyWeatherDetail.focus();
    dailyWeatherDetail.scrollIntoView({ behavior: 'auto' });
  }
}

/**
 * Build and return the Highcharts options structure
 */
var getChartOptions = function () {
  return {
    chart: {
      renderTo: "hourlyGraph",
      marginBottom: 70,
      marginRight: 40,
      marginTop: 50,
      plotBorderWidth: 1,
      height: 350,
      alignTicks: false,
      scrollablePlotArea: {
        minWidth: 720,
      },
    },

    defs: {
      
    },

    title: {
      text: "Hourly Weather(For next 5 days)",
      style: {
        whiteSpace: "nowrap",
        textOverflow: "ellipsis",
        marginLeft: '20px', // Set left margin for the title
      },
    },

    credits: {
      text: 'Forecast',
      href: "https://yr.no",
      position: {
        x: -40,
      },
    },

    tooltip: {
      shared: true,
      useHTML: true,
      headerFormat:
        "<small>{point.x:%A, %b %e, %H:%M} - " +
        "{point.point.to:%H:%M}</small><br>" +
        "<b>{point.point.symbolName}</b><br>",
    },

    xAxis: [
      {
        // Bottom X axis
        type: "datetime",
        tickInterval: 2 * 36e5, // two hours
        minorTickInterval: 36e5, // one hour
        tickLength: 0,
        gridLineWidth: 1,
        gridLineColor: "rgba(128, 128, 128, 0.1)",
        startOnTick: false,
        endOnTick: false,
        minPadding: 0,
        maxPadding: 0,
        offset: 30,
        showLastLabel: true,
        labels: {
          format: "{value:%H}",
        },
        crosshair: true,
      },
      {
        // Top X axis
        linkedTo: 0,
        type: "datetime",
        tickInterval: 24 * 3600 * 1000,
        labels: {
          format:
            '{value:<span style="font-size: 12px; font-weight: ' +
            'bold">%a</span> %b %e}',
          align: "left",
          x: 3,
          y: 8,
        },
        opposite: true,
        tickLength: 20,
        gridLineWidth: 1,
      },
    ],

    yAxis: [
      {
        // temperature axis
        title: {
          text: null,
        },
        labels: {
          format: "{value}°",
          style: {
            fontSize: "10px",
          },
          x: -3,
        },
        plotLines: [
          {
            // zero plane
            value: 0,
            color: "#BBBBBB",
            width: 1,
            zIndex: 2,
          },
        ],
        maxPadding: 0.3,
        minRange: 8,
        tickInterval: 1,
        gridLineColor: "rgba(128, 128, 128, 0.1)",
      },
      {
        // humidity axis
        title: {
          text: null,
        },
        labels: {
          enabled: false,
        },
        gridLineWidth: 0,
        tickLength: 0,
        minRange: 10,
        min: 0,
      },
      {
        // Air pressure
        allowDecimals: false,
        title: {
          // Title on top of axis
          text: "inHg",
          offset: 0,
          align: "high",
          rotation: 0,
          style: {
            fontSize: "10px",
            color: "#FFB43D",
          },
          textAlign: "left",
          x: 3,
        },
        labels: {
          style: {
            fontSize: "8px",
            color: "#FFB43D",
          },
          y: 2,
          x: 3,
        },
        gridLineWidth: 0,
        opposite: true,
        showLastLabel: false,
      },
    ],

    legend: {
      enabled: false,
    },

    plotOptions: {
      series: {
        pointPlacement: "between",
      },
    },

    series: [
      {
        name: "Temperature",
        data: temperature,
        type: "spline",
        marker: {
          enabled: false,
          states: {
            hover: {
              enabled: true,
            },
          },
        },
        tooltip: {
          pointFormat:
            '<span style="color:{point.color}">\u25CF</span>' +
            " " +
            "{series.name}: <b>{point.y}°F</b><br/>",
          
        },
        zIndex: 1,
        color: "#FF3333",
        negativeColor: "#48AFE8",
      },
      {
        name: "Humidity",
        data: humidity,
        type: "column",
        color: "#87CEFF",
        yAxis: 1,
        groupPadding: 0,
        pointPadding: 0,
        tooltip: {
          valueSuffix: " %",
        },
        grouping: false,
        dataLabels: {
          enabled: true,
          style: {
            fontSize: "8px",
            color: "gray",
          },
        },
      },
      {
        name: "Air pressure",
        color: "#FFB43D",
        data: pressure,
        marker: {
          enabled: false,
        },
        shadow: false,
        tooltip: {
          valueSuffix: " inHg",
        },
        dashStyle: "shortdot",
        yAxis: 2,
      },
      {
        name: "Wind",
        type: "windbarb",
        id: "windbarbs",
        color: Highcharts.getOptions().colors[1],
        lineWidth: 1.5,
        data: winds,
        vectorLength: 10,
        yOffset: -15,
        tooltip: {
          valueSuffix: " m/s",
        },
      },
    ],
  }
}

//function to dispaly the hourly chart for weather 
function displayHourlyData(downArrowElement){
  var xhttp = new XMLHttpRequest();
  xhttp.onreadystatechange = function(){
    if (this.readyState == 4 && this.status == 200){
      const intervals = JSON.parse(xhttp.responseText).data.timelines[0].intervals;
      temperature=[];
      humidity=[];
      pressure=[];
      winds=[];
      
      intervals.forEach((element,i) => {
        temperature.push({
          x: Date.parse(element.startTime),
          y: Math.round(element.values.temperature)
        });

        humidity.push({
          x: Date.parse(element.startTime),
          y: Math.round(element.values.humidity)
        });

        pressure.push({
          x: Date.parse(element.startTime),
          y: Math.round(element.values.pressureSeaLevel)
        });

        if(i%2==0){
          winds.push({
            x: Date.parse(element.startTime),
            value: element.values.windSpeed,
            direction: element.values.windDirection
          });
        }
        

        
      });


      hourlyChart = new Highcharts.Chart(getChartOptions(), (chart) => {
        const xAxis = chart.xAxis[0]

        for (
          let pos = xAxis.min, max = xAxis.max, i = 0;
          pos <= max + 36e5;
          pos += 36e5, i += 1
        ) {
          // Get the X position
          const isLast = pos === max + 36e5,
            x = Math.round(xAxis.toPixels(pos)) + (isLast ? 0.5 : -0.5)

          // Draw the vertical dividers and ticks
          const isLong =
            this.resolution > 36e5 ? pos % this.resolution === 0 : i % 2 === 0

          chart.renderer
            .path([
              "M",
              x,
              chart.plotTop + chart.plotHeight + (isLong ? 0 : 28),
              "L",
              x,
              chart.plotTop + chart.plotHeight + 32,
              "Z",
            ])
            .attr({
              stroke: chart.options.chart.plotBorderColor,
              "stroke-width": 1,
            })
            .add()
        }

        // Center items in block
        chart.get("windbarbs").markerGroup.attr({
          translateX: chart.get("windbarbs").markerGroup.translateX + 8,
        })

        const hourlyGraph = document.getElementById('hourlyGraph');
        if (hourlyGraph) {
          hourlyGraph.hidden = false;
          hourlyGraph.focus();
          hourlyGraph.scrollIntoView({ behavior: 'auto' });
        }

        
      })

      document.getElementById("hourlyGraph").hidden = false;
      document.getElementById("hourlyGraph").style.marginTop = "20px";
      document.getElementById("hourlyGraph").style.marginLeft = "320px";
    }
  }
  var weatherDataFields = ["temperature","windSpeed","windDirection","humidity","pressureSeaLevel"];
  const coordinates = document.getElementById("coordinates").value;
  xhttp.open("GET", "/weather?coordinates="+coordinates+"&timesteps=1h&weatherDataFields="+JSON.stringify(weatherDataFields)+"&startTime=now"+"&endTime=nowPlus5d", true);
  xhttp.send();
}

