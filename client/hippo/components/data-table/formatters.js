import Big from 'big.js';
import { isNaN } from 'lodash';

export function currency({ cellData: value }) {
    if (isNaN(value)) { return ''; }
    return Big(value).round(2).toFixed(2);
}
