import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Address } from './address.model';
import { state } from '@angular/animations';
import { Observable } from 'rxjs';
import { AddressResult } from './address-result.model';
import { map, catchError } from 'rxjs/operators';
@Injectable({
  providedIn: 'root'
})
export class FavoriteCityCollectionService {

  private url = '';

  constructor(private http: HttpClient) { }

  addFavoriteCity(address: any) {
    this.url = 'https://backend-dot-assignment3-439821.wl.r.appspot.com/backend/add-favorite-city';
    var headers = new HttpHeaders({ 'Content-Type': 'application/json' });
    return this.http.post(this.url, address, { headers }).subscribe(data => {
      console.log("request send!");
    });
  }

  // listFavoriteCity(){
  //   this.url = '/list-favorite-cities';
  //   return this.http.get(this.url, {params: {

  //   }}).subscribe(data => {
  //     console.log("list files received!");
  //   });;
  // }

  listFavoriteCity(): Observable<Address[]> {
    return this.http.get<any>('https://backend-dot-assignment3-439821.wl.r.appspot.com/backend/list-favorite-cities').pipe(map(res => res as Address[]));
  }

  deleteFavoriteCity(address: Address): Observable<Address[]> {
    this.url = `https://backend-dot-assignment3-439821.wl.r.appspot.com/backend/delete-favorite-city/${address.city}`;
    return this.http.delete<any>(this.url).pipe(map(res => res as Address[]));
  }

}
