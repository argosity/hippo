import { extend } from 'lodash';

import * as array from 'domtastic/src/array';
//import * as css              from 'domtastic/src/css';
import * as dom              from 'domtastic/src/dom/index';
import * as dom_attr         from 'domtastic/src/dom/attr';
import * as dom_class        from 'domtastic/src/dom/class';
import * as dom_contains     from 'domtastic/src/dom/contains';
//import * as dom_data         from 'domtastic/src/dom/data';
import * as dom_extra        from 'domtastic/src/dom/extra';
import * as dom_html         from 'domtastic/src/dom/html';
import * as event            from 'domtastic/src/event/index';
//import * as event_trigger    from 'domtastic/src/event/trigger';
//import * as event_ready      from 'domtastic/src/event/ready';
// import * as noconflict       from 'domtastic/src/noconflict';
import * as selector         from 'domtastic/src/selector/index';
import * as selector_closest from 'domtastic/src/selector/closest';
import * as selector_extra   from 'domtastic/src/selector/extra';

const api = {};
const $ = selector.$;
$.matches = selector.matches;

api.find = selector.find;

extend($, dom_contains);//, noconflict);
extend(
    api,
    array,
    // css,
    dom_attr,
    dom,
    dom_class,
    //  dom_data,
    dom_extra,
    dom_html,
    event,
    // event_trigger,
    // event_ready,
    selector_closest,
    selector_extra);

$.fn = api;

export default el => $(el);
