import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { BugetDetailsComponent } from './buget-details.component';

describe('BugetDetailsComponent', () => {
  let component: BugetDetailsComponent;
  let fixture: ComponentFixture<BugetDetailsComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ BugetDetailsComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(BugetDetailsComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
