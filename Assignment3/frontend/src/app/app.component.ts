//Import satetement for the required resources
/// <reference types="@types/googlemaps" />
import { Component, HostListener } from '@angular/core';
import { FormControl, FormBuilder, FormGroup, Validators } from '@angular/forms';
import { MatAutocompleteSelectedEvent } from '@angular/material/autocomplete';
import { NgbModal } from '@ng-bootstrap/ng-bootstrap';
import * as Highcharts from 'highcharts';
import more from 'highcharts/highcharts-more';
import accessibility from 'highcharts/modules/accessibility';
import data from 'highcharts/modules/data';
import datagrouping from 'highcharts/modules/datagrouping';
import exports from 'highcharts/modules/export-data';
import exporting from 'highcharts/modules/exporting';
import pattern from 'highcharts/modules/pattern-fill';
import windbarb from 'highcharts/modules/windbarb';
import { Observable } from 'rxjs';
import { debounceTime, distinctUntilChanged, map, startWith, switchMap } from 'rxjs/operators';
import { GeocodeService } from './geocode.service';
import { IpinfoService } from './ipinfo.service';
import { PostService } from './post.service';
import { WeeklyWeatherTableService } from './weekly-weather-table.service';
import { FavoriteCityCollectionService } from './favorite-city-collection.service';
import { Address } from './address.model';
import { Loader } from '@googlemaps/js-api-loader';
import { trigger, transition, animate, style } from '@angular/animations'


declare var require: any;
let Boost = require('highcharts/modules/boost');
let noData = require('highcharts/modules/no-data-to-display');


Boost(Highcharts);
noData(Highcharts);
more(Highcharts);
noData(Highcharts);
windbarb(Highcharts);
exporting(Highcharts);
exports(Highcharts);
datagrouping(Highcharts);
pattern(Highcharts);
data(Highcharts);
accessibility(Highcharts);


@Component({

  selector: 'app-root',

  templateUrl: './app.component.html',

  styleUrls: ['./app.component.css'],
  //slideIn and slideOut effect for result and details tab
  animations: [
    trigger('slideInOut', [
      transition(':enter', [
        style({ transform: 'translateX(-50%)' }),
        animate('300ms ease-in', style({ transform: 'translateX(0%)' }))
      ]),
      transition(':leave', [
        animate('300ms ease-in', style({ transform: 'translateX(-40%)' }))
      ])
    ]),
    trigger('slideOutIn', [
      transition(':enter', [
        style({ transform: 'translateX(50%)' }),
        animate('300ms ease-in', style({ transform: 'translateX(0%)' }))
      ]),
      transition(':leave', [
        animate('300ms ease-in', style({ transform: 'translateX(50%)' }))
      ])
    ])
  ]

})




export class AppComponent {
  //declarations
  title = 'assignment3';
  state: string = '';
  filteredOptions: Observable<any[]>;
  isDailyDetailHidden: boolean = true;
  isDisabled: boolean = false;
  myControl = new FormControl();
  coordinates: string = '';
  inputStreet: string = '';
  inputCityText: string = '';
  activeTab: string = '';
  isCheckboxChecked: boolean = false;
  imgUrl = '../assets/image/WeatherSymbolsforWeatherCodes/';
  temperatureRange: [number, number, number][] = [];
  Highcharts = Highcharts;
  address!: Address;
  startTime: string = '';
  endTime: string = '';
  temperatureMax: string = '';
  temperatureMin: string = '';
  temperatureApparent: string = '';
  sunriseTime: string = '';
  sunsetTime: string = '';
  humidity: string = '';
  windSpeed: string = '';
  visibility: string = '';
  cloudCover: string = '';
  status: number = 0;
  selectedWeatherDetails: any = {};
  dailyWeatherData: boolean = false;
  hidden: boolean = true;
  googleMap!: google.maps.Map;
  center: google.maps.LatLngLiteral = { lat: 30, lng: -110 };
  meteogram: any;
  meteogramOptions: any;
  resolution: number = window.innerHeight * innerWidth;
  favoriteAddresses: Address[] = [];
  progress = 0;
  progressVisible = false;
  dailyDataStartTime: string = '';
  isResultActive = true;
  isFavorite = false;
  loading: boolean = false;
  limitReached: boolean = false;
  hideError: boolean = false;
  isSearchButtonDisabled = true;

  //Services for the various APIs used
  constructor(private service: PostService,
    private ipInfoService: IpinfoService,
    private geocodeService: GeocodeService,
    private weeklyWeatherService: WeeklyWeatherTableService,
    private favoriteCityCollectionService: FavoriteCityCollectionService,
    private modalService: NgbModal) {
    this.filteredOptions = this.myControl.valueChanges.pipe(
      startWith(''),
      debounceTime(400),
      distinctUntilChanged(),
      switchMap(val => {
        return this.filter(val || '')
      })
    )
  }

  //autodetect location when checkbox is checked
  autoDetectLocation(values: any): void {
    this.isCheckboxChecked = values.currentTarget.checked;
    if (this.isCheckboxChecked) {
      this.isDisabled = true;
      this.myControl.disable();
      this.inputStreet = '';
      this.state = 'Select a State';
      this.ipInfoService.getCoordinates().subscribe(
        (response: any) => {
          this.coordinates = response.loc;
          this.isSearchButtonDisabled = false;
          let state = this.states.find(state => state.name === response.region);
          this.address = { city: response.city, state: state!.code, stateFullName: state!.name }; //response.city.concat(", ", response.region);
          const [latitude, longitude] = this.coordinates.split(',').map(Number);
          this.initMap(latitude, longitude);
        },
        (error) => { console.log(error); });
    } else {
      this.isDisabled = false;
      this.myControl.enable();
      this.isSearchButtonDisabled = true;
    }
  }

  //show weather Data when the search button is clicked 
  showWeather(): void {
    if (this.isCheckboxChecked) {
      this.loading = true;
      setTimeout(() => {
        this.loading = false;
      }, 500);

      this.weeklyWeather();
    } else {
      this.loading = true;
      setTimeout(() => {
        this.loading = false;
      }, 3000);
      const locationObject = (<Address>this.myControl.value);
      let state = this.states.find(state => state.code === locationObject.state);
      this.showCityWeatherData(locationObject);
    }

  }

  //if checkbox is not checked then use the geocoding api to get the coordinates
  showCityWeatherData(locationObject: Address) {
    let state = this.states.find(state => state.code === locationObject.state);
    if (state) {
      this.address = { city: locationObject.city, state: locationObject.state, stateFullName: state.name };
      this.geocodeService.getGeocodeCoordinates(this.inputStreet.concat(" ", locationObject.city), locationObject.state).subscribe(
        (response: any) => {
          const latitude = response.results[0].geometry.location.lat;
          const longitude = response.results[0].geometry.location.lng;
          this.coordinates = "".concat(latitude, ",", longitude);
          this.weeklyWeather();
          this.initMap(latitude, longitude);
        },
        (error) => {
          console.log(error);
        }
      );
    } else {
      this.limitReached = true;
      return;
    }

  }

  //show the weather data of the favorite city in the favorite list/tab
  showFavoriteCityWeatherData(address: Address) {
    this.activeTab = "day";
    this.showCityWeatherData(address);
  }


  //show the weekly weather data
  weeklyWeather(): void {
    this.weeklyWeatherService.getWeeklyWeatherData(this.coordinates, '1d', ["temperature", "temperatureApparent", "temperatureMin", "temperatureMax", "windSpeed", "windDirection", "humidity", "pressureSeaLevel", "uvIndex", "weatherCode", "precipitationProbability", "precipitationType", "visibility", "cloudCover"]).subscribe(
      (response: any) => {
        if ("Too Many Calls" == response.type) {
          this.limitReached = true;
          this.hideError = false;
          return;
        }

        let result = this.favoriteAddresses.filter(o => o.city === this.address.city);
        if (Array.isArray(result) && result.length > 0) {
          this.isFavorite = true;
        }
        else {
          this.isFavorite = false;
        }
        this.displayHourlyData();
        const intervals = response.data.timelines[0].intervals;

        const modifiedStartTime = this.modifyStartTime(response.data.timelines[0].startTime);
        this.loadDailyWeatherDetails(modifiedStartTime);
        const latlong = this.coordinates.split(",").map(x => Number(x));
        this.initMap(latlong[0], latlong[1]);

        this.startTime = this.formatDate(response.data.timelines[0].startTime);


        this.temperatureRange = [];
        this.weeklyWeatherData = intervals.map((element: any) => ({
          startTime: this.formatDate(element.startTime),
          endTime: this.formatDate(element.endTime),
          values: element.values,
          temperatureMin: element.values.temperatureMin,
          temperatureMax: element.values.temperatureMax,
        }));

        this.weeklyWeatherData.forEach((element: any) => {
          const chartElement: [number, number, number] = [
            Date.parse(element.startTime),
            element.temperatureMax,
            element.temperatureMin,
          ];
          this.temperatureRange.push(chartElement);
        });
        this.hidden = false;
        this.activeTab = 'day'
        // Update the chart with new data
        this.chartOptions.series[0].data = this.temperatureRange;
        Highcharts.chart('container', this.chartOptions);
      },
      (error) => { console.log(error); });
  }


  onRowClick(startTime: string): void {
    const modifiedStartTime = this.modifyStartTime(startTime);
    this.startTime = this.formatDate(startTime);
    this.loadDailyWeatherDetails(modifiedStartTime);
    this.activeTab = '';
    this.isDailyDetailHidden = false;
    this.hidden = true;
    const latlong = this.coordinates.split(",").map(x => Number(x));
    this.initMap(latlong[0], latlong[1]);
  }

  modifyStartTime(startTime: string): string {
    const date = new Date(startTime);
    date.setDate(date.getDate());
    return date.toISOString().slice(0, 19) + startTime.slice(19);
  }



  //temperature range highchart
  chartOptions: any = {
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
      text: 'Temperature Ranges (Min, Max)',
      align: 'left'
    },
    xAxis: {
      type: 'datetime',
      accessibility: {
        rangeDescription: 'Range: Jan 1st 2023 to Jan 1st 2024.'
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
      valueSuffix: '°C',
      xDateFormat: '%A, %b %e'
    },
    legend: {
      enabled: false
    },
    series: [{
      name: 'Temperatures',
      data: this.temperatureRange,
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
  }

  formatDate(dateString: any) {
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

  formatTime(timeString: any) {
    const date = new Date(timeString);


    let hours = date.getHours();
    const minutes = date.getMinutes();
    const ampm = hours >= 12 ? 'PM' : 'AM';


    hours = hours % 12;
    hours = hours ? hours : 12;
    const minutesString = minutes < 10 ? '0' + minutes : minutes;

    return `${hours}:${minutesString} ${ampm}`;
  }


  public weeklyWeatherData: any[] = [];



  onTabClick(tab: string): void {
    this.activeTab = tab;
    if (this.activeTab === "favorites") {
      this.isResultActive = false;
      this.hidden = true;
      this.isDailyDetailHidden = true;
      this.favoriteCityCollectionService.listFavoriteCity().subscribe({
        next: (addresses) => {
          this.favoriteAddresses = addresses;
        },
      });
    }
  }

  onResultClick(): void {
    this.isResultActive = true;
    this.activeTab = 'day';
    this.isDailyDetailHidden = true;
    if (this.weeklyWeatherData.length > 0) {
      this.hidden = false;

    }
  }

  goToWeeklyWeather() {
    this.isDailyDetailHidden = true;
    if (this.weeklyWeatherData.length > 0) {
      this.hidden = false;
    }
    this.activeTab = 'day';
  }

  deleteFavoriteCity(address: Address) {
    this.favoriteCityCollectionService.deleteFavoriteCity(address).subscribe({
      next: (addresses) => {
        this.favoriteAddresses = addresses;
      },
    });;
  }



  goToClear() {
    this.isDailyDetailHidden = true;
    this.hidden = true;
    this.isDisabled = false;
    this.hideError = true;
    this.myControl.reset();
    this.myControl.enable();
    this.weeklyWeatherData = [];
    this.coordinates = '';
    this.status = 0;
    this.isSearchButtonDisabled = true;
  }

  goToDetails() {
    if (this.status === 0) {
      this.isDailyDetailHidden = true;
      return;
    }

    this.isDailyDetailHidden = false;
    this.hidden = true;
  }



  
  filter(val: string): Observable<any[]> {
    // call the service which makes the http-request
    return this.service.getData(val)
      .pipe(
        map(response => response.filter(option => {
          return option.city.toLowerCase().indexOf(val.toLowerCase()) === 0
        }))
      )
  }

  public open(modal: any): void {
    this.modalService.open(modal);
  }

  OnCitySelected(SelectedCity: MatAutocompleteSelectedEvent) {
    console.log("Here " + SelectedCity.option.value);
    this.state = SelectedCity.option.value.state;
    this.isSearchButtonDisabled = false;
  }

  displayFn(location: Address): string {
    return location && location.city ? location.city : '';
  }

  //load the weather data of the selected day
  loadDailyWeatherDetails(startTime: string): void {
    this.weeklyWeatherService.getWeeklyWeatherData(this.coordinates, '1d', ["temperature", "temperatureApparent", "temperatureMin", "temperatureMax", "windSpeed", "windDirection", "humidity", "pressureSeaLevel", "uvIndex", "weatherCode", "precipitationProbability", "precipitationType", "visibility", "cloudCover", "sunriseTime", "sunsetTime"], startTime).subscribe(
      (response: any) => {
        this.dailyDataStartTime = startTime;
        const intervals = response.data.timelines[0].intervals[0].values;

        this.status = parseInt(intervals.weatherCode);
        this.temperatureMax = intervals.temperatureMax;
        this.temperatureMin = intervals.temperatureMin;
        this.temperatureApparent = intervals.temperatureApparent;
        this.sunriseTime = this.formatTime(intervals.sunriseTime);
        this.sunsetTime = this.formatTime(intervals.sunsetTime);
        this.humidity = intervals.humidity;
        this.windSpeed = intervals.windSpeed;
        this.visibility = intervals.visibility;
        this.cloudCover = intervals.cloudCover;

      },

      (error) => { console.log(error); });

  }

  getTwitterShareUrl(): string {
    const text = `The temperature in ${this.address?.city}, ${this.address?.state} on ${this.startTime} is ${this.temperatureApparent}. The weather conditions are ${this.getWeatherDescription(this.status)} #CSCI571WeatherSearch`;
    return `https://twitter.com/intent/tweet?text=${encodeURIComponent(text)}`;
  }

  /**
 * Build and return the Highcharts options structure
 */
  getChartOptions = (temperature: any, humidity: any, winds: any, pressure: any) => {
    const meteogramOptions = {
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
          color: "#68CEE7",
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
          color: "#FF3938",
          lineWidth: 1.5,
          data: winds,
          vectorLength: 10,
          yOffset: -15,
          tooltip: {
            valueSuffix: " m/s",
          },
        },
      ],
    };
    this.meteogramOptions = meteogramOptions;
    return meteogramOptions;
  }


  @HostListener('window:resize', ['$event'])
  onResize(event) {
    this.resolution = window.innerWidth * window.innerHeight;
  }

  meteogramCallback = (chart) => {
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
      const isLong = this.resolution > 36e5 ? pos % this.resolution === 0 : i % 2 === 0

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

  }


  //display the hourly weather data
  displayHourlyData(): void {
    this.weeklyWeatherService.getWeeklyWeatherData(this.coordinates, '1h', ["temperature", "temperatureApparent", "temperatureMin", "temperatureMax", "windSpeed", "windDirection", "humidity", "pressureSeaLevel", "uvIndex", "weatherCode", "precipitationProbability", "precipitationType", "visibility", "cloudCover"]).subscribe(
      (response: any) => {
        const intervals = response.data.timelines[0].intervals;
        const temperature: { x: number, y: number }[] = [];
        const humidityHighchart: { x: number, y: number }[] = [];
        const pressure: { x: number, y: number }[] = [];
        const winds: { x: number, value: number, direction: number }[] = [];


        intervals.forEach((element, i) => {
          temperature.push({
            x: Date.parse(element.startTime),
            y: Math.round(element.values.temperature)
          });

          humidityHighchart.push({
            x: Date.parse(element.startTime),
            y: Math.round(element.values.humidity)
          });

          pressure.push({
            x: Date.parse(element.startTime),
            y: Math.round(element.values.pressureSeaLevel)
          });

          if (i % 2 == 0) {
            winds.push({
              x: Date.parse(element.startTime),
              value: element.values.windSpeed,
              direction: element.values.windDirection
            });
          }

        });


        Highcharts.chart('hourlyGraph', this.getChartOptions(temperature, humidityHighchart, winds, pressure) as Highcharts.Options);

      },
      (error) => { console.log(error); });
  }


  ngOnInit(): void {
    let loader = new Loader({
      apiKey: 'AIzaSyAig7i8JmSejtz8_rdpaDOdcFj4JOxU130',
      libraries: ["places"]
    });
    loader.load().then(() => {
      this.initMap(0, 0);
    });

    this.favoriteCityCollectionService.listFavoriteCity().subscribe({
      next: (addresses) => {
        this.favoriteAddresses = addresses;
      },
    });


  }

  //map for the current city which is selected
  initMap(latitude: number, longitude: number): void {
    const mapOptions = {
      zoom: 8,
      center: { lat: latitude, lng: longitude }
    };

    this.googleMap = new google.maps.Map(
      document.getElementById('map') as HTMLElement,
      mapOptions
    );

    const marker = new google.maps.Marker({
      position: { lat: latitude, lng: longitude },
      map: this.googleMap
    });

    const infowindow = new google.maps.InfoWindow({
      content: `<p>Marker Location: ${marker.getPosition()}</p>`
    });

    google.maps.event.addListener(marker, 'click', () => {
      infowindow.open(this.googleMap, marker);
    });
  }

  //delete favorite city form the list if again slected and present in the list
  //if not present in the list then add it to the favorite list
  toggleFavoriteCity() {
    if (this.isFavorite) {
      this.deleteFavoriteCity(this.address);
    } else {
      this.favoriteCityCollectionService.addFavoriteCity(this.address);
    }
    this.isFavorite = !this.isFavorite;
  }



  selectedState!: string;
  states = [
    { code: 'AL', name: 'Alabama' },
    { code: 'AK', name: 'Alaska' },
    { code: 'AZ', name: 'Arizona' },
    { code: 'AR', name: 'Arkansas' },
    { code: 'CA', name: 'California' },
    { code: 'CO', name: 'Colorado' },
    { code: 'CT', name: 'Connecticut' },
    { code: 'DE', name: 'Delaware' },
    { code: 'DC', name: 'District Of Columbia' },
    { code: 'FL', name: 'Florida' },
    { code: 'GA', name: 'Georgia' },
    { code: 'HI', name: 'Hawaii' },
    { code: 'ID', name: 'Idaho' },
    { code: 'IL', name: 'Illinois' },
    { code: 'IN', name: 'Indiana' },
    { code: 'IA', name: 'Iowa' },
    { code: 'KS', name: 'Kansas' },
    { code: 'KY', name: 'Kentucky' },
    { code: 'LA', name: 'Louisiana' },
    { code: 'ME', name: 'Maine' },
    { code: 'MD', name: 'Maryland' },
    { code: 'MA', name: 'Massachusetts' },
    { code: 'MI', name: 'Michigan' },
    { code: 'MN', name: 'Minnesota' },
    { code: 'MS', name: 'Mississippi' },
    { code: 'MO', name: 'Missouri' },
    { code: 'MT', name: 'Montana' },
    { code: 'NE', name: 'Nebraska' },
    { code: 'NV', name: 'Nevada' },
    { code: 'NH', name: 'New Hampshire' },
    { code: 'NJ', name: 'New Jersey' },
    { code: 'NM', name: 'New Mexico' },
    { code: 'NY', name: 'New York' },
    { code: 'NC', name: 'North Carolina' },
    { code: 'ND', name: 'North Dakota' },
    { code: 'OH', name: 'Ohio' },
    { code: 'OK', name: 'Oklahoma' },
    { code: 'OR', name: 'Oregon' },
    { code: 'PA', name: 'Pennsylvania' },
    { code: 'RI', name: 'Rhode Island' },
    { code: 'SC', name: 'South Carolina' },
    { code: 'SD', name: 'South Dakota' },
    { code: 'TN', name: 'Tennessee' },
    { code: 'TX', name: 'Texas' },
    { code: 'UT', name: 'Utah' },
    { code: 'VT', name: 'Vermont' },
    { code: 'VA', name: 'Virginia' },
    { code: 'WA', name: 'Washington' },
    { code: 'WV', name: 'West Virginia' },
    { code: 'WI', name: 'Wisconsin' },
    { code: 'WY', name: 'Wyoming' }
  ];

  getWeatherDescription(weatherCode: number): string {
    const descriptions: { [key: number]: string } = {
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

    return descriptions[weatherCode] || 'Unknown Weather';
  }

}


function loadDailyWeatherDetails(startTime: any) {
  throw new Error('Function not implemented.');
}




