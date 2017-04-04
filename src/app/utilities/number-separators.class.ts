import { DataModelService } from '../data-model.service';

export class NumberSeparators {

    constructor (private dataModelService: DataModelService) { }

    thousandsSeparator() : string {
        let separator = this.dataModelService.dataModel.config.thousandsSeparator;
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
        let separator = this.dataModelService.dataModel.config.decimalSeparator;
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

}   // class NumberSeparators