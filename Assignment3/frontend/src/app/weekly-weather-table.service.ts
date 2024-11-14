import { HttpClient } from  '@angular/common/http';
import { Injectable } from '@angular/core';

@Injectable({
  providedIn: 'root'
})
export class WeeklyWeatherTableService {

  private url = 'https://backend-dot-assignment3-439821.wl.r.appspot.com/backend/weather';


  constructor(private http: HttpClient) { }

  getWeeklyWeatherData(coordinates: string, timesteps: string, weatherDataFields: string[], startTime?: string, endTime?: string) {
    const params: any = {
      coordinates: coordinates,
      timesteps: timesteps,
      weatherDataFields: weatherDataFields
    };

    if (startTime && !endTime) {
      params.startTime = startTime;
    } else if(startTime && endTime){
      params.startTime = startTime;
      params.endTime = endTime;
    }

    return this.http.get(this.url, { params });
  }
}
