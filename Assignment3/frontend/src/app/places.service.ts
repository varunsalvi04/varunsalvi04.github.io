//Import satetement for the required resources
/// <reference types="@types/googlemaps" />
import { Injectable } from '@angular/core';
import { Loader } from '@googlemaps/js-api-loader';
import { Observable } from 'rxjs';

@Injectable({
    providedIn: 'root'
})
export class GooglePlacesService {
    private autocompleteService!: google.maps.places.AutocompleteService;

    constructor() {
        let loader = new Loader({
            apiKey: 'AIzaSyAig7i8JmSejtz8_rdpaDOdcFj4JOxU130',
            libraries: ["places"]
          });
          loader.load().then(() => {
            this.autocompleteService = new google.maps.places.AutocompleteService();
          });
    }

    getPlacePredictions(input: string): Observable<google.maps.places.AutocompletePrediction[]> {
        return new Observable(observer => {
            this.autocompleteService.getPlacePredictions({input: input, types: ["locality"] }, (predictions, status) => {
                if (status === google.maps.places.PlacesServiceStatus.OK) {
                    let dataTransform: any[] = [];
                    // Log or process predictions
                    predictions.forEach((element) => {
                        let prediction = {
                            city: element.terms[0].value,
                            state: element.terms[1].value
                        };
                        dataTransform.push(prediction);
                    });
                    observer.next(dataTransform);
                } else {
                    observer.error(status);
                }
                observer.complete();
            });
        });
    }
}