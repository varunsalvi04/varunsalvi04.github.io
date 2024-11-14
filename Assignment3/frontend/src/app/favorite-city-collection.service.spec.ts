import { TestBed } from '@angular/core/testing';

import { FavoriteCityCollectionService } from './favorite-city-collection.service';

describe('FavoriteCityCollectionService', () => {
  let service: FavoriteCityCollectionService;

  beforeEach(() => {
    TestBed.configureTestingModule({});
    service = TestBed.inject(FavoriteCityCollectionService);
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });
});
