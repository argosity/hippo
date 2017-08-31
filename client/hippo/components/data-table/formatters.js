import Big from 'big.js';
import { isNaN } from 'lodash';

export function currency({ cellData: value }) { // eslint-disable-line import/prefer-default-export
    if (isNaN(value)) { return ''; }
    return Big(value).round(2).toFixed(2);
}
