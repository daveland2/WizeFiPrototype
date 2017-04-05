import { DataModelService } from '../data-model.service';

export class ConfigValues {

    constructor (private dataModelService: DataModelService) { }

    currencyCode() : string {
        let code = this.dataModelService.dataModel.persistent.settings.currencyCode;
        if (code == '') {code = 'USD'}  // default
        return code;
    }   // currencyCode

    thousandsSeparator() : string {
        let separator = this.dataModelService.dataModel.persistent.settings.thousandsSeparator;
        if (separator == '') {
            separator = ',';  // default
            if (typeof Number.prototype.toLocaleString === 'function') {
                let num = 1000000;
                let numStr = num.toLocaleString();
                if (numStr.length == 9) separator = numStr.substr(1,1);
            }
        }
        return separator;
    }   // thousandsSeparator

    decimalSeparator() : string {
        let separator = this.dataModelService.dataModel.persistent.settings.decimalSeparator;
        if (separator == '') {
            separator = '.';  // default
            if (typeof Number.prototype.toLocaleString === 'function') {
                let num = 1.05;
                let numStr = num.toLocaleString();
                if (numStr.length == 4) separator = numStr.substr(1,1);
            }
        }
        return separator;
    }   // decimalSeparator

}   // class ConfigValues