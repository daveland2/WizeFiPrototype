import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { BugetdetailsComponent } from './bugetdetails.component';

describe('BugetdetailsComponent', () => {
  let component: BugetdetailsComponent;
  let fixture: ComponentFixture<BugetdetailsComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ BugetdetailsComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(BugetdetailsComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
