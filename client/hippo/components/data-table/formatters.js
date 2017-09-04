import Big from 'big.js';
import { isNil, isNaN } from 'lodash';

export function currency({ cellData: value }) { // eslint-disable-line import/prefer-default-export
    if (isNil(value) || isNaN(value)) { return ''; }
    return Big(value).round(2).toFixed(2);
}
