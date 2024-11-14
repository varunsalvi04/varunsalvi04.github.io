import { TestBed } from '@angular/core/testing';

import { WeeklyWeatherTableService } from './weekly-weather-table.service';

describe('WeeklyWeatherTableService', () => {
  let service: WeeklyWeatherTableService;

  beforeEach(() => {
    TestBed.configureTestingModule({});
    service = TestBed.inject(WeeklyWeatherTableService);
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });
});
