import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { Assets2Component } from './assets2.component';

describe('Assets2Component', () => {
  let component: Assets2Component;
  let fixture: ComponentFixture<Assets2Component>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ Assets2Component ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(Assets2Component);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
