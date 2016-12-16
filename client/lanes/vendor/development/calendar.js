webpackJsonp([0],{

/***/ 0:
/***/ function(module, exports, __webpack_require__) {

	/* WEBPACK VAR INJECTION */(function(global) {var Lanes = ( global.Lanes || (global.Lanes = {}) );
	Lanes.Vendor = ( Lanes.Vendor || {} );

	Lanes.Vendor.Dayz = __webpack_require__(10);

	__webpack_require__(457);

	/* WEBPACK VAR INJECTION */}.call(exports, (function() { return this; }())))

/***/ },

/***/ 10:
/***/ function(module, exports, __webpack_require__) {

	'use strict';

	var _extends = Object.assign || function (target) { for (var i = 1; i < arguments.length; i++) { var source = arguments[i]; for (var key in source) { if (Object.prototype.hasOwnProperty.call(source, key)) { target[key] = source[key]; } } } return target; };

	var React = __webpack_require__(11);
	var moment = __webpack_require__(42);
	var Layout = __webpack_require__(153);
	var Day = __webpack_require__(215);
	var XLabels = __webpack_require__(364);
	var YLabels = __webpack_require__(439);

	__webpack_require__(445); // needed in order to for range to install itself

	var EventsCollection = __webpack_require__(446);

	var Dayz = React.createClass({
	    displayName: 'Dayz',


	    propTypes: {
	        editComponent: React.PropTypes.func,
	        display: React.PropTypes.oneOf(['month', 'week', 'day']),
	        date: React.PropTypes.object.isRequired,
	        displayHours: React.PropTypes.array,
	        events: React.PropTypes.instanceOf(EventsCollection),
	        onDayClick: React.PropTypes.func,
	        onDayDoubleClick: React.PropTypes.func,
	        onEventClick: React.PropTypes.func,
	        onEventResize: React.PropTypes.func
	    },

	    getDefaultProps: function getDefaultProps() {
	        return {
	            display: 'month'
	        };
	    },
	    componentWillMount: function componentWillMount() {
	        this.calculateLayout(this.props);
	    },
	    componentWillUnmount: function componentWillUnmount() {
	        this.detachEventBindings();
	    },
	    detachEventBindings: function detachEventBindings() {
	        if (this.props.events) {
	            this.props.events.off('change', this.onEventAdd);
	        }
	    },
	    componentWillReceiveProps: function componentWillReceiveProps(nextProps) {
	        this.calculateLayout(nextProps);
	    },
	    onEventsChange: function onEventsChange() {
	        this.calculateLayout(this.props);
	    },
	    calculateLayout: function calculateLayout(props) {
	        var range = moment.range(props.date.clone().startOf(props.display), props.date.clone().endOf(props.display));
	        if (props.events) {
	            this.detachEventBindings();
	            props.events.on('change', this.onEventsChange, this);
	        }
	        if (props.display === 'month') {
	            range.start.subtract(range.start.weekday(), 'days');
	            range.end.add(6 - range.end.weekday(), 'days');
	        }

	        var layout = new Layout(_extends({}, props, { range: range }));

	        this.setState({ range: range, layout: layout });
	    },
	    render: function render() {
	        var _this = this;

	        var classes = ["dayz", this.props.display];
	        var days = [];
	        this.state.range.by('days', function (day) {
	            return days.push(React.createElement(Day, { key: day.format('YYYYMMDD'),
	                day: day,
	                position: days.length,
	                layout: _this.state.layout,
	                editComponent: _this.props.editComponent,
	                onClick: _this.props.onDayClick,
	                onDoubleClick: _this.props.onDayDoubleClick,
	                onEventClick: _this.props.onEventClick,
	                onEventResize: _this.props.onEventResize

	            }));
	        });
	        return React.createElement(
	            'div',
	            { className: classes.join(' ') },
	            React.createElement(XLabels, { date: this.props.date, display: this.props.display }),
	            React.createElement(
	                'div',
	                { className: 'body' },
	                React.createElement(YLabels, {
	                    layout: this.state.layout,
	                    display: this.props.display,
	                    date: this.props.date
	                }),
	                React.createElement(
	                    'div',
	                    { className: 'days' },
	                    days,
	                    this.props.children
	                )
	            )
	        );
	    }
	});

	Dayz.EventsCollection = EventsCollection;

	module.exports = Dayz;

/***/ },

/***/ 153:
/***/ function(module, exports, __webpack_require__) {

	'use strict';

	var _createClass = function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; }();

	function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

	var assign = __webpack_require__(154);
	var each = __webpack_require__(204);
	var moment = __webpack_require__(42);
	var EventLayout = __webpack_require__(213);
	var C = __webpack_require__(214);

	function cacheKey(day) {
	    return day.format('YYYYMMDD');
	}

	// a layout describes how the calendar is displayed.

	var Layout = function () {
	    function Layout(options) {
	        var _this = this;

	        _classCallCheck(this, Layout);

	        assign(this, options);
	        this.cache = Object.create(null);

	        var multiDayCount = 0;
	        var cacheMethod = 'day' === this.display ? 'addtoDaysCache' : 'calculateSpanningLayout';
	        if (!this.events) {
	            return;
	        }
	        var range = this.range;

	        this.events.each(function (event) {
	            // we only care about events that are in the range we were provided
	            if (range.overlaps(event.range())) {
	                _this[cacheMethod](event);
	                if (!event.isSingleDay()) {
	                    multiDayCount += 1;
	                }
	            }
	        });
	        this.multiDayCount = multiDayCount;
	        this.calculateStacking();
	        if (!this.isDisplayingAsMonth() && !this.displayHours) {
	            this.displayHours = this.hourRange();
	        } else {
	            this.displayHours = this.displayHours || [0, 24];
	        }
	    }

	    _createClass(Layout, [{
	        key: 'minutesInDay',
	        value: function minutesInDay() {
	            return (this.displayHours[1] - this.displayHours[0]) * 60;
	        }
	    }, {
	        key: 'propsForDayContainer',
	        value: function propsForDayContainer(props) {
	            var classes = ['day'];
	            if (this.isDateOutsideRange(props.day)) {
	                classes.push('outside');
	            }
	            return { className: classes.join(' '), style: { order: props.position } };
	        }
	    }, {
	        key: 'propsForAllDayEventContainer',
	        value: function propsForAllDayEventContainer() {
	            var style = this.multiDayCount ? { flexBasis: this.multiDayCount * C.eventHeight } : { display: 'none' };
	            return { className: 'all-day', style: style };
	        }
	    }, {
	        key: 'hourRange',
	        value: function hourRange() {
	            var _this2 = this;

	            var range = [7, 19];
	            this.range.by('days', function (day) {
	                each(_this2.forDay(day), function (layout) {
	                    range[0] = Math.min(layout.event.start().hour(), range[0]);
	                    range[1] = Math.max(layout.event.end().hour(), range[1]);
	                });
	            });
	            range[1] += 1;
	            return range;
	        }
	    }, {
	        key: 'getEventsForWeek',
	        value: function getEventsForWeek(start) {
	            var day = start.clone();
	            var weeklyEvents = [];
	            for (var i = 0; i < 7; i++) {
	                var layouts = this.forDay(day);
	                each(layouts, function (layout) {
	                    weeklyEvents.push(layout);
	                });
	                day.add(1, 'day');
	            }
	            var minLong = function minLong(range) {
	                return moment.max(start, range.start).diff(moment.min(day, range.end), 'minutes');
	            };
	            return weeklyEvents.sort(function (a, b) {
	                a = minLong(a.event.range());b = minLong(b.event.range());
	                return a === b ? 0 : a > b ? 1 : -1;
	            });
	        }
	    }, {
	        key: 'calculateStacking',
	        value: function calculateStacking() {
	            var firstOfWeek = this.range.start.clone().startOf('week');
	            do {
	                var weeklyEvents = this.getEventsForWeek(firstOfWeek);
	                for (var layoutIndex = 0; layoutIndex < weeklyEvents.length; layoutIndex++) {
	                    var layout = weeklyEvents[layoutIndex];
	                    // loop through each layout that is before this one
	                    var ceilingIndex = 0;
	                    for (var pi = layoutIndex - 1; pi >= 0; pi--) {
	                        var prevLayout = weeklyEvents[pi];
	                        if (prevLayout.range.start.isSame(layout.range.start, 'd')) {
	                            ceilingIndex = pi + 1;
	                            break;
	                        }
	                    }
	                    for (var _pi = ceilingIndex; _pi < layoutIndex; _pi++) {
	                        var _prevLayout = weeklyEvents[_pi];
	                        if (layout.range.overlaps(_prevLayout.range)) {
	                            layout.stack++;
	                        }
	                    }
	                }
	                firstOfWeek.add(7, 'day');
	            } while (!firstOfWeek.isAfter(this.range.end));
	        }
	    }, {
	        key: 'isDateOutsideRange',
	        value: function isDateOutsideRange(date) {
	            return this.isDisplayingAsMonth() && this.date.month() !== date.month();
	        }
	    }, {
	        key: 'forDay',
	        value: function forDay(day) {
	            return this.cache[cacheKey(day)] || [];
	        }

	        // a single day is easy, just add the event to that day

	    }, {
	        key: 'addtoDaysCache',
	        value: function addtoDaysCache(event) {
	            var layout = new EventLayout(this, event, this.range);
	            this.addToCache(this.range.start, layout);
	        }

	        // other layouts must break at week boundaries, with indicators if they were/are continuing

	    }, {
	        key: 'calculateSpanningLayout',
	        value: function calculateSpanningLayout(event) {
	            var end = moment.min(this.range.end, event.range().end);
	            var start = moment.max(this.range.start, event.range().start).clone();
	            do {
	                var range = moment.range(start, start.clone().endOf('week'));
	                var layout = new EventLayout(this, event, range);
	                this.addToCache(start, layout);
	                // go to first day of next week
	                start.add(7 - start.day(), 'day');
	            } while (!start.isAfter(end));
	        }
	    }, {
	        key: 'addToCache',
	        value: function addToCache(date, eventLayout) {
	            date = date.clone();
	            var found = false;
	            each(this.cache, function (key, layout) {
	                if (layout.event === eventLayout.event) {
	                    found = true;
	                    return false;
	                }
	            });
	            if (!found) {
	                eventLayout.first = true;
	            }
	            var dayCache = this.cache[cacheKey(date)] || (this.cache[cacheKey(date)] = []);
	            dayCache.push(eventLayout);
	        }
	    }, {
	        key: 'displayingAs',
	        value: function displayingAs() {
	            return this.display;
	        }
	    }, {
	        key: 'isDisplayingAsMonth',
	        value: function isDisplayingAsMonth() {
	            return 'month' === this.display;
	        }
	    }]);

	    return Layout;
	}();

	module.exports = Layout;

/***/ },

/***/ 204:
/***/ function(module, exports, __webpack_require__) {

	module.exports = __webpack_require__(205);


/***/ },

/***/ 213:
/***/ function(module, exports, __webpack_require__) {

	'use strict';

	var _createClass = function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; }();

	function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

	var moment = __webpack_require__(42);

	// an event layout describes how an event is displayed.
	// A event may be split into one or more layouts in order to be split across week boundaries

	var EventLayout = function () {
	    function EventLayout(layout, event, displayRange) {
	        _classCallCheck(this, EventLayout);

	        this.layout = layout;
	        this.event = event;
	        this.stack = 0;
	        this.displayRange = displayRange;
	        this.startsBefore = event.start().isBefore(displayRange.start);
	        this.endsAfter = event.end().isAfter(displayRange.end);
	        this.range = moment.range(moment.max(displayRange.start, event.start()), moment.min(displayRange.end, event.end()));
	        var latest = moment.min(displayRange.end, event.end());
	        this.span = Math.max(1, Math.round(latest.diff(displayRange.start, 'day', true)));
	    }

	    _createClass(EventLayout, [{
	        key: 'isEditing',
	        value: function isEditing() {
	            return this.first && this.event.isEditing();
	        }
	    }, {
	        key: 'startsOnWeek',
	        value: function startsOnWeek() {
	            return 0 === this.event.start().day();
	        }
	    }, {
	        key: 'adjustEventTime',
	        value: function adjustEventTime(startOrEnd, position, height) {
	            if (position < 0 || position > height) {
	                return;
	            }
	            var time = this.event[startOrEnd]().startOf('day').add(this.layout.displayHours[0], 'hours').add(this.layout.minutesInDay() * (position / height), 'minutes');
	            var step = this.event.get('resizable').step;
	            if (step) {
	                var rounded = Math.round(time.minute() / step) * step;
	                time.minute(rounded).second(0);
	            }
	            this.event.emit('change');
	        }
	    }, {
	        key: 'inlineStyles',
	        value: function inlineStyles() {
	            if (this.layout.displayingAs() === 'month' || !this.event.isSingleDay()) {
	                return {};
	            } else {
	                var _event$daysMinuteRang = this.event.daysMinuteRange();

	                var start = _event$daysMinuteRang.start;
	                var end = _event$daysMinuteRang.end;

	                var startOffset = this.layout.displayHours[0] * 60;
	                start -= startOffset;
	                end -= startOffset;
	                var inday = this.layout.minutesInDay();
	                var top = (start / inday * 100).toFixed(2) + '%';
	                var bottom = (100 - end / inday * 100).toFixed(2) + '%';
	                return { top: top, bottom: bottom };
	            }
	        }
	    }, {
	        key: 'isResizable',
	        value: function isResizable() {
	            return this.layout.displayingAs() !== 'month' && this.event.get('resizable');
	        }
	    }, {
	        key: 'key',
	        value: function key() {
	            return this.displayRange.start.format('YYYYMMDD') + this.event.key;
	        }
	    }, {
	        key: 'setIsResizing',
	        value: function setIsResizing(val) {
	            this.isResizing = val;
	        }
	    }, {
	        key: 'classNames',
	        value: function classNames() {
	            var classes = ['event', 'span-' + this.span, 'color-' + this.event.colorIndex()];
	            if (this.isResizing) classes.push('is-resizing');
	            if (this.startsBefore) classes.push('is-continuation');
	            if (this.endsAfter) classes.push('is-continued');
	            if (this.stack) classes.push('stack-' + this.stack);
	            if (this.isEditing()) classes.push('is-editing');
	            if (this.isResizable()) classes.push('is-resizable');
	            return classes.join(' ');
	        }
	    }]);

	    return EventLayout;
	}();

	module.exports = EventLayout;

/***/ },

/***/ 214:
/***/ function(module, exports) {

	"use strict";

	module.exports = {

	    eventHeight: 20 // px

	};

/***/ },

/***/ 215:
/***/ function(module, exports, __webpack_require__) {

	'use strict';

	var _extends = Object.assign || function (target) { for (var i = 1; i < arguments.length; i++) { var source = arguments[i]; for (var key in source) { if (Object.prototype.hasOwnProperty.call(source, key)) { target[key] = source[key]; } } } return target; };

	var React = __webpack_require__(11);
	var Layout = __webpack_require__(153);
	var Event = __webpack_require__(216);
	var Label = __webpack_require__(363);
	var assign = __webpack_require__(154);
	var each = __webpack_require__(204);
	var ReactDOM = __webpack_require__(217);

	var IsDayClass = new RegExp('(\\s|^)(events|day|label)(\\s|$)');

	var Day = React.createClass({
	    displayName: 'Day',


	    propTypes: {
	        day: React.PropTypes.object.isRequired,
	        layout: React.PropTypes.instanceOf(Layout).isRequired,
	        position: React.PropTypes.number.isRequired,
	        onClick: React.PropTypes.func,
	        onDoubleClick: React.PropTypes.func,
	        onEventClick: React.PropTypes.func,
	        onEventResize: React.PropTypes.func,
	        editComponent: React.PropTypes.func,
	        onEventDoubleClick: React.PropTypes.func
	    },

	    getInitialState: function getInitialState() {
	        return { resize: false };
	    },
	    getBounds: function getBounds() {
	        return ReactDOM.findDOMNode(this.refs.events || this.refs.root).getBoundingClientRect();
	    },
	    _onClickHandler: function _onClickHandler(ev, handler) {
	        if (!handler || !IsDayClass.test(ev.target.className) || this.lastMouseUp && this.lastMouseUp < new Date().getMilliseconds() + 100) {
	            return;
	        }
	        this.lastMouseUp = 0;
	        var bounds = this.getBounds();
	        var perc = (ev.clientY - bounds.top) / ev.target.offsetHeight;
	        var hours = this.props.layout.displayHours[0] + this.props.layout.minutesInDay() * perc / 60;
	        handler.call(this, ev, this.props.day.clone().startOf('day').add(hours, 'hour'));
	    },
	    onClick: function onClick(ev) {
	        this._onClickHandler(ev, this.props.onClick);
	    },
	    onDoubleClick: function onDoubleClick(ev) {
	        this._onClickHandler(ev, this.props.onDoubleClick);
	    },
	    onDragStart: function onDragStart(resize, eventLayout) {
	        eventLayout.setIsResizing(true);
	        var bounds = this.getBounds();
	        assign(resize, { eventLayout: eventLayout, height: bounds.height, top: bounds.top });
	        this.setState({ resize: resize });
	    },
	    onMouseMove: function onMouseMove(ev) {
	        if (!this.state.resize) {
	            return;
	        }
	        var coord = ev.clientY - this.state.resize.top;
	        this.state.resize.eventLayout.adjustEventTime(this.state.resize.type, coord, this.state.resize.height);
	        this.forceUpdate();
	    },
	    onMouseUp: function onMouseUp(ev) {
	        var _this = this;

	        if (!this.state.resize) {
	            return;
	        }
	        this.state.resize.eventLayout.setIsResizing(false);
	        setTimeout(function () {
	            return _this.setState({ resize: false });
	        }, 1);
	        if (this.props.onEventResize) {
	            this.props.onEventResize(ev, this.state.resize.eventLayout.event);
	        }
	        this.lastMouseUp = new Date().getMilliseconds();
	    },
	    renderEvents: function renderEvents() {
	        var _this2 = this;

	        var asMonth = this.props.layout.isDisplayingAsMonth();
	        var singleDayEvents = [];
	        var allDayEvents = [];
	        var onMouseMove = asMonth ? null : this.onMouseMove;
	        each(this.props.layout.forDay(this.props.day), function (layout) {
	            var event = React.createElement(Event, {
	                layout: layout,
	                key: layout.key(),
	                day: _this2.props.day,
	                parent: _this2,
	                onDragStart: _this2.onDragStart,
	                onClick: _this2.props.onEventClick,
	                editComponent: _this2.props.editComponent,
	                onDoubleClick: _this2.props.onEventDoubleClick
	            });
	            (layout.event.isSingleDay() ? singleDayEvents : allDayEvents).push(event);
	        });
	        var events = [];
	        if (allDayEvents.length || !asMonth) {
	            events.push(React.createElement(
	                'div',
	                _extends({ key: 'allday' }, this.props.layout.propsForAllDayEventContainer()),
	                allDayEvents
	            ));
	        }
	        if (singleDayEvents.length) {
	            events.push(React.createElement(
	                'div',
	                { key: 'events', ref: 'events', className: 'events',
	                    onMouseMove: onMouseMove, onMouseUp: this.onMouseUp },
	                singleDayEvents
	            ));
	        }
	        return events;
	    },
	    render: function render() {
	        var props = this.props.layout.propsForDayContainer(this.props);

	        return React.createElement(
	            'div',
	            _extends({ ref: 'root'
	            }, props, {
	                onClick: this.onClick,
	                onDoubleClick: this.onDoubleClick
	            }),
	            React.createElement(
	                Label,
	                { day: this.props.day, className: 'label' },
	                this.props.day.format('D')
	            ),
	            this.renderEvents()
	        );
	    }
	});

	module.exports = Day;

/***/ },

/***/ 216:
/***/ function(module, exports, __webpack_require__) {

	'use strict';

	var React = __webpack_require__(11);
	var ReactDOM = __webpack_require__(217);
	var EventLayout = __webpack_require__(213);
	var IsResizeClass = new RegExp('(\\s|^)event(\\s|$)');

	var Event = React.createClass({
	    displayName: 'Event',


	    propTypes: {
	        layout: React.PropTypes.instanceOf(EventLayout),
	        editComponent: React.PropTypes.func,
	        onClick: React.PropTypes.func,
	        onDoubleClick: React.PropTypes.func
	    },

	    onClick: function onClick(ev) {
	        if (!this.props.onClick) {
	            return;
	        }
	        this.props.onClick(ev, this.props.layout.event);
	        ev.stopPropagation();
	    },
	    onDoubleClick: function onDoubleClick(ev) {
	        if (!this.props.onDoubleClick) {
	            return;
	        }
	        this.props.onDoubleClick(ev, this.props.layout.event);
	        ev.stopPropagation();
	    },
	    onDragStart: function onDragStart(ev) {
	        if (!IsResizeClass.test(ev.target.className)) {
	            return;
	        }
	        var bounds = ReactDOM.findDOMNode(this.refs.element).getBoundingClientRect();
	        var resize = void 0;
	        if (ev.clientY - bounds.top < 10) {
	            resize = { type: 'start' };
	        } else if (bounds.bottom - ev.clientY < 10) {
	            resize = { type: 'end' };
	        } else {
	            return;
	        }
	        this.props.onDragStart(resize, this.props.layout);
	    },
	    render: function render() {
	        var body = React.createElement(
	            'div',
	            { className: 'evbody', onClick: this.onClick },
	            this.props.layout.event.render()
	        );
	        var Edit = this.props.editComponent;
	        var children = this.props.layout.isEditing() ? React.createElement(
	            Edit,
	            { event: this.props.layout.event },
	            body
	        ) : body;
	        return React.createElement(
	            'div',
	            {
	                ref: 'element',
	                onMouseDown: this.onDragStart,
	                style: this.props.layout.inlineStyles(),
	                className: this.props.layout.classNames()
	            },
	            children
	        );
	    }
	});

	module.exports = Event;

/***/ },

/***/ 363:
/***/ function(module, exports, __webpack_require__) {

	'use strict';

	var React = __webpack_require__(11);

	var Label = React.createClass({
	    displayName: 'Label',


	    propTypes: {
	        day: React.PropTypes.object.isRequired
	    },

	    render: function render() {
	        return React.createElement(
	            'div',
	            { className: 'label' },
	            this.props.day.format('D')
	        );
	    }
	});

	module.exports = Label;

/***/ },

/***/ 364:
/***/ function(module, exports, __webpack_require__) {

	'use strict';

	var React = __webpack_require__(11);
	var map = __webpack_require__(365);

	var XLabels = React.createClass({
	    displayName: 'XLabels',


	    propTypes: {
	        display: React.PropTypes.oneOf(['month', 'week', 'day']),
	        date: React.PropTypes.object.isRequired
	    },

	    render: function render() {
	        var days = [];
	        if (this.props.display === 'day') {
	            days.push(this.props.date);
	        } else {
	            var day = this.props.date.clone().startOf('week');
	            for (var i = 0; i < 7; i++) {
	                days.push(day.clone().add(i, 'day'));
	            }
	        }
	        var format = this.props.display === 'month' ? 'dddd' : 'ddd, MMM Do';
	        var labels = map(days, function (day) {
	            return React.createElement(
	                'div',
	                { key: day.format('YYYYMMDD'), className: 'day-label' },
	                day.format(format)
	            );
	        });

	        return React.createElement(
	            'div',
	            { className: 'x-labels' },
	            labels
	        );
	    }
	});

	module.exports = XLabels;

/***/ },

/***/ 439:
/***/ function(module, exports, __webpack_require__) {

	'use strict';

	var React = __webpack_require__(11);
	var moment = __webpack_require__(42);
	var Layout = __webpack_require__(153);
	var each = __webpack_require__(204);
	var range = __webpack_require__(440);

	var YLabels = React.createClass({
	    displayName: 'YLabels',


	    propTypes: {
	        display: React.PropTypes.oneOf(['month', 'week', 'day']),
	        date: React.PropTypes.object.isRequired,
	        layout: React.PropTypes.instanceOf(Layout).isRequired
	    },

	    render: function render() {
	        if (this.props.display === 'month') {
	            return null;
	        }

	        var day = moment();
	        var labels = [];
	        var hours = range(this.props.layout.displayHours[0], this.props.layout.displayHours[1]);
	        each(hours, function (hour) {
	            day.hour(hour);
	            labels.push(React.createElement(
	                'div',
	                { key: hour, className: 'hour' },
	                day.format('ha')
	            ));
	        });

	        var multiDay = React.createElement(
	            'div',
	            this.props.layout.propsForAllDayEventContainer(),
	            'All Day'
	        );

	        return React.createElement(
	            'div',
	            null,
	            React.createElement(
	                'div',
	                { className: 'y-labels' },
	                multiDay,
	                labels
	            )
	        );
	    }
	});

	module.exports = YLabels;

/***/ },

/***/ 440:
/***/ function(module, exports, __webpack_require__) {

	var createRange = __webpack_require__(441);

	/**
	 * Creates an array of numbers (positive and/or negative) progressing from
	 * `start` up to, but not including, `end`. A step of `-1` is used if a negative
	 * `start` is specified without an `end` or `step`. If `end` is not specified,
	 * it's set to `start` with `start` then set to `0`.
	 *
	 * **Note:** JavaScript follows the IEEE-754 standard for resolving
	 * floating-point values which can produce unexpected results.
	 *
	 * @static
	 * @since 0.1.0
	 * @memberOf _
	 * @category Util
	 * @param {number} [start=0] The start of the range.
	 * @param {number} end The end of the range.
	 * @param {number} [step=1] The value to increment or decrement by.
	 * @returns {Array} Returns the range of numbers.
	 * @see _.inRange, _.rangeRight
	 * @example
	 *
	 * _.range(4);
	 * // => [0, 1, 2, 3]
	 *
	 * _.range(-4);
	 * // => [0, -1, -2, -3]
	 *
	 * _.range(1, 5);
	 * // => [1, 2, 3, 4]
	 *
	 * _.range(0, 20, 5);
	 * // => [0, 5, 10, 15]
	 *
	 * _.range(0, -4, -1);
	 * // => [0, -1, -2, -3]
	 *
	 * _.range(1, 4, 0);
	 * // => [1, 1, 1]
	 *
	 * _.range(0);
	 * // => []
	 */
	var range = createRange();

	module.exports = range;


/***/ },

/***/ 441:
/***/ function(module, exports, __webpack_require__) {

	var baseRange = __webpack_require__(442),
	    isIterateeCall = __webpack_require__(183),
	    toFinite = __webpack_require__(443);

	/**
	 * Creates a `_.range` or `_.rangeRight` function.
	 *
	 * @private
	 * @param {boolean} [fromRight] Specify iterating from right to left.
	 * @returns {Function} Returns the new range function.
	 */
	function createRange(fromRight) {
	  return function(start, end, step) {
	    if (step && typeof step != 'number' && isIterateeCall(start, end, step)) {
	      end = step = undefined;
	    }
	    // Ensure the sign of `-0` is preserved.
	    start = toFinite(start);
	    if (end === undefined) {
	      end = start;
	      start = 0;
	    } else {
	      end = toFinite(end);
	    }
	    step = step === undefined ? (start < end ? 1 : -1) : toFinite(step);
	    return baseRange(start, end, step, fromRight);
	  };
	}

	module.exports = createRange;


/***/ },

/***/ 442:
/***/ function(module, exports) {

	/* Built-in method references for those with the same name as other `lodash` methods. */
	var nativeCeil = Math.ceil,
	    nativeMax = Math.max;

	/**
	 * The base implementation of `_.range` and `_.rangeRight` which doesn't
	 * coerce arguments.
	 *
	 * @private
	 * @param {number} start The start of the range.
	 * @param {number} end The end of the range.
	 * @param {number} step The value to increment or decrement by.
	 * @param {boolean} [fromRight] Specify iterating from right to left.
	 * @returns {Array} Returns the range of numbers.
	 */
	function baseRange(start, end, step, fromRight) {
	  var index = -1,
	      length = nativeMax(nativeCeil((end - start) / (step || 1)), 0),
	      result = Array(length);

	  while (length--) {
	    result[fromRight ? length : ++index] = start;
	    start += step;
	  }
	  return result;
	}

	module.exports = baseRange;


/***/ },

/***/ 446:
/***/ function(module, exports, __webpack_require__) {

	'use strict';

	var _createClass = function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; }();

	function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

	var Event = __webpack_require__(447);
	var Emitter = __webpack_require__(448);
	var _each = __webpack_require__(204);
	var assign = __webpack_require__(154);
	var sortBy = __webpack_require__(449);

	function lengthCompare(event) {
	    return event.attributes.range.start.diff(event.attributes.range.end);
	}

	var EventsCollection = function () {
	    function EventsCollection() {
	        var events = arguments.length <= 0 || arguments[0] === undefined ? [] : arguments[0];

	        _classCallCheck(this, EventsCollection);

	        this.events = [];
	        for (var i = 0, length = events.length; i < length; i++) {
	            this.add(events[i]);
	        }
	    }

	    _createClass(EventsCollection, [{
	        key: 'add',
	        value: function add(event) {
	            if (!event.isEvent) {
	                event = new Event(event);
	            }
	            event.collection = this;
	            this.events.push(event);
	            this.emit('change');
	            return event;
	        }
	    }, {
	        key: 'each',
	        value: function each(fn, scope) {
	            var sorted = sortBy(this.events, lengthCompare);
	            _each(sorted, fn, scope);
	        }
	    }, {
	        key: 'length',
	        value: function length() {
	            return this.events.length;
	        }
	    }, {
	        key: 'remove',
	        value: function remove(event) {
	            var index = this.events.indexOf(event);
	            if (-1 !== index) {
	                this.events.splice(index, 1);
	                this.emit('change');
	            }
	        }
	    }]);

	    return EventsCollection;
	}();

	EventsCollection.Event = Event;


	assign(EventsCollection.prototype, Emitter.prototype);

	module.exports = EventsCollection;

/***/ },

/***/ 447:
/***/ function(module, exports, __webpack_require__) {

	'use strict';

	var _createClass = function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; }();

	function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

	var React = __webpack_require__(11);
	var assign = __webpack_require__(154);
	var each = __webpack_require__(204);
	var Emitter = __webpack_require__(448);

	var EVENT_COUNTER = 1;

	var Event = function () {
	    function Event(attributes) {
	        _classCallCheck(this, Event);

	        this.attributes = attributes;
	        this.isEvent = true;
	        this.key = EVENT_COUNTER++;
	        if (!this.attributes.range) {
	            throw new Error("Must provide range");
	        }
	    }

	    _createClass(Event, [{
	        key: 'render',
	        value: function render(date, layout) {
	            if (this.attributes.render) {
	                return this.attributes.render(date, layout);
	            } else {
	                return this.defaultRenderImplementation(date, layout);
	            }
	        }
	    }, {
	        key: 'defaultRenderImplementation',
	        value: function defaultRenderImplementation() {
	            return React.createElement('div', {}, this.attributes.content || this.attributes.range.start.format('MMM DD YYYY'));
	        }
	    }, {
	        key: 'get',
	        value: function get(key) {
	            return this.attributes[key];
	        }
	    }, {
	        key: 'set',
	        value: function set(attributes, options) {
	            var _this = this;

	            var changed = false;
	            each(attributes, function (value, key) {
	                if (_this.attributes[key] !== value) {
	                    changed = true;
	                    return false;
	                }
	            });
	            if (!changed) {
	                return;
	            }
	            assign(this.attributes, attributes);
	            this._emitChangeEvent(options);
	        }
	    }, {
	        key: 'isEditing',
	        value: function isEditing() {
	            return !!this.attributes.editing;
	        }
	    }, {
	        key: 'setEditing',
	        value: function setEditing(isEditing) {
	            var options = arguments.length <= 1 || arguments[1] === undefined ? {} : arguments[1];

	            if (isEditing !== this.isEditing()) {
	                this.attributes.editing = isEditing;
	            }
	            this._emitChangeEvent(options);
	        }
	    }, {
	        key: '_emitChangeEvent',
	        value: function _emitChangeEvent() {
	            var options = arguments.length <= 0 || arguments[0] === undefined ? {} : arguments[0];

	            if (this.collection) {
	                this.collection.emit('change', this);
	            }
	            if (!options || !options.silent) {
	                this.emit('change', this);
	            }
	        }
	    }, {
	        key: 'range',
	        value: function range() {
	            return this.attributes.range.clone();
	        }
	    }, {
	        key: 'isSingleDay',
	        value: function isSingleDay() {
	            return this.attributes.range.end.diff(this.attributes.range.start, 'hours') <= 24;
	        }
	    }, {
	        key: 'daysMinuteRange',
	        value: function daysMinuteRange() {
	            var startOfDay = this.attributes.range.start.clone().startOf('day');
	            return { start: this.attributes.range.start.diff(startOfDay, 'minute'),
	                end: this.attributes.range.end.diff(startOfDay, 'minute') };
	        }
	    }, {
	        key: 'content',
	        value: function content() {
	            return this.attributes.content;
	        }
	    }, {
	        key: 'start',
	        value: function start() {
	            return this.attributes.range.start;
	        }
	    }, {
	        key: 'end',
	        value: function end() {
	            return this.attributes.range.end;
	        }
	    }, {
	        key: 'colorIndex',
	        value: function colorIndex() {
	            return this.attributes.colorIndex;
	        }
	    }, {
	        key: 'remove',
	        value: function remove() {
	            this.collection.remove(this);
	            this.isDeleted = true;
	            this.emit('change');
	        }
	    }]);

	    return Event;
	}();

	assign(Event.prototype, Emitter.prototype);

	module.exports = Event;

/***/ },

/***/ 448:
/***/ function(module, exports) {

	function E () {
	  // Keep this empty so it's easier to inherit from
	  // (via https://github.com/lipsmack from https://github.com/scottcorgan/tiny-emitter/issues/3)
	}

	E.prototype = {
	  on: function (name, callback, ctx) {
	    var e = this.e || (this.e = {});

	    (e[name] || (e[name] = [])).push({
	      fn: callback,
	      ctx: ctx
	    });

	    return this;
	  },

	  once: function (name, callback, ctx) {
	    var self = this;
	    function listener () {
	      self.off(name, listener);
	      callback.apply(ctx, arguments);
	    };

	    listener._ = callback
	    return this.on(name, listener, ctx);
	  },

	  emit: function (name) {
	    var data = [].slice.call(arguments, 1);
	    var evtArr = ((this.e || (this.e = {}))[name] || []).slice();
	    var i = 0;
	    var len = evtArr.length;

	    for (i; i < len; i++) {
	      evtArr[i].fn.apply(evtArr[i].ctx, data);
	    }

	    return this;
	  },

	  off: function (name, callback) {
	    var e = this.e || (this.e = {});
	    var evts = e[name];
	    var liveEvents = [];

	    if (evts && callback) {
	      for (var i = 0, len = evts.length; i < len; i++) {
	        if (evts[i].fn !== callback && evts[i].fn._ !== callback)
	          liveEvents.push(evts[i]);
	      }
	    }

	    // Remove event from queue to prevent memory leak
	    // Suggested by https://github.com/lazd
	    // Ref: https://github.com/scottcorgan/tiny-emitter/commit/c6ebfaa9bc973b33d110a84a307742b7cf94c953#commitcomment-5024910

	    (liveEvents.length)
	      ? e[name] = liveEvents
	      : delete e[name];

	    return this;
	  }
	};

	module.exports = E;


/***/ },

/***/ 457:
/***/ function(module, exports, __webpack_require__) {

	module.exports = __webpack_require__.p + "calendar.scss";

/***/ }

});