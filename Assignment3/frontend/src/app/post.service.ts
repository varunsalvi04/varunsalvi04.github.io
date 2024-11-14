import { Injectable } from '@angular/core';

import { HttpClient } from '@angular/common/http';

import { tap, map } from 'rxjs/operators';

import { of } from 'rxjs';

  

@Injectable({

  providedIn: 'root'

})

export class PostService {


  constructor(private http: HttpClient) { }

    getData(val: string) {
      return  this.http.get<any>('https://backend-dot-assignment3-439821.wl.r.appspot.com/backend/autocomplete?input='+val).pipe(map(data => {
        return this.process(data);
      }));
    }

    process(data:any)  
    {
        let dataTransform:any[]=[];
        data.predictions.forEach((element: any) => {
          let prediction = {
            city: element.terms[0].value,
            state: element.terms[1].value
          };
          dataTransform.push(prediction);
        });
        return dataTransform;
    }
}