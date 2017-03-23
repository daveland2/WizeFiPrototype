import { WizeFiPrototypePage } from './app.po';

describe('wize-fi-prototype App', () => {
  let page: WizeFiPrototypePage;

  beforeEach(() => {
    page = new WizeFiPrototypePage();
  });

  it('should display message saying app works', () => {
    page.navigateTo();
    expect(page.getParagraphText()).toEqual('app works!');
  });
});
