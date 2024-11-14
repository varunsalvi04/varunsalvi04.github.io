import { HttpClient } from  '@angular/common/http';
import { Injectable } from '@angular/core';

@Injectable({
  providedIn: 'root'
})
export class IpinfoService {
  private url = 'https://ipinfo.io/';
  constructor(private http: HttpClient) { }

  getCoordinates() {
    return this.http.get(this.url, {params: {
      token: "ef2cd709c85551"
    }});
  }
}
