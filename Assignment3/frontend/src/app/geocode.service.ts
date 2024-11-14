import { HttpClient } from  '@angular/common/http';
import { Injectable } from '@angular/core';

@Injectable({
  providedIn: 'root'
})
export class GeocodeService {
  private url = 'https://backend-dot-assignment3-439821.wl.r.appspot.com/backend/coordinates';
  constructor(private http: HttpClient) { }

  getGeocodeCoordinates(address: string, state: string) {
    return this.http.get(this.url, {params: {
      address: address,
      state: state
    }});
  }
}
