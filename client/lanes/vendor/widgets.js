webpackJsonp([4],{

/***/ 0:
/***/ function(module, exports, __webpack_require__) {

	/* WEBPACK VAR INJECTION */(function(global) {var Lanes = ( global.Lanes || (global.Lanes = {}) );
	Lanes.Vendor = ( Lanes.Vendor || {} );

	Lanes.Vendor.ReactWidgets = __webpack_require__(1405)
	__webpack_require__(1483);

	/* WEBPACK VAR INJECTION */}.call(exports, (function() { return this; }())))

/***/ },

/***/ 103:
/***/ function(module, exports, __webpack_require__) {

	module.exports = __webpack_require__(104);


/***/ },

/***/ 1405:
/***/ function(module, exports, __webpack_require__) {

	/* WEBPACK VAR INJECTION */(function(process) {'use strict';

	if (process.env.NODE_ENV !== 'production') {
	  [Array.prototype.some, Array.prototype.filter, Array.prototype.reduce].forEach(function (method) {
	    if (!method) throw new Error('One or more ES5 features is not available to ReactWidgets: http://jquense.github.io/react-widgets/docs/#/getting-started/browser');
	  });
	}

	module.exports = {

	  DropdownList: __webpack_require__(1406),
	  Combobox: __webpack_require__(1454),

	  Calendar: __webpack_require__(1458),
	  DateTimePicker: __webpack_require__(1471),

	  NumberPicker: __webpack_require__(1474),

	  Multiselect: __webpack_require__(1477),
	  SelectList: __webpack_require__(1481),

	  configure: __webpack_require__(1482),

	  utils: {
	    ReplaceTransitionGroup: __webpack_require__(1469),
	    SlideTransition: __webpack_require__(1468)
	  }
	};
	/* WEBPACK VAR INJECTION */}.call(exports, __webpack_require__(105)))

/***/ },

/***/ 1406:
/***/ function(module, exports, __webpack_require__) {

	'use strict';

	var babelHelpers = __webpack_require__(1407);

	var React = __webpack_require__(103),
	    activeElement = __webpack_require__(236),
	    _ = __webpack_require__(1408),
	    contains = __webpack_require__(1409),
	    cx = __webpack_require__(1411),
	    compat = __webpack_require__(1412),
	    CustomPropTypes = __webpack_require__(1413),
	    Popup = __webpack_require__(1431),
	    PlainList = __webpack_require__(1435),
	    GroupableList = __webpack_require__(1441),
	    validateList = __webpack_require__(1442),
	    createUncontrolledWidget = __webpack_require__(1443);

	var omit = _.omit;
	var pick = _.pick;
	var result = _.result;

	var propTypes = {
	  //-- controlled props -----------
	  value: React.PropTypes.any,
	  onChange: React.PropTypes.func,
	  open: React.PropTypes.bool,
	  onToggle: React.PropTypes.func,
	  //------------------------------------

	  data: React.PropTypes.array,
	  valueField: React.PropTypes.string,
	  textField: CustomPropTypes.accessor,

	  valueComponent: CustomPropTypes.elementType,
	  itemComponent: CustomPropTypes.elementType,
	  listComponent: CustomPropTypes.elementType,

	  groupComponent: CustomPropTypes.elementType,
	  groupBy: CustomPropTypes.accessor,

	  onSelect: React.PropTypes.func,

	  searchTerm: React.PropTypes.string,
	  onSearch: React.PropTypes.func,

	  busy: React.PropTypes.bool,

	  delay: React.PropTypes.number,

	  dropUp: React.PropTypes.bool,
	  duration: React.PropTypes.number, //popup

	  disabled: React.PropTypes.oneOfType([React.PropTypes.bool, React.PropTypes.oneOf(['disabled'])]),

	  readOnly: React.PropTypes.oneOfType([React.PropTypes.bool, React.PropTypes.oneOf(['readOnly'])]),

	  messages: React.PropTypes.shape({
	    open: CustomPropTypes.message,
	    emptyList: CustomPropTypes.message,
	    emptyFilter: CustomPropTypes.message,
	    filterPlaceholder: CustomPropTypes.message
	  })
	};

	var DropdownList = React.createClass({

	  displayName: 'DropdownList',

	  mixins: [__webpack_require__(1437), __webpack_require__(1445), __webpack_require__(1446), __webpack_require__(1447), __webpack_require__(1438), __webpack_require__(1448), __webpack_require__(1453), __webpack_require__(1440)()],

	  propTypes: propTypes,

	  getDefaultProps: function getDefaultProps() {
	    return {
	      delay: 500,
	      value: '',
	      open: false,
	      data: [],
	      searchTerm: '',
	      messages: msgs(),
	      ariaActiveDescendantKey: 'dropdownlist'
	    };
	  },

	  getInitialState: function getInitialState() {
	    var filter = this.props.open && this.props.filter,
	        data = filter ? this.filter(this.props.data, this.props.searchTerm) : this.props.data,
	        initialIdx = this._dataIndexOf(this.props.data, this.props.value);

	    return {
	      filteredData: filter && data,
	      selectedItem: data[initialIdx],
	      focusedItem: data[initialIdx] || data[0]
	    };
	  },

	  componentDidUpdate: function componentDidUpdate() {
	    this.refs.list && validateList(this.refs.list);
	  },

	  componentWillReceiveProps: function componentWillReceiveProps(props) {
	    var filter = props.open && props.filter,
	        data = filter ? this.filter(props.data, props.searchTerm) : props.data,
	        idx = this._dataIndexOf(data, props.value);

	    this.setState({
	      filteredData: filter && data,
	      selectedItem: data[idx],
	      focusedItem: data[! ~idx ? 0 : idx]
	    });
	  },

	  render: function render() {
	    var _cx,
	        _this = this;

	    var _props = this.props;
	    var className = _props.className;
	    var tabIndex = _props.tabIndex;
	    var filter = _props.filter;
	    var groupBy = _props.groupBy;
	    var messages = _props.messages;
	    var data = _props.data;
	    var busy = _props.busy;
	    var dropUp = _props.dropUp;
	    var placeholder = _props.placeholder;
	    var value = _props.value;
	    var open = _props.open;
	    var disabled = _props.disabled;
	    var readOnly = _props.readOnly;
	    var ValueComponent = _props.valueComponent;
	    var List = _props.listComponent;

	    List = List || groupBy && GroupableList || PlainList;

	    var elementProps = omit(this.props, Object.keys(propTypes));
	    var listProps = pick(this.props, Object.keys(compat.type(List).propTypes));
	    var popupProps = pick(this.props, Object.keys(compat.type(Popup).propTypes));

	    var _state = this.state;
	    var focusedItem = _state.focusedItem;
	    var selectedItem = _state.selectedItem;
	    var focused = _state.focused;

	    var items = this._data(),
	        valueItem = this._dataItem(data, value) // take value from the raw data
	    ,
	        listID = this._id('__listbox');

	    var shouldRenderList = _.isFirstFocusedRender(this) || open;

	    messages = msgs(messages);

	    return React.createElement(
	      'div',
	      babelHelpers._extends({}, elementProps, {
	        ref: 'input',
	        role: 'combobox',
	        tabIndex: tabIndex || '0',
	        'aria-expanded': open,
	        'aria-haspopup': true,
	        'aria-owns': listID,
	        'aria-busy': !!busy,
	        'aria-live': !open && 'polite',
	        //aria-activedescendant={activeID}
	        'aria-autocomplete': 'list',
	        'aria-disabled': disabled,
	        'aria-readonly': readOnly,
	        onKeyDown: this._keyDown,
	        onClick: this._click,
	        onFocus: this._focus.bind(null, true),
	        onBlur: this._focus.bind(null, false),
	        className: cx(className, 'rw-dropdownlist', 'rw-widget', (_cx = {}, _cx['rw-state-disabled'] = disabled, _cx['rw-state-readonly'] = readOnly, _cx['rw-state-focus'] = focused, _cx['rw-rtl'] = this.isRtl(), _cx['rw-open' + (dropUp ? '-up' : '')] = open, _cx)) }),
	      React.createElement(
	        'span',
	        { className: 'rw-dropdownlist-picker rw-select rw-btn' },
	        React.createElement(
	          'i',
	          { className: 'rw-i rw-i-caret-down' + (busy ? ' rw-loading' : '') },
	          React.createElement(
	            'span',
	            { className: 'rw-sr' },
	            result(messages.open, this.props)
	          )
	        )
	      ),
	      React.createElement(
	        'div',
	        {
	          className: 'rw-input'
	        },
	        !valueItem && placeholder ? React.createElement(
	          'span',
	          { className: 'rw-placeholder' },
	          placeholder
	        ) : this.props.valueComponent ? React.createElement(ValueComponent, { item: valueItem }) : this._dataText(valueItem)
	      ),
	      React.createElement(
	        Popup,
	        babelHelpers._extends({}, popupProps, {
	          onOpen: function () {
	            return _this.focus();
	          },
	          onOpening: function () {
	            return _this.refs.list.forceUpdate();
	          },
	          onRequestClose: this.close
	        }),
	        React.createElement(
	          'div',
	          null,
	          filter && this._renderFilter(messages),
	          shouldRenderList && React.createElement(List, babelHelpers._extends({ ref: 'list'
	          }, listProps, {
	            data: items,
	            id: listID,
	            'aria-live': open && 'polite',
	            'aria-labelledby': this._id(),
	            'aria-hidden': !this.props.open,
	            selected: selectedItem,
	            focused: open ? focusedItem : null,
	            onSelect: this._onSelect,
	            onMove: this._scrollTo,
	            messages: {
	              emptyList: data.length ? messages.emptyFilter : messages.emptyList
	            } }))
	        )
	      )
	    );
	  },

	  _renderFilter: function _renderFilter(messages) {
	    var _this2 = this;

	    return React.createElement(
	      'div',
	      { ref: 'filterWrapper', className: 'rw-filter-input' },
	      React.createElement(
	        'span',
	        { className: 'rw-select rw-btn' },
	        React.createElement('i', { className: 'rw-i rw-i-search' })
	      ),
	      React.createElement('input', { ref: 'filter', className: 'rw-input',
	        placeholder: _.result(messages.filterPlaceholder, this.props),
	        value: this.props.searchTerm,
	        onChange: function (e) {
	          return _this2.notify('onSearch', e.target.value);
	        } })
	    );
	  },

	  _focus: _.ifNotDisabled(true, function (focused, e) {
	    var _this3 = this;

	    this.setTimeout('focus', function () {
	      if (!focused) _this3.close();

	      if (focused !== _this3.state.focused) {
	        _this3.notify(focused ? 'onFocus' : 'onBlur', e);
	        _this3.setState({ focused: focused });
	      }
	    });
	  }),

	  _onSelect: _.ifNotDisabled(function (data) {
	    this.close();
	    this.notify('onSelect', data);
	    this.change(data);
	    this.focus(this);
	  }),

	  _click: _.ifNotDisabled(function (e) {
	    var wrapper = this.refs.filterWrapper;

	    if (!this.props.filter || !this.props.open) this.toggle();else if (!contains(compat.findDOMNode(wrapper), e.target)) this.close();

	    this.notify('onClick', e);
	  }),

	  _keyDown: _.ifNotDisabled(function (e) {
	    var _this4 = this;

	    var self = this,
	        key = e.key,
	        alt = e.altKey,
	        list = this.refs.list,
	        filtering = this.props.filter,
	        focusedItem = this.state.focusedItem,
	        selectedItem = this.state.selectedItem,
	        isOpen = this.props.open,
	        closeWithFocus = function closeWithFocus() {
	      _this4.close(), compat.findDOMNode(_this4).focus();
	    };

	    if (key === 'End') {
	      if (isOpen) this.setState({ focusedItem: list.last() });else change(list.last());
	      e.preventDefault();
	    } else if (key === 'Home') {
	      if (isOpen) this.setState({ focusedItem: list.first() });else change(list.first());
	      e.preventDefault();
	    } else if (key === 'Escape' && isOpen) {
	      closeWithFocus();
	    } else if ((key === 'Enter' || key === ' ' && !filtering) && isOpen) {
	      change(this.state.focusedItem, true);
	    } else if (key === 'ArrowDown') {
	      if (alt) this.open();else if (isOpen) this.setState({ focusedItem: list.next(focusedItem) });else change(list.next(selectedItem));
	      e.preventDefault();
	    } else if (key === 'ArrowUp') {
	      if (alt) closeWithFocus();else if (isOpen) this.setState({ focusedItem: list.prev(focusedItem) });else change(list.prev(selectedItem));
	      e.preventDefault();
	    } else if (!(this.props.filter && isOpen)) this.search(String.fromCharCode(e.keyCode), function (item) {
	      isOpen ? _this4.setState({ focusedItem: item }) : change(item);
	    });

	    this.notify('onKeyDown', [e]);

	    function change(item, fromList) {
	      if (!item) return;
	      fromList ? self._onSelect(item) : self.change(item);
	    }
	  }),

	  change: function change(data) {
	    if (!_.isShallowEqual(data, this.props.value)) {
	      this.notify('onChange', data);
	      this.notify('onSearch', '');
	      this.close();
	    }
	  },

	  focus: function focus(target) {
	    var inst = target || (this.props.filter && this.props.open ? this.refs.filter : this.refs.input);

	    if (activeElement() !== compat.findDOMNode(inst)) compat.findDOMNode(inst).focus();
	  },

	  _data: function _data() {
	    return this.state.filteredData || this.props.data.concat();
	  },

	  search: function search(character, cb) {
	    var _this5 = this;

	    var word = ((this._searchTerm || '') + character).toLowerCase();

	    this._searchTerm = word;

	    this.setTimeout('search', function () {
	      var list = _this5.refs.list,
	          key = _this5.props.open ? 'focusedItem' : 'selectedItem',
	          item = list.next(_this5.state[key], word);

	      _this5._searchTerm = '';
	      if (item) cb(item);
	    }, this.props.delay);
	  },

	  open: function open() {
	    this.notify('onToggle', true);
	  },

	  close: function close() {
	    this.notify('onToggle', false);
	  },

	  toggle: function toggle() {
	    this.props.open ? this.close() : this.open();
	  }

	});

	function msgs(msgs) {
	  return babelHelpers._extends({
	    open: 'open dropdown',
	    filterPlaceholder: '',
	    emptyList: 'There are no items in this list',
	    emptyFilter: 'The filter returned no results' }, msgs);
	}

	module.exports = createUncontrolledWidget(DropdownList, { open: 'onToggle', value: 'onChange', searchTerm: 'onSearch' });

	module.exports.BaseDropdownList = DropdownList;

/***/ },

/***/ 1407:
/***/ function(module, exports, __webpack_require__) {

	var __WEBPACK_AMD_DEFINE_FACTORY__, __WEBPACK_AMD_DEFINE_ARRAY__, __WEBPACK_AMD_DEFINE_RESULT__;(function (root, factory) {
	  if (true) {
	    !(__WEBPACK_AMD_DEFINE_ARRAY__ = [exports], __WEBPACK_AMD_DEFINE_FACTORY__ = (factory), __WEBPACK_AMD_DEFINE_RESULT__ = (typeof __WEBPACK_AMD_DEFINE_FACTORY__ === 'function' ? (__WEBPACK_AMD_DEFINE_FACTORY__.apply(exports, __WEBPACK_AMD_DEFINE_ARRAY__)) : __WEBPACK_AMD_DEFINE_FACTORY__), __WEBPACK_AMD_DEFINE_RESULT__ !== undefined && (module.exports = __WEBPACK_AMD_DEFINE_RESULT__));
	  } else if (typeof exports === "object") {
	    factory(exports);
	  } else {
	    factory(root.babelHelpers = {});
	  }
	})(this, function (global) {
	  var babelHelpers = global;

	  babelHelpers.objectWithoutProperties = function (obj, keys) {
	    var target = {};

	    for (var i in obj) {
	      if (keys.indexOf(i) >= 0) continue;
	      if (!Object.prototype.hasOwnProperty.call(obj, i)) continue;
	      target[i] = obj[i];
	    }

	    return target;
	  };

	  babelHelpers.interopRequireDefault = function (obj) {
	    return obj && obj.__esModule ? obj : {
	      "default": obj
	    };
	  };

	  babelHelpers._extends = Object.assign || function (target) {
	    for (var i = 1; i < arguments.length; i++) {
	      var source = arguments[i];

	      for (var key in source) {
	        if (Object.prototype.hasOwnProperty.call(source, key)) {
	          target[key] = source[key];
	        }
	      }
	    }

	    return target;
	  };

	  babelHelpers.classCallCheck = function (instance, Constructor) {
	    if (!(instance instanceof Constructor)) {
	      throw new TypeError("Cannot call a class as a function");
	    }
	  };
	})

/***/ },

/***/ 1408:
/***/ function(module, exports) {

	'use strict';
	var idCount = 0;

	var _ = module.exports = {

	  has: has,

	  result: function result(value) {
	    for (var _len = arguments.length, args = Array(_len > 1 ? _len - 1 : 0), _key = 1; _key < _len; _key++) {
	      args[_key - 1] = arguments[_key];
	    }

	    return typeof value === 'function' ? value.apply(undefined, args) : value;
	  },

	  isShallowEqual: function isShallowEqual(a, b) {
	    if (a === b) return true;
	    if (a instanceof Date && b instanceof Date) return a.getTime() === b.getTime();

	    if (typeof a !== 'object' && typeof b !== 'object') return a === b;

	    if (typeof a !== typeof b) return false;

	    return shallowEqual(a, b);
	  },

	  transform: function transform(obj, cb, seed) {
	    _.each(obj, cb.bind(null, seed = seed || (Array.isArray(obj) ? [] : {})));
	    return seed;
	  },

	  each: function each(obj, cb, thisArg) {
	    if (Array.isArray(obj)) return obj.forEach(cb, thisArg);

	    for (var key in obj) if (has(obj, key)) cb.call(thisArg, obj[key], key, obj);
	  },

	  pick: function pick(obj, keys) {
	    keys = [].concat(keys);
	    return _.transform(obj, function (mapped, val, key) {
	      if (keys.indexOf(key) !== -1) mapped[key] = val;
	    }, {});
	  },

	  omit: function omit(obj, keys) {
	    keys = [].concat(keys);
	    return _.transform(obj, function (mapped, val, key) {
	      if (keys.indexOf(key) === -1) mapped[key] = val;
	    }, {});
	  },

	  find: function find(arr, cb, thisArg) {
	    var result;
	    if (Array.isArray(arr)) {
	      arr.every(function (val, idx) {
	        if (cb.call(thisArg, val, idx, arr)) return (result = val, false);
	        return true;
	      });
	      return result;
	    } else for (var key in arr) if (has(arr, key)) if (cb.call(thisArg, arr[key], key, arr)) return arr[key];
	  },

	  chunk: function chunk(array, chunkSize) {
	    var index = 0,
	        length = array ? array.length : 0,
	        result = [];

	    chunkSize = Math.max(+chunkSize || 1, 1);

	    while (index < length) result.push(array.slice(index, index += chunkSize));

	    return result;
	  },

	  splat: function splat(obj) {
	    return obj == null ? [] : [].concat(obj);
	  },

	  noop: function noop() {},

	  uniqueId: function uniqueId(prefix) {
	    return '' + ((prefix == null ? '' : prefix) + ++idCount);
	  },

	  //-- Really specific Component Utilities --

	  isFirstFocusedRender: function isFirstFocusedRender(component) {
	    return component._firstFocus || component.state.focused && (component._firstFocus = true);
	  },

	  ifNotDisabled: function ifNotDisabled(disabledOnly, fn) {
	    if (arguments.length === 1) fn = disabledOnly, disabledOnly = false;

	    //console.log('create method')
	    return function () {
	      for (var _len2 = arguments.length, args = Array(_len2), _key2 = 0; _key2 < _len2; _key2++) {
	        args[_key2] = arguments[_key2];
	      }

	      //console.log('called', disabledOnly)
	      if (!(this.isDisabled() || !disabledOnly && this.isReadOnly())) return fn.apply(this, args);
	    };
	  }
	};

	function has(o, k) {
	  return o ? Object.prototype.hasOwnProperty.call(o, k) : false;
	}

	function eql(a, b) {
	  return a === b;
	}

	/**
	 * Copyright 2013-2015, Facebook, Inc.
	 * All rights reserved.
	 */
	function shallowEqual(objA, objB) {

	  if (objA == null || objB == null) return false;

	  var keysA = Object.keys(objA),
	      keysB = Object.keys(objB);

	  if (keysA.length !== keysB.length) return false;

	  for (var i = 0; i < keysA.length; i++) if (!has(objB, keysA[i]) || !eql(objA[keysA[i]], objB[keysA[i]])) return false;

	  return true;
	}

/***/ },

/***/ 1409:
/***/ function(module, exports, __webpack_require__) {

	'use strict';
	var canUseDOM = __webpack_require__(1410);

	var contains = (function () {
	  var root = canUseDOM && document.documentElement;

	  return root && root.contains ? function (context, node) {
	    return context.contains(node);
	  } : root && root.compareDocumentPosition ? function (context, node) {
	    return context === node || !!(context.compareDocumentPosition(node) & 16);
	  } : function (context, node) {
	    if (node) do {
	      if (node === context) return true;
	    } while (node = node.parentNode);

	    return false;
	  };
	})();

	module.exports = contains;

/***/ },

/***/ 1410:
/***/ function(module, exports) {

	'use strict';
	module.exports = !!(typeof window !== 'undefined' && window.document && window.document.createElement);

/***/ },

/***/ 1411:
/***/ function(module, exports, __webpack_require__) {

	var __WEBPACK_AMD_DEFINE_RESULT__;/*!
	  Copyright (c) 2015 Jed Watson.
	  Licensed under the MIT License (MIT), see
	  http://jedwatson.github.io/classnames
	*/

	(function () {
		'use strict';

		function classNames () {

			var classes = '';

			for (var i = 0; i < arguments.length; i++) {
				var arg = arguments[i];
				if (!arg) continue;

				var argType = typeof arg;

				if ('string' === argType || 'number' === argType) {
					classes += ' ' + arg;

				} else if (Array.isArray(arg)) {
					classes += ' ' + classNames.apply(null, arg);

				} else if ('object' === argType) {
					for (var key in arg) {
						if (arg.hasOwnProperty(key) && arg[key]) {
							classes += ' ' + key;
						}
					}
				}
			}

			return classes.substr(1);
		}

		if (typeof module !== 'undefined' && module.exports) {
			module.exports = classNames;
		} else if (true){
			// AMD. Register as an anonymous module.
			!(__WEBPACK_AMD_DEFINE_RESULT__ = function () {
				return classNames;
			}.call(exports, __webpack_require__, exports, module), __WEBPACK_AMD_DEFINE_RESULT__ !== undefined && (module.exports = __WEBPACK_AMD_DEFINE_RESULT__));
		} else {
			window.classNames = classNames;
		}

	}());


/***/ },

/***/ 1412:
/***/ function(module, exports, __webpack_require__) {

	'use strict';
	var React = __webpack_require__(103),
	    _ = __webpack_require__(1408);

	var _version = React.version.split('.').map(parseFloat);

	module.exports = {

	  version: function version() {
	    return _version;
	  },

	  type: function type(component) {
	    if (_version[0] === 0 && _version[1] >= 13) return component;

	    return component.type;
	  },

	  findDOMNode: function findDOMNode(component) {
	    if (React.findDOMNode) return React.findDOMNode(component);

	    return component.getDOMNode();
	  },

	  cloneElement: function cloneElement(child, props) {
	    if (React.cloneElement) return React.cloneElement(child, props);

	    //just mutate if pre 0.13
	    _.each(props, function (value, prop) {
	      return child.props[prop] = value;
	    });

	    return child;
	  }
	};

/***/ },

/***/ 1413:
/***/ function(module, exports, __webpack_require__) {

	'use strict';
	var React = __webpack_require__(103),
	    localizers = __webpack_require__(1414).locale,
	    filters = __webpack_require__(1430);

	var filterTypes = Object.keys(filters).filter(function (i) {
	  return i !== 'filter';
	});

	module.exports = {

	  elementType: createChainableTypeChecker(function (props, propName, componentName) {

	    if (typeof props[propName] !== 'function') {
	      if (React.isValidElement(props[propName])) return new Error('Invalid prop `' + propName + '` specified in  `' + componentName + '`.' + ' Expected an Element `type`, not an actual Element');

	      if (typeof props[propName] !== 'string') return new Error('Invalid prop `' + propName + '` specified in  `' + componentName + '`.' + ' Expected an Element `type` such as a tag name or return value of React.createClass(...)');
	    }
	    return true;
	  }),

	  numberFormat: createChainableTypeChecker(function () {
	    var _localizers$number;

	    for (var _len = arguments.length, args = Array(_len), _key = 0; _key < _len; _key++) {
	      args[_key] = arguments[_key];
	    }

	    return (_localizers$number = localizers.number).propType.apply(_localizers$number, args);
	  }),

	  dateFormat: createChainableTypeChecker(function () {
	    var _localizers$date;

	    for (var _len2 = arguments.length, args = Array(_len2), _key2 = 0; _key2 < _len2; _key2++) {
	      args[_key2] = arguments[_key2];
	    }

	    return (_localizers$date = localizers.date).propType.apply(_localizers$date, args);
	  }),

	  accessor: React.PropTypes.oneOfType([React.PropTypes.string, React.PropTypes.func]),

	  message: React.PropTypes.oneOfType([React.PropTypes.func, React.PropTypes.string]),

	  filter: React.PropTypes.oneOfType([React.PropTypes.func, React.PropTypes.bool, React.PropTypes.oneOf(filterTypes)])
	};

	function createChainableTypeChecker(validate) {

	  function checkType(isRequired, props, propName, componentName, location) {
	    componentName = componentName || '<<anonymous>>';
	    if (props[propName] == null) {
	      if (isRequired) {
	        return new Error('Required prop `' + propName + '` was not specified in  `' + componentName + '`.');
	      }
	    } else return validate(props, propName, componentName, location);
	  }

	  var chainedCheckType = checkType.bind(null, false);
	  chainedCheckType.isRequired = checkType.bind(null, true);

	  return chainedCheckType;
	}

/***/ },

/***/ 1414:
/***/ function(module, exports, __webpack_require__) {

	/* WEBPACK VAR INJECTION */(function(process) {'use strict';

	var _require = __webpack_require__(1415);

	var globalizeNumberLocalizer = _require.globalizeNumberLocalizer;
	var globalizeDateLocalizer = _require.globalizeDateLocalizer;

	var globalize;

	try {
	  globalize = __webpack_require__(1418);
	} catch (err) {
	  globalize = {};
	  if (process.env.NODE_ENV !== 'production') {
	    var desc = { get: function get() {
	        throw new Error('Globalize.js is available but is still set as the localization strategy. ' + 'Please include Globalize.js or provide an alternative localization strategy.');
	      } };
	    Object.defineProperties(globalize, { format: desc, parseDate: desc, parseFloat: desc, findClosestCulture: desc, culture: desc });
	  }
	}

	module.exports = {

	  animate: __webpack_require__(1419),

	  locale: {
	    date: globalizeDateLocalizer(globalize),
	    number: globalizeNumberLocalizer(globalize)
	  }
	};
	/* WEBPACK VAR INJECTION */}.call(exports, __webpack_require__(105)))

/***/ },

/***/ 1415:
/***/ function(module, exports, __webpack_require__) {

	'use strict';

	var _require = __webpack_require__(1416);

	var NumberLocalizer = _require.NumberLocalizer;
	var DateLocalizer = _require.DateLocalizer;

	var dates = __webpack_require__(1417);

	function globalizeDateLocalizer(globalize) {
	  var shortNames = Object.create(null);

	  function getCulture(culture) {
	    return culture ? (localizer.globalize || globalize).findClosestCulture(culture) : (localizer.globalize || globalize).culture();
	  }

	  function firstOfWeek(culture) {
	    culture = getCulture(culture);
	    return culture && culture.calendar.firstDay || 0;
	  }

	  function shortDay(dayOfTheWeek) {
	    var culture = getCulture(arguments[1]),
	        name = culture.name,
	        start = firstOfWeek(culture),
	        days = function days() {
	      var days = culture.calendar.days.namesShort.slice();
	      return start === 0 ? days : days.concat(days.splice(0, start));
	    };

	    var names = shortNames[name] || (shortNames[name] = days());

	    return names[dayOfTheWeek];
	  }

	  var localizer = new DateLocalizer({

	    formats: {
	      date: 'd',
	      time: 't',
	      'default': 'f',
	      header: 'MMMM yyyy',
	      footer: 'D',
	      weekday: shortDay,
	      dayOfMonth: 'dd',
	      month: 'MMM',
	      year: 'yyyy',

	      decade: function decade(dt, culture, l) {
	        return '' + l.format(dt, l.formats.year, culture) + ' - ' + l.format(dates.endOf(dt, 'decade'), l.formats.year, culture);
	      },

	      century: function century(dt, culture, l) {
	        return '' + l.format(dt, l.formats.year, culture) + ' - ' + l.format(dates.endOf(dt, 'century'), l.formats.year, culture);
	      }
	    },

	    firstOfWeek: firstOfWeek,

	    parse: function parse(value, format, culture) {
	      return (this.globalize || globalize).parseDate(value, format, culture);
	    },

	    format: function format(value, _format, culture) {
	      return (this.globalize || globalize).format(value, _format, culture);
	    }
	  });

	  // Back-compat cruft, expose the globalize instance so setGlobalizeInstance can mutate it after initialization
	  // this works b/c there is no need to change the default prop values
	  localizer.globalize = globalize;
	  return localizer;
	}

	function globalizeNumberLocalizer(globalize) {

	  function getCulture(culture) {
	    return culture ? (localizer.globalize || globalize).findClosestCulture(culture) : (localizer.globalize || globalize).culture();
	  }

	  var localizer = new NumberLocalizer({

	    formats: {
	      'default': 'D'
	    },

	    parse: function parse(value, culture) {
	      return (this.globalize || globalize).parseFloat(value, 10, culture);
	    },

	    format: function format(value, _format2, culture) {
	      return (this.globalize || globalize).format(value, _format2, culture);
	    },

	    precision: function precision(format, _culture) {
	      var culture = getCulture(_culture),
	          numFormat = culture.numberFormat;

	      if (typeof format === 'string') {
	        if (format.length > 1) return parseFloat(format.substr(1));

	        if (format.indexOf('p') !== -1) numFormat = numFormat.percent;
	        if (format.indexOf('c') !== -1) numFormat = numFormat.curency;

	        return numFormat.decimals || null;
	      }

	      return null;
	    }
	  });

	  // see point above
	  localizer.globalize = globalize;
	  return localizer;
	}

	module.exports = {
	  globalizeNumberLocalizer: globalizeNumberLocalizer, globalizeDateLocalizer: globalizeDateLocalizer
	};

/***/ },

/***/ 1416:
/***/ function(module, exports, __webpack_require__) {

	/* WEBPACK VAR INJECTION */(function(process) {'use strict';

	var babelHelpers = __webpack_require__(1407);

	var invariant = __webpack_require__(109);

	var _require = __webpack_require__(1408);

	var has = _require.has;

	var React = __webpack_require__(103);

	var REQUIRED_NUMBER_FORMATS = ['default'];

	var localePropType = React.PropTypes.oneOfType([React.PropTypes.string, React.PropTypes.func]);

	var REQUIRED_DATE_FORMATS = ['default', 'date', 'time', 'header', 'footer', 'dayOfMonth', 'month', 'year', 'decade', 'century'];

	function _format(localizer, formatter, value, format, culture) {
	  var result = typeof format === 'function' ? format(value, culture, localizer) : formatter.call(localizer, value, format, culture);

	  invariant(result == null || typeof result === 'string', '`localizer format(..)` must return a string, null, or undefined');

	  return result;
	}

	function checkFormats(requiredFormats, formats) {
	  if (process.env.NODE_ENV !== 'production') requiredFormats.forEach(function (f) {
	    return invariant(has(formats, f), 'localizer missing required format: `%s`', f);
	  });
	}

	var NumberLocalizer = function NumberLocalizer(_ref) {
	  var _this = this;

	  var format = _ref.format;
	  var parse = _ref.parse;
	  var precision = _ref.precision;
	  var formats = _ref.formats;
	  var propType = _ref.propType;
	  babelHelpers.classCallCheck(this, NumberLocalizer);

	  invariant(typeof format === 'function', 'number localizer `format(..)` must be a function');
	  invariant(typeof parse === 'function', 'number localizer `parse(..)` must be a function');

	  // invariant(typeof precision === 'function'
	  //   , 'number localizer `precision(..)` must be a function')

	  checkFormats(REQUIRED_NUMBER_FORMATS, formats);

	  this.propType = propType || localePropType;
	  this.formats = formats;
	  this.precision = precision || function () {
	    return null;
	  };

	  this.format = function (value, str, culture) {
	    return _format(_this, format, value, str, culture);
	  };

	  this.parse = function (value, culture) {
	    var result = parse.call(_this, value, culture);

	    invariant(result == null || typeof result === 'number', 'number localizer `parse(..)` must return a number, null, or undefined');

	    return result;
	  };
	};

	var DateLocalizer = function DateLocalizer(spec) {
	  var _this2 = this;

	  babelHelpers.classCallCheck(this, DateLocalizer);

	  invariant(typeof spec.format === 'function', 'date localizer `format(..)` must be a function');
	  invariant(typeof spec.parse === 'function', 'date localizer `parse(..)` must be a function');
	  invariant(typeof spec.firstOfWeek === 'function', 'date localizer `firstOfWeek(..)` must be a function');
	  checkFormats(REQUIRED_DATE_FORMATS, spec.formats);

	  this.propType = spec.propType || localePropType;
	  this.formats = spec.formats;
	  this.startOfWeek = spec.firstOfWeek;

	  this.format = function (value, format, culture) {
	    return _format(_this2, spec.format, value, format, culture);
	  };

	  this.parse = function (value, format, culture) {
	    var result = spec.parse.call(_this2, value, format, culture);

	    invariant(result == null || result instanceof Date && !isNaN(result.getTime()), 'date localizer `parse(..)` must return a valid Date, null, or undefined');

	    return result;
	  };
	};

	module.exports = {
	  NumberLocalizer: NumberLocalizer, DateLocalizer: DateLocalizer
	};
	/* WEBPACK VAR INJECTION */}.call(exports, __webpack_require__(105)))

/***/ },

/***/ 1417:
/***/ function(module, exports) {

	var MILI    = 'milliseconds'
	  , SECONDS = 'seconds'
	  , MINUTES = 'minutes'
	  , HOURS   = 'hours'
	  , DAY     = 'day'
	  , WEEK    = 'week'
	  , MONTH   = 'month'
	  , YEAR    = 'year'
	  , DECADE  = 'decade'
	  , CENTURY = 'century';

	var dates = module.exports = {

	  add: function(date, num, unit) {
	    date = new Date(date)

	    switch (unit){
	      case MILI:
	      case SECONDS:
	      case MINUTES:
	      case HOURS:
	      case YEAR:
	        return dates[unit](date, dates[unit](date) + num)
	      case DAY:
	        return dates.date(date, dates.date(date) + num)
	      case WEEK:
	        return dates.date(date, dates.date(date) + (7 * num))
	      case MONTH:
	        return monthMath(date, num)
	      case DECADE:
	        return dates.year(date, dates.year(date) + (num * 10))
	      case CENTURY:
	        return dates.year(date, dates.year(date) + (num * 100))
	    }

	    throw new TypeError('Invalid units: "' + unit + '"')
	  },

	  subtract: function(date, num, unit) {
	    return dates.add(date, -num, unit)
	  },

	  startOf: function(date, unit, firstOfWeek) {
	    date = new Date(date)

	    switch (unit) {
	      case 'century':
	      case 'decade':
	      case 'year':
	          date = dates.month(date, 0);
	      case 'month':
	          date = dates.date(date, 1);
	      case 'week':
	      case 'day':
	          date = dates.hours(date, 0);
	      case 'hours':
	          date = dates.minutes(date, 0);
	      case 'minutes':
	          date = dates.seconds(date, 0);
	      case 'seconds':
	          date = dates.milliseconds(date, 0);
	    }

	    if (unit === DECADE)
	      date = dates.subtract(date, dates.year(date) % 10, 'year')

	    if (unit === CENTURY)
	      date = dates.subtract(date, dates.year(date) % 100, 'year')

	    if (unit === WEEK)
	      date = dates.weekday(date, 0, firstOfWeek);

	    return date
	  },

	  endOf: function(date, unit, firstOfWeek){
	    date = new Date(date)
	    date = dates.startOf(date, unit, firstOfWeek)
	    date = dates.add(date, 1, unit)
	    date = dates.subtract(date, 1, MILI)
	    return date
	  },

	  eq:  createComparer(function(a, b){ return a === b }),
	  neq: createComparer(function(a, b){ return a !== b }),
	  gt:  createComparer(function(a, b){ return a > b }),
	  gte: createComparer(function(a, b){ return a >= b }),
	  lt:  createComparer(function(a, b){ return a < b }),
	  lte: createComparer(function(a, b){ return a <= b }),

	  min: function(){
	    return new Date(Math.min.apply(Math, arguments))
	  },

	  max: function(){
	    return new Date(Math.max.apply(Math, arguments))
	  },

	  inRange: function(day, min, max, unit){
	    unit = unit || 'day'

	    return (!min || dates.gte(day, min, unit))
	        && (!max || dates.lte(day, max, unit))
	  },

	  milliseconds:   createAccessor('Milliseconds'),
	  seconds:        createAccessor('Seconds'),
	  minutes:        createAccessor('Minutes'),
	  hours:          createAccessor('Hours'),
	  day:            createAccessor('Day'),
	  date:           createAccessor('Date'),
	  month:          createAccessor('Month'),
	  year:           createAccessor('FullYear'),

	  decade: function (date, val) {
	    return val === undefined
	      ? dates.year(dates.startOf(date, DECADE))
	      : dates.add(date, val + 10, YEAR);
	  },

	  century: function (date, val) {
	    return val === undefined
	      ? dates.year(dates.startOf(date, CENTURY))
	      : dates.add(date, val + 100, YEAR);
	  },

	  weekday: function (date, val, firstDay) {
	      var weekday = (dates.day(date) + 7 - (firstDay || 0) ) % 7;

	      return val === undefined
	        ? weekday
	        : dates.add(date, val - weekday, DAY);
	  }
	}


	function monthMath(date, val){
	  var current = dates.month(date)
	    , newMonth  = (current + val);

	    date = dates.month(date, newMonth)

	    if (newMonth < 0 ) newMonth = 12 + val

	    //month rollover
	    if ( dates.month(date) !== ( newMonth % 12))
	      date = dates.date(date, 0) //move to last of month

	    return date
	}

	function createAccessor(method){
	  return function(date, val){
	    if (val === undefined)
	      return date['get' + method]()

	    date = new Date(date)
	    date['set' + method](val)
	    return date
	  }
	}

	function createComparer(operator) {
	  return function (a, b, unit, maybeFoW) {
	    return operator(+dates.startOf(a, unit, maybeFoW), +dates.startOf(b, unit, maybeFoW))
	  };
	}


/***/ },

/***/ 1418:
/***/ function(module, exports, __webpack_require__) {

	/*!
	 * Globalize
	 *
	 * http://github.com/jquery/globalize
	 *
	 * Copyright Software Freedom Conservancy, Inc.
	 * Dual licensed under the MIT or GPL Version 2 licenses.
	 * http://jquery.org/license
	 */

	(function( window, undefined ) {

	var Globalize,
		// private variables
		regexHex,
		regexInfinity,
		regexParseFloat,
		regexTrim,
		// private JavaScript utility functions
		arrayIndexOf,
		endsWith,
		extend,
		isArray,
		isFunction,
		isObject,
		startsWith,
		trim,
		truncate,
		zeroPad,
		// private Globalization utility functions
		appendPreOrPostMatch,
		expandFormat,
		formatDate,
		formatNumber,
		getTokenRegExp,
		getEra,
		getEraYear,
		parseExact,
		parseNegativePattern;

	// Global variable (Globalize) or CommonJS module (globalize)
	Globalize = function( cultureSelector ) {
		return new Globalize.prototype.init( cultureSelector );
	};

	if ( true ) {
		// Assume CommonJS
		module.exports = Globalize;
	} else {
		// Export as global variable
		window.Globalize = Globalize;
	}

	Globalize.cultures = {};

	Globalize.prototype = {
		constructor: Globalize,
		init: function( cultureSelector ) {
			this.cultures = Globalize.cultures;
			this.cultureSelector = cultureSelector;

			return this;
		}
	};
	Globalize.prototype.init.prototype = Globalize.prototype;

	// 1. When defining a culture, all fields are required except the ones stated as optional.
	// 2. Each culture should have a ".calendars" object with at least one calendar named "standard"
	//    which serves as the default calendar in use by that culture.
	// 3. Each culture should have a ".calendar" object which is the current calendar being used,
	//    it may be dynamically changed at any time to one of the calendars in ".calendars".
	Globalize.cultures[ "default" ] = {
		// A unique name for the culture in the form <language code>-<country/region code>
		name: "en",
		// the name of the culture in the english language
		englishName: "English",
		// the name of the culture in its own language
		nativeName: "English",
		// whether the culture uses right-to-left text
		isRTL: false,
		// "language" is used for so-called "specific" cultures.
		// For example, the culture "es-CL" means "Spanish, in Chili".
		// It represents the Spanish-speaking culture as it is in Chili,
		// which might have different formatting rules or even translations
		// than Spanish in Spain. A "neutral" culture is one that is not
		// specific to a region. For example, the culture "es" is the generic
		// Spanish culture, which may be a more generalized version of the language
		// that may or may not be what a specific culture expects.
		// For a specific culture like "es-CL", the "language" field refers to the
		// neutral, generic culture information for the language it is using.
		// This is not always a simple matter of the string before the dash.
		// For example, the "zh-Hans" culture is netural (Simplified Chinese).
		// And the "zh-SG" culture is Simplified Chinese in Singapore, whose lanugage
		// field is "zh-CHS", not "zh".
		// This field should be used to navigate from a specific culture to it's
		// more general, neutral culture. If a culture is already as general as it
		// can get, the language may refer to itself.
		language: "en",
		// numberFormat defines general number formatting rules, like the digits in
		// each grouping, the group separator, and how negative numbers are displayed.
		numberFormat: {
			// [negativePattern]
			// Note, numberFormat.pattern has no "positivePattern" unlike percent and currency,
			// but is still defined as an array for consistency with them.
			//   negativePattern: one of "(n)|-n|- n|n-|n -"
			pattern: [ "-n" ],
			// number of decimal places normally shown
			decimals: 2,
			// string that separates number groups, as in 1,000,000
			",": ",",
			// string that separates a number from the fractional portion, as in 1.99
			".": ".",
			// array of numbers indicating the size of each number group.
			// TODO: more detailed description and example
			groupSizes: [ 3 ],
			// symbol used for positive numbers
			"+": "+",
			// symbol used for negative numbers
			"-": "-",
			// symbol used for NaN (Not-A-Number)
			"NaN": "NaN",
			// symbol used for Negative Infinity
			negativeInfinity: "-Infinity",
			// symbol used for Positive Infinity
			positiveInfinity: "Infinity",
			percent: {
				// [negativePattern, positivePattern]
				//   negativePattern: one of "-n %|-n%|-%n|%-n|%n-|n-%|n%-|-% n|n %-|% n-|% -n|n- %"
				//   positivePattern: one of "n %|n%|%n|% n"
				pattern: [ "-n %", "n %" ],
				// number of decimal places normally shown
				decimals: 2,
				// array of numbers indicating the size of each number group.
				// TODO: more detailed description and example
				groupSizes: [ 3 ],
				// string that separates number groups, as in 1,000,000
				",": ",",
				// string that separates a number from the fractional portion, as in 1.99
				".": ".",
				// symbol used to represent a percentage
				symbol: "%"
			},
			currency: {
				// [negativePattern, positivePattern]
				//   negativePattern: one of "($n)|-$n|$-n|$n-|(n$)|-n$|n-$|n$-|-n $|-$ n|n $-|$ n-|$ -n|n- $|($ n)|(n $)"
				//   positivePattern: one of "$n|n$|$ n|n $"
				pattern: [ "($n)", "$n" ],
				// number of decimal places normally shown
				decimals: 2,
				// array of numbers indicating the size of each number group.
				// TODO: more detailed description and example
				groupSizes: [ 3 ],
				// string that separates number groups, as in 1,000,000
				",": ",",
				// string that separates a number from the fractional portion, as in 1.99
				".": ".",
				// symbol used to represent currency
				symbol: "$"
			}
		},
		// calendars defines all the possible calendars used by this culture.
		// There should be at least one defined with name "standard", and is the default
		// calendar used by the culture.
		// A calendar contains information about how dates are formatted, information about
		// the calendar's eras, a standard set of the date formats,
		// translations for day and month names, and if the calendar is not based on the Gregorian
		// calendar, conversion functions to and from the Gregorian calendar.
		calendars: {
			standard: {
				// name that identifies the type of calendar this is
				name: "Gregorian_USEnglish",
				// separator of parts of a date (e.g. "/" in 11/05/1955)
				"/": "/",
				// separator of parts of a time (e.g. ":" in 05:44 PM)
				":": ":",
				// the first day of the week (0 = Sunday, 1 = Monday, etc)
				firstDay: 0,
				days: {
					// full day names
					names: [ "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday" ],
					// abbreviated day names
					namesAbbr: [ "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat" ],
					// shortest day names
					namesShort: [ "Su", "Mo", "Tu", "We", "Th", "Fr", "Sa" ]
				},
				months: {
					// full month names (13 months for lunar calendards -- 13th month should be "" if not lunar)
					names: [ "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December", "" ],
					// abbreviated month names
					namesAbbr: [ "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec", "" ]
				},
				// AM and PM designators in one of these forms:
				// The usual view, and the upper and lower case versions
				//   [ standard, lowercase, uppercase ]
				// The culture does not use AM or PM (likely all standard date formats use 24 hour time)
				//   null
				AM: [ "AM", "am", "AM" ],
				PM: [ "PM", "pm", "PM" ],
				eras: [
					// eras in reverse chronological order.
					// name: the name of the era in this culture (e.g. A.D., C.E.)
					// start: when the era starts in ticks (gregorian, gmt), null if it is the earliest supported era.
					// offset: offset in years from gregorian calendar
					{
						"name": "A.D.",
						"start": null,
						"offset": 0
					}
				],
				// when a two digit year is given, it will never be parsed as a four digit
				// year greater than this year (in the appropriate era for the culture)
				// Set it as a full year (e.g. 2029) or use an offset format starting from
				// the current year: "+19" would correspond to 2029 if the current year 2010.
				twoDigitYearMax: 2029,
				// set of predefined date and time patterns used by the culture
				// these represent the format someone in this culture would expect
				// to see given the portions of the date that are shown.
				patterns: {
					// short date pattern
					d: "M/d/yyyy",
					// long date pattern
					D: "dddd, MMMM dd, yyyy",
					// short time pattern
					t: "h:mm tt",
					// long time pattern
					T: "h:mm:ss tt",
					// long date, short time pattern
					f: "dddd, MMMM dd, yyyy h:mm tt",
					// long date, long time pattern
					F: "dddd, MMMM dd, yyyy h:mm:ss tt",
					// month/day pattern
					M: "MMMM dd",
					// month/year pattern
					Y: "yyyy MMMM",
					// S is a sortable format that does not vary by culture
					S: "yyyy\u0027-\u0027MM\u0027-\u0027dd\u0027T\u0027HH\u0027:\u0027mm\u0027:\u0027ss"
				}
				// optional fields for each calendar:
				/*
				monthsGenitive:
					Same as months but used when the day preceeds the month.
					Omit if the culture has no genitive distinction in month names.
					For an explaination of genitive months, see http://blogs.msdn.com/michkap/archive/2004/12/25/332259.aspx
				convert:
					Allows for the support of non-gregorian based calendars. This convert object is used to
					to convert a date to and from a gregorian calendar date to handle parsing and formatting.
					The two functions:
						fromGregorian( date )
							Given the date as a parameter, return an array with parts [ year, month, day ]
							corresponding to the non-gregorian based year, month, and day for the calendar.
						toGregorian( year, month, day )
							Given the non-gregorian year, month, and day, return a new Date() object
							set to the corresponding date in the gregorian calendar.
				*/
			}
		},
		// For localized strings
		messages: {}
	};

	Globalize.cultures[ "default" ].calendar = Globalize.cultures[ "default" ].calendars.standard;

	Globalize.cultures.en = Globalize.cultures[ "default" ];

	Globalize.cultureSelector = "en";

	//
	// private variables
	//

	regexHex = /^0x[a-f0-9]+$/i;
	regexInfinity = /^[+\-]?infinity$/i;
	regexParseFloat = /^[+\-]?\d*\.?\d*(e[+\-]?\d+)?$/;
	regexTrim = /^\s+|\s+$/g;

	//
	// private JavaScript utility functions
	//

	arrayIndexOf = function( array, item ) {
		if ( array.indexOf ) {
			return array.indexOf( item );
		}
		for ( var i = 0, length = array.length; i < length; i++ ) {
			if ( array[i] === item ) {
				return i;
			}
		}
		return -1;
	};

	endsWith = function( value, pattern ) {
		return value.substr( value.length - pattern.length ) === pattern;
	};

	extend = function() {
		var options, name, src, copy, copyIsArray, clone,
			target = arguments[0] || {},
			i = 1,
			length = arguments.length,
			deep = false;

		// Handle a deep copy situation
		if ( typeof target === "boolean" ) {
			deep = target;
			target = arguments[1] || {};
			// skip the boolean and the target
			i = 2;
		}

		// Handle case when target is a string or something (possible in deep copy)
		if ( typeof target !== "object" && !isFunction(target) ) {
			target = {};
		}

		for ( ; i < length; i++ ) {
			// Only deal with non-null/undefined values
			if ( (options = arguments[ i ]) != null ) {
				// Extend the base object
				for ( name in options ) {
					src = target[ name ];
					copy = options[ name ];

					// Prevent never-ending loop
					if ( target === copy ) {
						continue;
					}

					// Recurse if we're merging plain objects or arrays
					if ( deep && copy && ( isObject(copy) || (copyIsArray = isArray(copy)) ) ) {
						if ( copyIsArray ) {
							copyIsArray = false;
							clone = src && isArray(src) ? src : [];

						} else {
							clone = src && isObject(src) ? src : {};
						}

						// Never move original objects, clone them
						target[ name ] = extend( deep, clone, copy );

					// Don't bring in undefined values
					} else if ( copy !== undefined ) {
						target[ name ] = copy;
					}
				}
			}
		}

		// Return the modified object
		return target;
	};

	isArray = Array.isArray || function( obj ) {
		return Object.prototype.toString.call( obj ) === "[object Array]";
	};

	isFunction = function( obj ) {
		return Object.prototype.toString.call( obj ) === "[object Function]";
	};

	isObject = function( obj ) {
		return Object.prototype.toString.call( obj ) === "[object Object]";
	};

	startsWith = function( value, pattern ) {
		return value.indexOf( pattern ) === 0;
	};

	trim = function( value ) {
		return ( value + "" ).replace( regexTrim, "" );
	};

	truncate = function( value ) {
		if ( isNaN( value ) ) {
			return NaN;
		}
		return Math[ value < 0 ? "ceil" : "floor" ]( value );
	};

	zeroPad = function( str, count, left ) {
		var l;
		for ( l = str.length; l < count; l += 1 ) {
			str = ( left ? ("0" + str) : (str + "0") );
		}
		return str;
	};

	//
	// private Globalization utility functions
	//

	appendPreOrPostMatch = function( preMatch, strings ) {
		// appends pre- and post- token match strings while removing escaped characters.
		// Returns a single quote count which is used to determine if the token occurs
		// in a string literal.
		var quoteCount = 0,
			escaped = false;
		for ( var i = 0, il = preMatch.length; i < il; i++ ) {
			var c = preMatch.charAt( i );
			switch ( c ) {
				case "\'":
					if ( escaped ) {
						strings.push( "\'" );
					}
					else {
						quoteCount++;
					}
					escaped = false;
					break;
				case "\\":
					if ( escaped ) {
						strings.push( "\\" );
					}
					escaped = !escaped;
					break;
				default:
					strings.push( c );
					escaped = false;
					break;
			}
		}
		return quoteCount;
	};

	expandFormat = function( cal, format ) {
		// expands unspecified or single character date formats into the full pattern.
		format = format || "F";
		var pattern,
			patterns = cal.patterns,
			len = format.length;
		if ( len === 1 ) {
			pattern = patterns[ format ];
			if ( !pattern ) {
				throw "Invalid date format string \'" + format + "\'.";
			}
			format = pattern;
		}
		else if ( len === 2 && format.charAt(0) === "%" ) {
			// %X escape format -- intended as a custom format string that is only one character, not a built-in format.
			format = format.charAt( 1 );
		}
		return format;
	};

	formatDate = function( value, format, culture ) {
		var cal = culture.calendar,
			convert = cal.convert,
			ret;

		if ( !format || !format.length || format === "i" ) {
			if ( culture && culture.name.length ) {
				if ( convert ) {
					// non-gregorian calendar, so we cannot use built-in toLocaleString()
					ret = formatDate( value, cal.patterns.F, culture );
				}
				else {
					var eraDate = new Date( value.getTime() ),
						era = getEra( value, cal.eras );
					eraDate.setFullYear( getEraYear(value, cal, era) );
					ret = eraDate.toLocaleString();
				}
			}
			else {
				ret = value.toString();
			}
			return ret;
		}

		var eras = cal.eras,
			sortable = format === "s";
		format = expandFormat( cal, format );

		// Start with an empty string
		ret = [];
		var hour,
			zeros = [ "0", "00", "000" ],
			foundDay,
			checkedDay,
			dayPartRegExp = /([^d]|^)(d|dd)([^d]|$)/g,
			quoteCount = 0,
			tokenRegExp = getTokenRegExp(),
			converted;

		function padZeros( num, c ) {
			var r, s = num + "";
			if ( c > 1 && s.length < c ) {
				r = ( zeros[c - 2] + s);
				return r.substr( r.length - c, c );
			}
			else {
				r = s;
			}
			return r;
		}

		function hasDay() {
			if ( foundDay || checkedDay ) {
				return foundDay;
			}
			foundDay = dayPartRegExp.test( format );
			checkedDay = true;
			return foundDay;
		}

		function getPart( date, part ) {
			if ( converted ) {
				return converted[ part ];
			}
			switch ( part ) {
				case 0:
					return date.getFullYear();
				case 1:
					return date.getMonth();
				case 2:
					return date.getDate();
				default:
					throw "Invalid part value " + part;
			}
		}

		if ( !sortable && convert ) {
			converted = convert.fromGregorian( value );
		}

		for ( ; ; ) {
			// Save the current index
			var index = tokenRegExp.lastIndex,
				// Look for the next pattern
				ar = tokenRegExp.exec( format );

			// Append the text before the pattern (or the end of the string if not found)
			var preMatch = format.slice( index, ar ? ar.index : format.length );
			quoteCount += appendPreOrPostMatch( preMatch, ret );

			if ( !ar ) {
				break;
			}

			// do not replace any matches that occur inside a string literal.
			if ( quoteCount % 2 ) {
				ret.push( ar[0] );
				continue;
			}

			var current = ar[ 0 ],
				clength = current.length;

			switch ( current ) {
				case "ddd":
					//Day of the week, as a three-letter abbreviation
				case "dddd":
					// Day of the week, using the full name
					var names = ( clength === 3 ) ? cal.days.namesAbbr : cal.days.names;
					ret.push( names[value.getDay()] );
					break;
				case "d":
					// Day of month, without leading zero for single-digit days
				case "dd":
					// Day of month, with leading zero for single-digit days
					foundDay = true;
					ret.push(
						padZeros( getPart(value, 2), clength )
					);
					break;
				case "MMM":
					// Month, as a three-letter abbreviation
				case "MMMM":
					// Month, using the full name
					var part = getPart( value, 1 );
					ret.push(
						( cal.monthsGenitive && hasDay() ) ?
						( cal.monthsGenitive[ clength === 3 ? "namesAbbr" : "names" ][ part ] ) :
						( cal.months[ clength === 3 ? "namesAbbr" : "names" ][ part ] )
					);
					break;
				case "M":
					// Month, as digits, with no leading zero for single-digit months
				case "MM":
					// Month, as digits, with leading zero for single-digit months
					ret.push(
						padZeros( getPart(value, 1) + 1, clength )
					);
					break;
				case "y":
					// Year, as two digits, but with no leading zero for years less than 10
				case "yy":
					// Year, as two digits, with leading zero for years less than 10
				case "yyyy":
					// Year represented by four full digits
					part = converted ? converted[ 0 ] : getEraYear( value, cal, getEra(value, eras), sortable );
					if ( clength < 4 ) {
						part = part % 100;
					}
					ret.push(
						padZeros( part, clength )
					);
					break;
				case "h":
					// Hours with no leading zero for single-digit hours, using 12-hour clock
				case "hh":
					// Hours with leading zero for single-digit hours, using 12-hour clock
					hour = value.getHours() % 12;
					if ( hour === 0 ) hour = 12;
					ret.push(
						padZeros( hour, clength )
					);
					break;
				case "H":
					// Hours with no leading zero for single-digit hours, using 24-hour clock
				case "HH":
					// Hours with leading zero for single-digit hours, using 24-hour clock
					ret.push(
						padZeros( value.getHours(), clength )
					);
					break;
				case "m":
					// Minutes with no leading zero for single-digit minutes
				case "mm":
					// Minutes with leading zero for single-digit minutes
					ret.push(
						padZeros( value.getMinutes(), clength )
					);
					break;
				case "s":
					// Seconds with no leading zero for single-digit seconds
				case "ss":
					// Seconds with leading zero for single-digit seconds
					ret.push(
						padZeros( value.getSeconds(), clength )
					);
					break;
				case "t":
					// One character am/pm indicator ("a" or "p")
				case "tt":
					// Multicharacter am/pm indicator
					part = value.getHours() < 12 ? ( cal.AM ? cal.AM[0] : " " ) : ( cal.PM ? cal.PM[0] : " " );
					ret.push( clength === 1 ? part.charAt(0) : part );
					break;
				case "f":
					// Deciseconds
				case "ff":
					// Centiseconds
				case "fff":
					// Milliseconds
					ret.push(
						padZeros( value.getMilliseconds(), 3 ).substr( 0, clength )
					);
					break;
				case "z":
					// Time zone offset, no leading zero
				case "zz":
					// Time zone offset with leading zero
					hour = value.getTimezoneOffset() / 60;
					ret.push(
						( hour <= 0 ? "+" : "-" ) + padZeros( Math.floor(Math.abs(hour)), clength )
					);
					break;
				case "zzz":
					// Time zone offset with leading zero
					hour = value.getTimezoneOffset() / 60;
					ret.push(
						( hour <= 0 ? "+" : "-" ) + padZeros( Math.floor(Math.abs(hour)), 2 ) +
						// Hard coded ":" separator, rather than using cal.TimeSeparator
						// Repeated here for consistency, plus ":" was already assumed in date parsing.
						":" + padZeros( Math.abs(value.getTimezoneOffset() % 60), 2 )
					);
					break;
				case "g":
				case "gg":
					if ( cal.eras ) {
						ret.push(
							cal.eras[ getEra(value, eras) ].name
						);
					}
					break;
			case "/":
				ret.push( cal["/"] );
				break;
			default:
				throw "Invalid date format pattern \'" + current + "\'.";
			}
		}
		return ret.join( "" );
	};

	// formatNumber
	(function() {
		var expandNumber;

		expandNumber = function( number, precision, formatInfo ) {
			var groupSizes = formatInfo.groupSizes,
				curSize = groupSizes[ 0 ],
				curGroupIndex = 1,
				factor = Math.pow( 10, precision ),
				rounded = Math.round( number * factor ) / factor;

			if ( !isFinite(rounded) ) {
				rounded = number;
			}
			number = rounded;

			var numberString = number+"",
				right = "",
				split = numberString.split( /e/i ),
				exponent = split.length > 1 ? parseInt( split[1], 10 ) : 0;
			numberString = split[ 0 ];
			split = numberString.split( "." );
			numberString = split[ 0 ];
			right = split.length > 1 ? split[ 1 ] : "";

			var l;
			if ( exponent > 0 ) {
				right = zeroPad( right, exponent, false );
				numberString += right.slice( 0, exponent );
				right = right.substr( exponent );
			}
			else if ( exponent < 0 ) {
				exponent = -exponent;
				numberString = zeroPad( numberString, exponent + 1, true );
				right = numberString.slice( -exponent, numberString.length ) + right;
				numberString = numberString.slice( 0, -exponent );
			}

			if ( precision > 0 ) {
				right = formatInfo[ "." ] +
					( (right.length > precision) ? right.slice(0, precision) : zeroPad(right, precision) );
			}
			else {
				right = "";
			}

			var stringIndex = numberString.length - 1,
				sep = formatInfo[ "," ],
				ret = "";

			while ( stringIndex >= 0 ) {
				if ( curSize === 0 || curSize > stringIndex ) {
					return numberString.slice( 0, stringIndex + 1 ) + ( ret.length ? (sep + ret + right) : right );
				}
				ret = numberString.slice( stringIndex - curSize + 1, stringIndex + 1 ) + ( ret.length ? (sep + ret) : "" );

				stringIndex -= curSize;

				if ( curGroupIndex < groupSizes.length ) {
					curSize = groupSizes[ curGroupIndex ];
					curGroupIndex++;
				}
			}

			return numberString.slice( 0, stringIndex + 1 ) + sep + ret + right;
		};

		formatNumber = function( value, format, culture ) {
			if ( !isFinite(value) ) {
				if ( value === Infinity ) {
					return culture.numberFormat.positiveInfinity;
				}
				if ( value === -Infinity ) {
					return culture.numberFormat.negativeInfinity;
				}
				return culture.numberFormat[ "NaN" ];
			}
			if ( !format || format === "i" ) {
				return culture.name.length ? value.toLocaleString() : value.toString();
			}
			format = format || "D";

			var nf = culture.numberFormat,
				number = Math.abs( value ),
				precision = -1,
				pattern;
			if ( format.length > 1 ) precision = parseInt( format.slice(1), 10 );

			var current = format.charAt( 0 ).toUpperCase(),
				formatInfo;

			switch ( current ) {
				case "D":
					pattern = "n";
					number = truncate( number );
					if ( precision !== -1 ) {
						number = zeroPad( "" + number, precision, true );
					}
					if ( value < 0 ) number = "-" + number;
					break;
				case "N":
					formatInfo = nf;
					/* falls through */
				case "C":
					formatInfo = formatInfo || nf.currency;
					/* falls through */
				case "P":
					formatInfo = formatInfo || nf.percent;
					pattern = value < 0 ? formatInfo.pattern[ 0 ] : ( formatInfo.pattern[1] || "n" );
					if ( precision === -1 ) precision = formatInfo.decimals;
					number = expandNumber( number * (current === "P" ? 100 : 1), precision, formatInfo );
					break;
				default:
					throw "Bad number format specifier: " + current;
			}

			var patternParts = /n|\$|-|%/g,
				ret = "";
			for ( ; ; ) {
				var index = patternParts.lastIndex,
					ar = patternParts.exec( pattern );

				ret += pattern.slice( index, ar ? ar.index : pattern.length );

				if ( !ar ) {
					break;
				}

				switch ( ar[0] ) {
					case "n":
						ret += number;
						break;
					case "$":
						ret += nf.currency.symbol;
						break;
					case "-":
						// don't make 0 negative
						if ( /[1-9]/.test(number) ) {
							ret += nf[ "-" ];
						}
						break;
					case "%":
						ret += nf.percent.symbol;
						break;
				}
			}

			return ret;
		};

	}());

	getTokenRegExp = function() {
		// regular expression for matching date and time tokens in format strings.
		return (/\/|dddd|ddd|dd|d|MMMM|MMM|MM|M|yyyy|yy|y|hh|h|HH|H|mm|m|ss|s|tt|t|fff|ff|f|zzz|zz|z|gg|g/g);
	};

	getEra = function( date, eras ) {
		if ( !eras ) return 0;
		var start, ticks = date.getTime();
		for ( var i = 0, l = eras.length; i < l; i++ ) {
			start = eras[ i ].start;
			if ( start === null || ticks >= start ) {
				return i;
			}
		}
		return 0;
	};

	getEraYear = function( date, cal, era, sortable ) {
		var year = date.getFullYear();
		if ( !sortable && cal.eras ) {
			// convert normal gregorian year to era-shifted gregorian
			// year by subtracting the era offset
			year -= cal.eras[ era ].offset;
		}
		return year;
	};

	// parseExact
	(function() {
		var expandYear,
			getDayIndex,
			getMonthIndex,
			getParseRegExp,
			outOfRange,
			toUpper,
			toUpperArray;

		expandYear = function( cal, year ) {
			// expands 2-digit year into 4 digits.
			if ( year < 100 ) {
				var now = new Date(),
					era = getEra( now ),
					curr = getEraYear( now, cal, era ),
					twoDigitYearMax = cal.twoDigitYearMax;
				twoDigitYearMax = typeof twoDigitYearMax === "string" ? new Date().getFullYear() % 100 + parseInt( twoDigitYearMax, 10 ) : twoDigitYearMax;
				year += curr - ( curr % 100 );
				if ( year > twoDigitYearMax ) {
					year -= 100;
				}
			}
			return year;
		};

		getDayIndex = function	( cal, value, abbr ) {
			var ret,
				days = cal.days,
				upperDays = cal._upperDays;
			if ( !upperDays ) {
				cal._upperDays = upperDays = [
					toUpperArray( days.names ),
					toUpperArray( days.namesAbbr ),
					toUpperArray( days.namesShort )
				];
			}
			value = toUpper( value );
			if ( abbr ) {
				ret = arrayIndexOf( upperDays[1], value );
				if ( ret === -1 ) {
					ret = arrayIndexOf( upperDays[2], value );
				}
			}
			else {
				ret = arrayIndexOf( upperDays[0], value );
			}
			return ret;
		};

		getMonthIndex = function( cal, value, abbr ) {
			var months = cal.months,
				monthsGen = cal.monthsGenitive || cal.months,
				upperMonths = cal._upperMonths,
				upperMonthsGen = cal._upperMonthsGen;
			if ( !upperMonths ) {
				cal._upperMonths = upperMonths = [
					toUpperArray( months.names ),
					toUpperArray( months.namesAbbr )
				];
				cal._upperMonthsGen = upperMonthsGen = [
					toUpperArray( monthsGen.names ),
					toUpperArray( monthsGen.namesAbbr )
				];
			}
			value = toUpper( value );
			var i = arrayIndexOf( abbr ? upperMonths[1] : upperMonths[0], value );
			if ( i < 0 ) {
				i = arrayIndexOf( abbr ? upperMonthsGen[1] : upperMonthsGen[0], value );
			}
			return i;
		};

		getParseRegExp = function( cal, format ) {
			// converts a format string into a regular expression with groups that
			// can be used to extract date fields from a date string.
			// check for a cached parse regex.
			var re = cal._parseRegExp;
			if ( !re ) {
				cal._parseRegExp = re = {};
			}
			else {
				var reFormat = re[ format ];
				if ( reFormat ) {
					return reFormat;
				}
			}

			// expand single digit formats, then escape regular expression characters.
			var expFormat = expandFormat( cal, format ).replace( /([\^\$\.\*\+\?\|\[\]\(\)\{\}])/g, "\\\\$1" ),
				regexp = [ "^" ],
				groups = [],
				index = 0,
				quoteCount = 0,
				tokenRegExp = getTokenRegExp(),
				match;

			// iterate through each date token found.
			while ( (match = tokenRegExp.exec(expFormat)) !== null ) {
				var preMatch = expFormat.slice( index, match.index );
				index = tokenRegExp.lastIndex;

				// don't replace any matches that occur inside a string literal.
				quoteCount += appendPreOrPostMatch( preMatch, regexp );
				if ( quoteCount % 2 ) {
					regexp.push( match[0] );
					continue;
				}

				// add a regex group for the token.
				var m = match[ 0 ],
					len = m.length,
					add;
				switch ( m ) {
					case "dddd": case "ddd":
					case "MMMM": case "MMM":
					case "gg": case "g":
						add = "(\\D+)";
						break;
					case "tt": case "t":
						add = "(\\D*)";
						break;
					case "yyyy":
					case "fff":
					case "ff":
					case "f":
						add = "(\\d{" + len + "})";
						break;
					case "dd": case "d":
					case "MM": case "M":
					case "yy": case "y":
					case "HH": case "H":
					case "hh": case "h":
					case "mm": case "m":
					case "ss": case "s":
						add = "(\\d\\d?)";
						break;
					case "zzz":
						add = "([+-]?\\d\\d?:\\d{2})";
						break;
					case "zz": case "z":
						add = "([+-]?\\d\\d?)";
						break;
					case "/":
						add = "(\\/)";
						break;
					default:
						throw "Invalid date format pattern \'" + m + "\'.";
				}
				if ( add ) {
					regexp.push( add );
				}
				groups.push( match[0] );
			}
			appendPreOrPostMatch( expFormat.slice(index), regexp );
			regexp.push( "$" );

			// allow whitespace to differ when matching formats.
			var regexpStr = regexp.join( "" ).replace( /\s+/g, "\\s+" ),
				parseRegExp = { "regExp": regexpStr, "groups": groups };

			// cache the regex for this format.
			return re[ format ] = parseRegExp;
		};

		outOfRange = function( value, low, high ) {
			return value < low || value > high;
		};

		toUpper = function( value ) {
			// "he-IL" has non-breaking space in weekday names.
			return value.split( "\u00A0" ).join( " " ).toUpperCase();
		};

		toUpperArray = function( arr ) {
			var results = [];
			for ( var i = 0, l = arr.length; i < l; i++ ) {
				results[ i ] = toUpper( arr[i] );
			}
			return results;
		};

		parseExact = function( value, format, culture ) {
			// try to parse the date string by matching against the format string
			// while using the specified culture for date field names.
			value = trim( value );
			var cal = culture.calendar,
				// convert date formats into regular expressions with groupings.
				// use the regexp to determine the input format and extract the date fields.
				parseInfo = getParseRegExp( cal, format ),
				match = new RegExp( parseInfo.regExp ).exec( value );
			if ( match === null ) {
				return null;
			}
			// found a date format that matches the input.
			var groups = parseInfo.groups,
				era = null, year = null, month = null, date = null, weekDay = null,
				hour = 0, hourOffset, min = 0, sec = 0, msec = 0, tzMinOffset = null,
				pmHour = false;
			// iterate the format groups to extract and set the date fields.
			for ( var j = 0, jl = groups.length; j < jl; j++ ) {
				var matchGroup = match[ j + 1 ];
				if ( matchGroup ) {
					var current = groups[ j ],
						clength = current.length,
						matchInt = parseInt( matchGroup, 10 );
					switch ( current ) {
						case "dd": case "d":
							// Day of month.
							date = matchInt;
							// check that date is generally in valid range, also checking overflow below.
							if ( outOfRange(date, 1, 31) ) return null;
							break;
						case "MMM": case "MMMM":
							month = getMonthIndex( cal, matchGroup, clength === 3 );
							if ( outOfRange(month, 0, 11) ) return null;
							break;
						case "M": case "MM":
							// Month.
							month = matchInt - 1;
							if ( outOfRange(month, 0, 11) ) return null;
							break;
						case "y": case "yy":
						case "yyyy":
							year = clength < 4 ? expandYear( cal, matchInt ) : matchInt;
							if ( outOfRange(year, 0, 9999) ) return null;
							break;
						case "h": case "hh":
							// Hours (12-hour clock).
							hour = matchInt;
							if ( hour === 12 ) hour = 0;
							if ( outOfRange(hour, 0, 11) ) return null;
							break;
						case "H": case "HH":
							// Hours (24-hour clock).
							hour = matchInt;
							if ( outOfRange(hour, 0, 23) ) return null;
							break;
						case "m": case "mm":
							// Minutes.
							min = matchInt;
							if ( outOfRange(min, 0, 59) ) return null;
							break;
						case "s": case "ss":
							// Seconds.
							sec = matchInt;
							if ( outOfRange(sec, 0, 59) ) return null;
							break;
						case "tt": case "t":
							// AM/PM designator.
							// see if it is standard, upper, or lower case PM. If not, ensure it is at least one of
							// the AM tokens. If not, fail the parse for this format.
							pmHour = cal.PM && ( matchGroup === cal.PM[0] || matchGroup === cal.PM[1] || matchGroup === cal.PM[2] );
							if (
								!pmHour && (
									!cal.AM || ( matchGroup !== cal.AM[0] && matchGroup !== cal.AM[1] && matchGroup !== cal.AM[2] )
								)
							) return null;
							break;
						case "f":
							// Deciseconds.
						case "ff":
							// Centiseconds.
						case "fff":
							// Milliseconds.
							msec = matchInt * Math.pow( 10, 3 - clength );
							if ( outOfRange(msec, 0, 999) ) return null;
							break;
						case "ddd":
							// Day of week.
						case "dddd":
							// Day of week.
							weekDay = getDayIndex( cal, matchGroup, clength === 3 );
							if ( outOfRange(weekDay, 0, 6) ) return null;
							break;
						case "zzz":
							// Time zone offset in +/- hours:min.
							var offsets = matchGroup.split( /:/ );
							if ( offsets.length !== 2 ) return null;
							hourOffset = parseInt( offsets[0], 10 );
							if ( outOfRange(hourOffset, -12, 13) ) return null;
							var minOffset = parseInt( offsets[1], 10 );
							if ( outOfRange(minOffset, 0, 59) ) return null;
							tzMinOffset = ( hourOffset * 60 ) + ( startsWith(matchGroup, "-") ? -minOffset : minOffset );
							break;
						case "z": case "zz":
							// Time zone offset in +/- hours.
							hourOffset = matchInt;
							if ( outOfRange(hourOffset, -12, 13) ) return null;
							tzMinOffset = hourOffset * 60;
							break;
						case "g": case "gg":
							var eraName = matchGroup;
							if ( !eraName || !cal.eras ) return null;
							eraName = trim( eraName.toLowerCase() );
							for ( var i = 0, l = cal.eras.length; i < l; i++ ) {
								if ( eraName === cal.eras[i].name.toLowerCase() ) {
									era = i;
									break;
								}
							}
							// could not find an era with that name
							if ( era === null ) return null;
							break;
					}
				}
			}
			var result = new Date(), defaultYear, convert = cal.convert;
			defaultYear = convert ? convert.fromGregorian( result )[ 0 ] : result.getFullYear();
			if ( year === null ) {
				year = defaultYear;
			}
			else if ( cal.eras ) {
				// year must be shifted to normal gregorian year
				// but not if year was not specified, its already normal gregorian
				// per the main if clause above.
				year += cal.eras[( era || 0 )].offset;
			}
			// set default day and month to 1 and January, so if unspecified, these are the defaults
			// instead of the current day/month.
			if ( month === null ) {
				month = 0;
			}
			if ( date === null ) {
				date = 1;
			}
			// now have year, month, and date, but in the culture's calendar.
			// convert to gregorian if necessary
			if ( convert ) {
				result = convert.toGregorian( year, month, date );
				// conversion failed, must be an invalid match
				if ( result === null ) return null;
			}
			else {
				// have to set year, month and date together to avoid overflow based on current date.
				result.setFullYear( year, month, date );
				// check to see if date overflowed for specified month (only checked 1-31 above).
				if ( result.getDate() !== date ) return null;
				// invalid day of week.
				if ( weekDay !== null && result.getDay() !== weekDay ) {
					return null;
				}
			}
			// if pm designator token was found make sure the hours fit the 24-hour clock.
			if ( pmHour && hour < 12 ) {
				hour += 12;
			}
			result.setHours( hour, min, sec, msec );
			if ( tzMinOffset !== null ) {
				// adjust timezone to utc before applying local offset.
				var adjustedMin = result.getMinutes() - ( tzMinOffset + result.getTimezoneOffset() );
				// Safari limits hours and minutes to the range of -127 to 127.  We need to use setHours
				// to ensure both these fields will not exceed this range.	adjustedMin will range
				// somewhere between -1440 and 1500, so we only need to split this into hours.
				result.setHours( result.getHours() + parseInt(adjustedMin / 60, 10), adjustedMin % 60 );
			}
			return result;
		};
	}());

	parseNegativePattern = function( value, nf, negativePattern ) {
		var neg = nf[ "-" ],
			pos = nf[ "+" ],
			ret;
		switch ( negativePattern ) {
			case "n -":
				neg = " " + neg;
				pos = " " + pos;
				/* falls through */
			case "n-":
				if ( endsWith(value, neg) ) {
					ret = [ "-", value.substr(0, value.length - neg.length) ];
				}
				else if ( endsWith(value, pos) ) {
					ret = [ "+", value.substr(0, value.length - pos.length) ];
				}
				break;
			case "- n":
				neg += " ";
				pos += " ";
				/* falls through */
			case "-n":
				if ( startsWith(value, neg) ) {
					ret = [ "-", value.substr(neg.length) ];
				}
				else if ( startsWith(value, pos) ) {
					ret = [ "+", value.substr(pos.length) ];
				}
				break;
			case "(n)":
				if ( startsWith(value, "(") && endsWith(value, ")") ) {
					ret = [ "-", value.substr(1, value.length - 2) ];
				}
				break;
		}
		return ret || [ "", value ];
	};

	//
	// public instance functions
	//

	Globalize.prototype.findClosestCulture = function( cultureSelector ) {
		return Globalize.findClosestCulture.call( this, cultureSelector );
	};

	Globalize.prototype.format = function( value, format, cultureSelector ) {
		return Globalize.format.call( this, value, format, cultureSelector );
	};

	Globalize.prototype.localize = function( key, cultureSelector ) {
		return Globalize.localize.call( this, key, cultureSelector );
	};

	Globalize.prototype.parseInt = function( value, radix, cultureSelector ) {
		return Globalize.parseInt.call( this, value, radix, cultureSelector );
	};

	Globalize.prototype.parseFloat = function( value, radix, cultureSelector ) {
		return Globalize.parseFloat.call( this, value, radix, cultureSelector );
	};

	Globalize.prototype.culture = function( cultureSelector ) {
		return Globalize.culture.call( this, cultureSelector );
	};

	//
	// public singleton functions
	//

	Globalize.addCultureInfo = function( cultureName, baseCultureName, info ) {

		var base = {},
			isNew = false;

		if ( typeof cultureName !== "string" ) {
			// cultureName argument is optional string. If not specified, assume info is first
			// and only argument. Specified info deep-extends current culture.
			info = cultureName;
			cultureName = this.culture().name;
			base = this.cultures[ cultureName ];
		} else if ( typeof baseCultureName !== "string" ) {
			// baseCultureName argument is optional string. If not specified, assume info is second
			// argument. Specified info deep-extends specified culture.
			// If specified culture does not exist, create by deep-extending default
			info = baseCultureName;
			isNew = ( this.cultures[ cultureName ] == null );
			base = this.cultures[ cultureName ] || this.cultures[ "default" ];
		} else {
			// cultureName and baseCultureName specified. Assume a new culture is being created
			// by deep-extending an specified base culture
			isNew = true;
			base = this.cultures[ baseCultureName ];
		}

		this.cultures[ cultureName ] = extend(true, {},
			base,
			info
		);
		// Make the standard calendar the current culture if it's a new culture
		if ( isNew ) {
			this.cultures[ cultureName ].calendar = this.cultures[ cultureName ].calendars.standard;
		}
	};

	Globalize.findClosestCulture = function( name ) {
		var match;
		if ( !name ) {
			return this.findClosestCulture( this.cultureSelector ) || this.cultures[ "default" ];
		}
		if ( typeof name === "string" ) {
			name = name.split( "," );
		}
		if ( isArray(name) ) {
			var lang,
				cultures = this.cultures,
				list = name,
				i, l = list.length,
				prioritized = [];
			for ( i = 0; i < l; i++ ) {
				name = trim( list[i] );
				var pri, parts = name.split( ";" );
				lang = trim( parts[0] );
				if ( parts.length === 1 ) {
					pri = 1;
				}
				else {
					name = trim( parts[1] );
					if ( name.indexOf("q=") === 0 ) {
						name = name.substr( 2 );
						pri = parseFloat( name );
						pri = isNaN( pri ) ? 0 : pri;
					}
					else {
						pri = 1;
					}
				}
				prioritized.push({ lang: lang, pri: pri });
			}
			prioritized.sort(function( a, b ) {
				if ( a.pri < b.pri ) {
					return 1;
				} else if ( a.pri > b.pri ) {
					return -1;
				}
				return 0;
			});
			// exact match
			for ( i = 0; i < l; i++ ) {
				lang = prioritized[ i ].lang;
				match = cultures[ lang ];
				if ( match ) {
					return match;
				}
			}

			// neutral language match
			for ( i = 0; i < l; i++ ) {
				lang = prioritized[ i ].lang;
				do {
					var index = lang.lastIndexOf( "-" );
					if ( index === -1 ) {
						break;
					}
					// strip off the last part. e.g. en-US => en
					lang = lang.substr( 0, index );
					match = cultures[ lang ];
					if ( match ) {
						return match;
					}
				}
				while ( 1 );
			}

			// last resort: match first culture using that language
			for ( i = 0; i < l; i++ ) {
				lang = prioritized[ i ].lang;
				for ( var cultureKey in cultures ) {
					var culture = cultures[ cultureKey ];
					if ( culture.language == lang ) {
						return culture;
					}
				}
			}
		}
		else if ( typeof name === "object" ) {
			return name;
		}
		return match || null;
	};

	Globalize.format = function( value, format, cultureSelector ) {
		var culture = this.findClosestCulture( cultureSelector );
		if ( value instanceof Date ) {
			value = formatDate( value, format, culture );
		}
		else if ( typeof value === "number" ) {
			value = formatNumber( value, format, culture );
		}
		return value;
	};

	Globalize.localize = function( key, cultureSelector ) {
		return this.findClosestCulture( cultureSelector ).messages[ key ] ||
			this.cultures[ "default" ].messages[ key ];
	};

	Globalize.parseDate = function( value, formats, culture ) {
		culture = this.findClosestCulture( culture );

		var date, prop, patterns;
		if ( formats ) {
			if ( typeof formats === "string" ) {
				formats = [ formats ];
			}
			if ( formats.length ) {
				for ( var i = 0, l = formats.length; i < l; i++ ) {
					var format = formats[ i ];
					if ( format ) {
						date = parseExact( value, format, culture );
						if ( date ) {
							break;
						}
					}
				}
			}
		} else {
			patterns = culture.calendar.patterns;
			for ( prop in patterns ) {
				date = parseExact( value, patterns[prop], culture );
				if ( date ) {
					break;
				}
			}
		}

		return date || null;
	};

	Globalize.parseInt = function( value, radix, cultureSelector ) {
		return truncate( Globalize.parseFloat(value, radix, cultureSelector) );
	};

	Globalize.parseFloat = function( value, radix, cultureSelector ) {
		// radix argument is optional
		if ( typeof radix !== "number" ) {
			cultureSelector = radix;
			radix = 10;
		}

		var culture = this.findClosestCulture( cultureSelector );
		var ret = NaN,
			nf = culture.numberFormat;

		if ( value.indexOf(culture.numberFormat.currency.symbol) > -1 ) {
			// remove currency symbol
			value = value.replace( culture.numberFormat.currency.symbol, "" );
			// replace decimal seperator
			value = value.replace( culture.numberFormat.currency["."], culture.numberFormat["."] );
		}

		//Remove percentage character from number string before parsing
		if ( value.indexOf(culture.numberFormat.percent.symbol) > -1){
			value = value.replace( culture.numberFormat.percent.symbol, "" );
		}

		// remove spaces: leading, trailing and between - and number. Used for negative currency pt-BR
		value = value.replace( / /g, "" );

		// allow infinity or hexidecimal
		if ( regexInfinity.test(value) ) {
			ret = parseFloat( value );
		}
		else if ( !radix && regexHex.test(value) ) {
			ret = parseInt( value, 16 );
		}
		else {

			// determine sign and number
			var signInfo = parseNegativePattern( value, nf, nf.pattern[0] ),
				sign = signInfo[ 0 ],
				num = signInfo[ 1 ];

			// #44 - try parsing as "(n)"
			if ( sign === "" && nf.pattern[0] !== "(n)" ) {
				signInfo = parseNegativePattern( value, nf, "(n)" );
				sign = signInfo[ 0 ];
				num = signInfo[ 1 ];
			}

			// try parsing as "-n"
			if ( sign === "" && nf.pattern[0] !== "-n" ) {
				signInfo = parseNegativePattern( value, nf, "-n" );
				sign = signInfo[ 0 ];
				num = signInfo[ 1 ];
			}

			sign = sign || "+";

			// determine exponent and number
			var exponent,
				intAndFraction,
				exponentPos = num.indexOf( "e" );
			if ( exponentPos < 0 ) exponentPos = num.indexOf( "E" );
			if ( exponentPos < 0 ) {
				intAndFraction = num;
				exponent = null;
			}
			else {
				intAndFraction = num.substr( 0, exponentPos );
				exponent = num.substr( exponentPos + 1 );
			}
			// determine decimal position
			var integer,
				fraction,
				decSep = nf[ "." ],
				decimalPos = intAndFraction.indexOf( decSep );
			if ( decimalPos < 0 ) {
				integer = intAndFraction;
				fraction = null;
			}
			else {
				integer = intAndFraction.substr( 0, decimalPos );
				fraction = intAndFraction.substr( decimalPos + decSep.length );
			}
			// handle groups (e.g. 1,000,000)
			var groupSep = nf[ "," ];
			integer = integer.split( groupSep ).join( "" );
			var altGroupSep = groupSep.replace( /\u00A0/g, " " );
			if ( groupSep !== altGroupSep ) {
				integer = integer.split( altGroupSep ).join( "" );
			}
			// build a natively parsable number string
			var p = sign + integer;
			if ( fraction !== null ) {
				p += "." + fraction;
			}
			if ( exponent !== null ) {
				// exponent itself may have a number patternd
				var expSignInfo = parseNegativePattern( exponent, nf, "-n" );
				p += "e" + ( expSignInfo[0] || "+" ) + expSignInfo[ 1 ];
			}
			if ( regexParseFloat.test(p) ) {
				ret = parseFloat( p );
			}
		}
		return ret;
	};

	Globalize.culture = function( cultureSelector ) {
		// setter
		if ( typeof cultureSelector !== "undefined" ) {
			this.cultureSelector = cultureSelector;
		}
		// getter
		return this.findClosestCulture( cultureSelector ) || this.cultures[ "default" ];
	};

	}( this ));


/***/ },

/***/ 1419:
/***/ function(module, exports, __webpack_require__) {

	'use strict';
	var hyphenate = __webpack_require__(1420),
	    css = __webpack_require__(1421),
	    on = __webpack_require__(1427),
	    off = __webpack_require__(1428),
	    transitionProps = __webpack_require__(1429);

	var has = Object.prototype.hasOwnProperty,
	    reset = {},
	    TRANSLATION_MAP = {
	  left: 'translateX',
	  right: 'translateX',
	  top: 'translateY',
	  bottom: 'translateY'
	};

	reset[transitionProps.property] = reset[transitionProps.duration] = reset[transitionProps.delay] = reset[transitionProps.timing] = '';

	animate.endEvent = transitionProps.end;
	animate.transform = transitionProps.transform;
	animate.TRANSLATION_MAP = TRANSLATION_MAP;

	module.exports = animate;

	// super lean animate function for transitions
	// doesn't support all translations to keep it matching the jquery API
	/**
	 * code in part from: Zepto 1.1.4 | zeptojs.com/license
	 */
	function animate(node, properties, duration, easing, callback) {
	  var cssProperties = [],
	      fakeEvent = { target: node, currentTarget: node },
	      cssValues = {},
	      transforms = '',
	      fired;

	  if (typeof easing === 'function') callback = easing, easing = null;

	  if (!transitionProps.end) duration = 0;
	  if (duration === undefined) duration = 200;

	  for (var key in properties) if (has.call(properties, key)) {
	    if (/(top|bottom)/.test(key)) transforms += TRANSLATION_MAP[key] + '(' + properties[key] + ') ';else {
	      cssValues[key] = properties[key];
	      cssProperties.push(hyphenate(key));
	    }
	  }

	  if (transforms) {
	    cssValues[transitionProps.transform] = transforms;
	    cssProperties.push(transitionProps.transform);
	  }

	  if (duration > 0) {
	    cssValues[transitionProps.property] = cssProperties.join(', ');
	    cssValues[transitionProps.duration] = duration / 1000 + 's';
	    cssValues[transitionProps.delay] = 0 + 's';
	    cssValues[transitionProps.timing] = easing || 'linear';

	    on(node, transitionProps.end, done);

	    setTimeout(function () {
	      if (!fired) done(fakeEvent);
	    }, duration + 500);
	  }

	  node.clientLeft; // trigger page reflow
	  css(node, cssValues);

	  if (duration <= 0) setTimeout(done.bind(null, fakeEvent), 0);

	  function done(event) {
	    if (event.target !== event.currentTarget) return;

	    fired = true;
	    off(event.target, transitionProps.end, done);
	    css(node, reset);
	    callback && callback.call(this);
	  }
	}

/***/ },

/***/ 1420:
/***/ function(module, exports) {

	'use strict';

	var rUpper = /([A-Z])/g;

	module.exports = function hyphenate(string) {
	  return string.replace(rUpper, '-$1').toLowerCase();
	};

/***/ },

/***/ 1421:
/***/ function(module, exports, __webpack_require__) {

	'use strict';

	var camelize = __webpack_require__(1422),
	    hyphenate = __webpack_require__(1424),
	    _getComputedStyle = __webpack_require__(1425),
	    removeStyle = __webpack_require__(1426);

	var has = Object.prototype.hasOwnProperty;

	module.exports = function style(node, property, value) {
	  var css = '',
	      props = property;

	  if (typeof property === 'string') {
	    if (value === undefined) return node.style[camelize(property)] || _getComputedStyle(node).getPropertyValue(property);else (props = {})[property] = value;
	  }

	  for (var key in props) if (has.call(props, key)) {
	    !props[key] && props[key] !== 0 ? removeStyle(node, hyphenate(key)) : css += hyphenate(key) + ':' + props[key] + ';';
	  }

	  node.style.cssText += ';' + css;
	};

/***/ },

/***/ 1422:
/***/ function(module, exports, __webpack_require__) {

	/**
	 * Copyright 2014-2015, Facebook, Inc.
	 * All rights reserved.
	 * https://github.com/facebook/react/blob/2aeb8a2a6beb00617a4217f7f8284924fa2ad819/src/vendor/core/camelizeStyleName.js
	 */

	'use strict';
	var camelize = __webpack_require__(1423);
	var msPattern = /^-ms-/;

	module.exports = function camelizeStyleName(string) {
	  return camelize(string.replace(msPattern, 'ms-'));
	};

/***/ },

/***/ 1423:
/***/ function(module, exports) {

	"use strict";

	var rHyphen = /-(.)/g;

	module.exports = function camelize(string) {
	  return string.replace(rHyphen, function (_, chr) {
	    return chr.toUpperCase();
	  });
	};

/***/ },

/***/ 1424:
/***/ function(module, exports, __webpack_require__) {

	/**
	 * Copyright 2013-2014, Facebook, Inc.
	 * All rights reserved.
	 * https://github.com/facebook/react/blob/2aeb8a2a6beb00617a4217f7f8284924fa2ad819/src/vendor/core/hyphenateStyleName.js
	 */

	"use strict";

	var hyphenate = __webpack_require__(1420);
	var msPattern = /^ms-/;

	module.exports = function hyphenateStyleName(string) {
	  return hyphenate(string).replace(msPattern, "-ms-");
	};

/***/ },

/***/ 1425:
/***/ function(module, exports) {

	"use strict";

	module.exports = function _getComputedStyle(node) {
	  if (!node) throw new TypeError("No Element passed to `getComputedStyle()`");
	  var doc = node.ownerDocument;

	  return "defaultView" in doc ? doc.defaultView.opener ? node.ownerDocument.defaultView.getComputedStyle(node, null) : window.getComputedStyle(node, null) : { //ie 8 "magic"
	    getPropertyValue: function getPropertyValue(prop) {
	      var re = /(\-([a-z]){1})/g;
	      if (prop == "float") prop = "styleFloat";
	      if (re.test(prop)) prop = prop.replace(re, function () {
	        return arguments[2].toUpperCase();
	      });

	      return node.currentStyle[prop] || null;
	    }
	  };
	};

/***/ },

/***/ 1426:
/***/ function(module, exports) {

	'use strict';

	module.exports = function removeStyle(node, key) {
	  return 'removeProperty' in node.style ? node.style.removeProperty(key) : node.style.removeAttribute(key);
	};

/***/ },

/***/ 1427:
/***/ function(module, exports, __webpack_require__) {

	'use strict';
	var canUseDOM = __webpack_require__(1410);
	var on = function on() {};

	if (canUseDOM) {
	  on = (function () {

	    if (document.addEventListener) return function (node, eventName, handler, capture) {
	      return node.addEventListener(eventName, handler, capture || false);
	    };else if (document.attachEvent) return function (node, eventName, handler) {
	      return node.attachEvent('on' + eventName, handler);
	    };
	  })();
	}

	module.exports = on;

/***/ },

/***/ 1428:
/***/ function(module, exports, __webpack_require__) {

	'use strict';
	var canUseDOM = __webpack_require__(1410);
	var off = function off() {};

	if (canUseDOM) {

	  off = (function () {

	    if (document.addEventListener) return function (node, eventName, handler, capture) {
	      return node.removeEventListener(eventName, handler, capture || false);
	    };else if (document.attachEvent) return function (node, eventName, handler) {
	      return node.detachEvent('on' + eventName, handler);
	    };
	  })();
	}

	module.exports = off;

/***/ },

/***/ 1429:
/***/ function(module, exports, __webpack_require__) {

	'use strict';
	var canUseDOM = __webpack_require__(1410);

	var has = Object.prototype.hasOwnProperty,
	    transform = 'transform',
	    transition = {},
	    transitionTiming,
	    transitionDuration,
	    transitionProperty,
	    transitionDelay;

	if (canUseDOM) {
	  transition = getTransitionProperties();

	  transform = transition.prefix + transform;

	  transitionProperty = transition.prefix + 'transition-property';
	  transitionDuration = transition.prefix + 'transition-duration';
	  transitionDelay = transition.prefix + 'transition-delay';
	  transitionTiming = transition.prefix + 'transition-timing-function';
	}

	module.exports = {
	  transform: transform,
	  end: transition.end,
	  property: transitionProperty,
	  timing: transitionTiming,
	  delay: transitionDelay,
	  duration: transitionDuration
	};

	function getTransitionProperties() {
	  var endEvent,
	      prefix = '',
	      transitions = {
	    O: 'otransitionend',
	    Moz: 'transitionend',
	    Webkit: 'webkitTransitionEnd',
	    ms: 'MSTransitionEnd'
	  };

	  var element = document.createElement('div');

	  for (var vendor in transitions) if (has.call(transitions, vendor)) {
	    if (element.style[vendor + 'TransitionProperty'] !== undefined) {
	      prefix = '-' + vendor.toLowerCase() + '-';
	      endEvent = transitions[vendor];
	      break;
	    }
	  }

	  if (!endEvent && element.style.transitionProperty !== undefined) endEvent = 'transitionend';

	  return { end: endEvent, prefix: prefix };
	}

/***/ },

/***/ 1430:
/***/ function(module, exports) {

	'use strict';
	var common = {
	  eq: function eq(a, b) {
	    return a === b;
	  },
	  neq: function neq(a, b) {
	    return a !== b;
	  },
	  gt: function gt(a, b) {
	    return a > b;
	  },
	  gte: function gte(a, b) {
	    return a >= b;
	  },
	  lt: function lt(a, b) {
	    return a < b;
	  },
	  lte: function lte(a, b) {
	    return a <= b;
	  },

	  contains: function contains(a, b) {
	    return a.indexOf(b) !== -1;
	  },

	  startsWith: function startsWith(a, b) {
	    return a.lastIndexOf(b, 0) === 0;
	  },

	  endsWith: function endsWith(a, b) {
	    var pos = a.length - b.length,
	        lastIndex = a.indexOf(b, pos);

	    return lastIndex !== -1 && lastIndex === pos;
	  }
	};

	module.exports = common;

/***/ },

/***/ 1431:
/***/ function(module, exports, __webpack_require__) {

	'use strict';

	var babelHelpers = __webpack_require__(1407);

	var React = __webpack_require__(103),
	    css = __webpack_require__(1421),
	    getHeight = __webpack_require__(1432),
	    config = __webpack_require__(1414),
	    cn = __webpack_require__(1411),
	    compat = __webpack_require__(1412);

	var transform = config.animate.transform;

	function properties(prop, value) {
	  var _ref, _ref2;

	  var TRANSLATION_MAP = config.animate.TRANSLATION_MAP;

	  if (TRANSLATION_MAP && TRANSLATION_MAP[prop]) return (_ref = {}, _ref[transform] = '' + TRANSLATION_MAP[prop] + '(' + value + ')', _ref);

	  return (_ref2 = {}, _ref2[prop] = value, _ref2);
	}

	var PopupContent = React.createClass({
	  displayName: 'PopupContent',

	  render: function render() {
	    var child = this.props.children;

	    if (!child) return React.createElement('span', { className: 'rw-popup rw-widget' });

	    child = React.Children.only(this.props.children);

	    return compat.cloneElement(child, {
	      className: cn(child.props.className, 'rw-popup rw-widget')
	    });
	  }
	});

	module.exports = React.createClass({

	  displayName: 'Popup',

	  propTypes: {
	    open: React.PropTypes.bool,
	    dropUp: React.PropTypes.bool,
	    duration: React.PropTypes.number,

	    onRequestClose: React.PropTypes.func.isRequired,
	    onClosing: React.PropTypes.func,
	    onOpening: React.PropTypes.func,
	    onClose: React.PropTypes.func,
	    onOpen: React.PropTypes.func
	  },

	  getInitialState: function getInitialState() {
	    return {};
	  },

	  getDefaultProps: function getDefaultProps() {
	    return {
	      duration: 200,
	      open: false,
	      onClosing: function onClosing() {},
	      onOpening: function onOpening() {},
	      onClose: function onClose() {},
	      onOpen: function onOpen() {}
	    };
	  },

	  // componentDidMount(){
	  //   !this.props.open && this.close(0)
	  // },
	  componentWillMount: function componentWillMount() {
	    !this.props.open && (this._initialPosition = true);
	  },

	  componentWillReceiveProps: function componentWillReceiveProps(nextProps) {
	    this.setState({
	      contentChanged: childKey(nextProps.children) !== childKey(this.props.children)
	    });
	  },

	  componentDidUpdate: function componentDidUpdate(pvProps) {
	    var closing = pvProps.open && !this.props.open,
	        opening = !pvProps.open && this.props.open,
	        open = this.props.open;

	    if (opening) this.open();else if (closing) this.close();else if (open) this.height();
	  },

	  render: function render() {
	    var _props = this.props;
	    var className = _props.className;
	    var open = _props.open;
	    var dropUp = _props.dropUp;
	    var props = babelHelpers.objectWithoutProperties(_props, ['className', 'open', 'dropUp']);
	    var display = open ? 'block' : void 0;

	    if (this._initialPosition) {
	      display = 'none';
	    }

	    return React.createElement(
	      'div',
	      babelHelpers._extends({}, props, {
	        style: babelHelpers._extends({
	          display: display,
	          height: this.state.height }, props.style),
	        className: cn(className, 'rw-popup-container', { 'rw-dropup': dropUp })
	      }),
	      React.createElement(
	        PopupContent,
	        { ref: 'content' },
	        this.props.children
	      )
	    );
	  },

	  reset: function reset() {
	    var container = compat.findDOMNode(this),
	        content = compat.findDOMNode(this.refs.content),
	        style = { display: 'block', overflow: 'hidden' };

	    css(container, style);
	    this.height();
	    css(content, properties('top', this.props.dropUp ? '100%' : '-100%'));
	  },

	  height: function height() {
	    var el = compat.findDOMNode(this),
	        content = compat.findDOMNode(this.refs.content),
	        margin = parseInt(css(content, 'margin-top'), 10) + parseInt(css(content, 'margin-bottom'), 10);

	    var height = getHeight(content) + (isNaN(margin) ? 0 : margin);

	    if (this.state.height !== height) {
	      el.style.height = height + 'px';
	      this.setState({ height: height });
	    }
	  },

	  open: function open() {
	    var self = this,
	        anim = compat.findDOMNode(this),
	        el = compat.findDOMNode(this.refs.content);

	    this.ORGINAL_POSITION = css(el, 'position');
	    this._isOpening = true;

	    if (this._initialPosition) {
	      this._initialPosition = false;
	      this.reset();
	    } else this.height();

	    this.props.onOpening();

	    anim.className += ' rw-popup-animating';
	    el.style.position = 'absolute';

	    config.animate(el, { top: 0 }, self.props.duration, 'ease', function () {
	      if (!self._isOpening) return;

	      anim.className = anim.className.replace(/ ?rw-popup-animating/g, '');

	      el.style.position = self.ORGINAL_POSITION;
	      anim.style.overflow = 'visible';
	      self.ORGINAL_POSITION = null;

	      self.props.onOpen();
	    });
	  },

	  close: function close(dur) {
	    var self = this,
	        el = compat.findDOMNode(this.refs.content),
	        anim = compat.findDOMNode(this);

	    this.ORGINAL_POSITION = css(el, 'position');

	    this._isOpening = false;
	    this.height();
	    this.props.onClosing();

	    anim.style.overflow = 'hidden';
	    anim.className += ' rw-popup-animating';
	    el.style.position = 'absolute';

	    config.animate(el, { top: this.props.dropUp ? '100%' : '-100%' }, dur === undefined ? this.props.duration : dur, 'ease', function () {
	      if (self._isOpening) return;

	      el.style.position = self.ORGINAL_POSITION;
	      anim.className = anim.className.replace(/ ?rw-popup-animating/g, '');

	      anim.style.display = 'none';
	      self.ORGINAL_POSITION = null;
	      self.props.onClose();
	    });
	  }

	});

	function childKey(children) {
	  var nextChildMapping = React.Children.map(children, function (c) {
	    return c;
	  });
	  for (var key in nextChildMapping) return key;
	}

/***/ },

/***/ 1432:
/***/ function(module, exports, __webpack_require__) {

	'use strict';

	var offset = __webpack_require__(1433),
	    getWindow = __webpack_require__(1434);

	module.exports = function height(node, client) {
	  var win = getWindow(node);
	  return win ? win.innerHeight : client ? node.clientHeight : offset(node).height;
	};

/***/ },

/***/ 1433:
/***/ function(module, exports, __webpack_require__) {

	'use strict';
	var contains = __webpack_require__(1409),
	    getWindow = __webpack_require__(1434);

	module.exports = function offset(node) {
	  var doc = node.ownerDocument,
	      docElem = doc && doc.documentElement,
	      box = { top: 0, left: 0, height: 0, width: 0 };

	  if (!doc) return;

	  if (!contains(docElem, node)) return box;

	  if (node.getBoundingClientRect !== undefined) box = node.getBoundingClientRect();

	  var win = getWindow(doc);

	  return {
	    top: box.top + (win.pageYOffset || docElem.scrollTop) - (docElem.clientTop || 0),
	    left: box.left + (win.pageXOffset || docElem.scrollLeft) - (docElem.clientLeft || 0),
	    width: box.width || node.offsetWidth,
	    height: box.height || node.offsetHeight
	  };
	};

/***/ },

/***/ 1434:
/***/ function(module, exports) {

	'use strict';

	module.exports = function getWindow(node) {
	  return node === node.window ? node : node.nodeType === 9 ? node.defaultView || node.parentWindow : false;
	};

/***/ },

/***/ 1435:
/***/ function(module, exports, __webpack_require__) {

	'use strict';

	var babelHelpers = __webpack_require__(1407);

	exports.__esModule = true;

	var _react = __webpack_require__(103);

	var _react2 = babelHelpers.interopRequireDefault(_react);

	var _ListOption = __webpack_require__(1436);

	var _ListOption2 = babelHelpers.interopRequireDefault(_ListOption);

	var _utilPropTypes = __webpack_require__(1413);

	var _utilPropTypes2 = babelHelpers.interopRequireDefault(_utilPropTypes);

	var _utilCompat = __webpack_require__(1412);

	var _utilCompat2 = babelHelpers.interopRequireDefault(_utilCompat);

	var _classnames = __webpack_require__(1411);

	var _classnames2 = babelHelpers.interopRequireDefault(_classnames);

	var _util_ = __webpack_require__(1408);

	var _util_2 = babelHelpers.interopRequireDefault(_util_);

	var optionId = function optionId(id, idx) {
	  return '' + id + '__option__' + idx;
	};

	exports['default'] = _react2['default'].createClass({

	  displayName: 'List',

	  mixins: [__webpack_require__(1437), __webpack_require__(1438), __webpack_require__(1439), __webpack_require__(1440)()],

	  propTypes: {
	    data: _react2['default'].PropTypes.array,
	    onSelect: _react2['default'].PropTypes.func,
	    onMove: _react2['default'].PropTypes.func,

	    optionComponent: _utilPropTypes2['default'].elementType,
	    itemComponent: _utilPropTypes2['default'].elementType,

	    selectedIndex: _react2['default'].PropTypes.number,
	    focusedIndex: _react2['default'].PropTypes.number,
	    valueField: _react2['default'].PropTypes.string,
	    textField: _utilPropTypes2['default'].accessor,

	    optionID: _react2['default'].PropTypes.func,

	    messages: _react2['default'].PropTypes.shape({
	      emptyList: _utilPropTypes2['default'].message
	    })
	  },

	  getDefaultProps: function getDefaultProps() {
	    return {
	      optID: '',
	      onSelect: function onSelect() {},
	      optionComponent: _ListOption2['default'],
	      ariaActiveDescendantKey: 'list',
	      data: [],
	      messages: {
	        emptyList: 'There are no items in this list'
	      }
	    };
	  },

	  componentDidMount: function componentDidMount() {
	    this.move();
	  },

	  componentDidUpdate: function componentDidUpdate() {
	    var _props = this.props;
	    var data = _props.data;
	    var focused = _props.focused;
	    var idx = data.indexOf(focused);
	    var activeId = optionId(this._id(), idx);

	    this.ariaActiveDescendant(idx !== -1 ? activeId : null);

	    this.move();
	  },

	  render: function render() {
	    var _this = this;

	    var _props2 = this.props;
	    var className = _props2.className;
	    var role = _props2.role;
	    var data = _props2.data;
	    var focused = _props2.focused;
	    var selected = _props2.selected;
	    var messages = _props2.messages;
	    var onSelect = _props2.onSelect;
	    var ItemComponent = _props2.itemComponent;
	    var Option = _props2.optionComponent;
	    var optionID = _props2.optionID;
	    var props = babelHelpers.objectWithoutProperties(_props2, ['className', 'role', 'data', 'focused', 'selected', 'messages', 'onSelect', 'itemComponent', 'optionComponent', 'optionID']);
	    var id = this._id();
	    var items;

	    items = !data.length ? _react2['default'].createElement(
	      'li',
	      { className: 'rw-list-empty' },
	      _util_2['default'].result(messages.emptyList, this.props)
	    ) : data.map(function (item, idx) {
	      var currentId = optionId(id, idx);

	      // if (focused === item)
	      //   this._activeID = currentId;

	      return _react2['default'].createElement(
	        Option,
	        {
	          key: 'item_' + idx,
	          id: currentId,
	          dataItem: item,
	          focused: focused === item,
	          selected: selected === item,
	          onClick: onSelect.bind(null, item)
	        },
	        ItemComponent ? _react2['default'].createElement(ItemComponent, { item: item, value: _this._dataValue(item), text: _this._dataText(item) }) : _this._dataText(item)
	      );
	    });

	    return _react2['default'].createElement(
	      'ul',
	      babelHelpers._extends({
	        id: id,
	        tabIndex: '-1',
	        className: (0, _classnames2['default'])(className, 'rw-list'),
	        role: role === undefined ? 'listbox' : role
	      }, props),
	      items
	    );
	  },

	  _data: function _data() {
	    return this.props.data;
	  },

	  move: function move() {
	    var list = _utilCompat2['default'].findDOMNode(this),
	        idx = this._data().indexOf(this.props.focused),
	        selected = list.children[idx];

	    if (!selected) return;

	    this.notify('onMove', [selected, list, this.props.focused]);
	  }

	});
	module.exports = exports['default'];

/***/ },

/***/ 1436:
/***/ function(module, exports, __webpack_require__) {

	'use strict';

	var babelHelpers = __webpack_require__(1407);

	exports.__esModule = true;

	var _react = __webpack_require__(103);

	var _react2 = babelHelpers.interopRequireDefault(_react);

	var _classnames = __webpack_require__(1411);

	var _classnames2 = babelHelpers.interopRequireDefault(_classnames);

	var ListOption = _react2['default'].createClass({
	  displayName: 'ListOption',

	  propTypes: {
	    dataItem: _react2['default'].PropTypes.any,
	    focused: _react2['default'].PropTypes.bool,
	    selected: _react2['default'].PropTypes.bool
	  },

	  render: function render() {
	    var _props = this.props;
	    var className = _props.className;
	    var children = _props.children;
	    var focused = _props.focused;
	    var selected = _props.selected;
	    var props = babelHelpers.objectWithoutProperties(_props, ['className', 'children', 'focused', 'selected']);

	    var classes = {
	      'rw-state-focus': focused,
	      'rw-state-selected': selected
	    };

	    return _react2['default'].createElement(
	      'li',
	      babelHelpers._extends({
	        role: 'option',
	        tabIndex: '-1',
	        'aria-selected': !!selected,
	        className: (0, _classnames2['default'])('rw-list-option', className, classes)
	      }, props),
	      children
	    );
	  }
	});

	exports['default'] = ListOption;
	module.exports = exports['default'];

/***/ },

/***/ 1437:
/***/ function(module, exports, __webpack_require__) {

	'use strict';
	var React = __webpack_require__(103),
	    _ = __webpack_require__(1408); //uniqueID

	module.exports = {

	  propTypes: {

	    disabled: React.PropTypes.oneOfType([React.PropTypes.bool, React.PropTypes.oneOf(['disabled'])]),

	    readOnly: React.PropTypes.oneOfType([React.PropTypes.bool, React.PropTypes.oneOf(['readOnly'])])
	  },

	  isDisabled: function isDisabled() {
	    return this.props.disabled === true || this.props.disabled === 'disabled';
	  },

	  isReadOnly: function isReadOnly() {
	    return this.props.readOnly === true || this.props.readOnly === 'readonly';
	  },

	  notify: function notify(handler, args) {
	    this.props[handler] && this.props[handler].apply(null, [].concat(args));
	  },

	  _id: function _id() {
	    var suffix = arguments[0] === undefined ? '' : arguments[0];

	    this._id_ || (this._id_ = _.uniqueId('rw_'));
	    return (this.props.id || this._id_) + suffix;
	  },

	  _maybeHandle: function _maybeHandle(handler, disabledOnly) {
	    if (!(this.isDisabled() || !disabledOnly && this.isReadOnly())) return handler;
	    return function () {};
	  }
	};

/***/ },

/***/ 1438:
/***/ function(module, exports, __webpack_require__) {

	'use strict';
	var React = __webpack_require__(103);
	var propTypes = __webpack_require__(1413);

	var _require = __webpack_require__(1408);

	var has = _require.has;
	var isShallowEqual = _require.isShallowEqual;

	function accessor(data, field) {
	  var value = data;

	  if (typeof field === 'function') value = field(data);else if (data == null) value = data;else if (typeof field === 'string' && typeof data === 'object' && field in data) value = data[field];

	  return value;
	}

	module.exports = {

	  propTypes: {
	    valueField: React.PropTypes.string,
	    textField: propTypes.accessor
	  },

	  _dataValue: function _dataValue(item) {
	    var field = this.props.valueField;

	    return field && item && has(item, field) ? item[field] : item;
	  },

	  _dataText: function _dataText(item) {
	    var field = this.props.textField,
	        value = accessor(item, field);

	    return value == null ? '' : value + '';
	  },

	  _dataIndexOf: function _dataIndexOf(data, item) {
	    var _this = this;

	    var idx = -1,
	        len = data.length,
	        finder = function finder(datum) {
	      return _this._valueMatcher(item, datum);
	    };

	    while (++idx < len) if (finder(data[idx])) return idx;

	    return -1;
	  },

	  _valueMatcher: function _valueMatcher(a, b) {
	    return isShallowEqual(this._dataValue(a), this._dataValue(b));
	  },

	  _dataItem: function _dataItem(data, item) {
	    var first = data[0],
	        field = this.props.valueField,
	        idx;

	    // make an attempt to see if we were passed in dataItem vs just a valueField value
	    // either an object with the right prop, or a primitive
	    // { valueField: 5 } || "hello" [ "hello" ]
	    if (has(item, field) || typeof first === typeof val) return item;

	    idx = this._dataIndexOf(data, this._dataValue(item));

	    if (idx !== -1) return data[idx];

	    return item;
	  }
	};

/***/ },

/***/ 1439:
/***/ function(module, exports, __webpack_require__) {

	'use strict';
	var React = __webpack_require__(103),
	    filter = __webpack_require__(1430),
	    helper = __webpack_require__(1438);

	module.exports = {

	  propTypes: {
	    textField: React.PropTypes.string
	  },

	  first: function first() {
	    return this._data()[0];
	  },

	  last: function last() {
	    var data = this._data();
	    return data[data.length - 1];
	  },

	  prev: function prev(item, word) {
	    var data = this._data(),
	        idx = data.indexOf(item);

	    if (idx === -1) idx = data.length;

	    return word ? findPrevInstance(this, data, word, idx) : --idx < 0 ? data[0] : data[idx];
	  },

	  next: function next(item, word) {
	    var data = this._data(),
	        idx = data.indexOf(item);

	    return word ? findNextInstance(this, data, word, idx) : ++idx === data.length ? data[data.length - 1] : data[idx];
	  }

	};

	function findNextInstance(ctx, data, word, startIndex) {
	  var matches = filter.startsWith,
	      idx = -1,
	      len = data.length,
	      foundStart,
	      itemText;

	  word = word.toLowerCase();

	  while (++idx < len) {
	    foundStart = foundStart || idx > startIndex;
	    itemText = foundStart && helper._dataText.call(ctx, data[idx]).toLowerCase();

	    if (foundStart && matches(itemText, word)) return data[idx];
	  }
	}

	function findPrevInstance(ctx, data, word, startIndex) {
	  var matches = filter.startsWith,
	      idx = data.length,
	      foundStart,
	      itemText;

	  word = word.toLowerCase();

	  while (--idx >= 0) {
	    foundStart = foundStart || idx < startIndex;
	    itemText = foundStart && helper._dataText.call(ctx, data[idx]).toLowerCase();

	    if (foundStart && matches(itemText, word)) return data[idx];
	  }
	}

/***/ },

/***/ 1440:
/***/ function(module, exports, __webpack_require__) {

	'use strict';

	var babelHelpers = __webpack_require__(1407);

	exports.__esModule = true;

	var _react = __webpack_require__(103);

	var _react2 = babelHelpers.interopRequireDefault(_react);

	var shape = _react2['default'].PropTypes.shape({
	  //setActive: React.PropTypes.func,
	  reconcile: _react2['default'].PropTypes.func
	});

	function defaultReconcile(key, id) {
	  return id;
	}

	function flushAriaToNode(id, nodeOrComponent, ctx) {
	  var node = typeof nodeOrComponent === 'function' ? nodeOrComponent(ctx) : typeof nodeOrComponent === 'string' ? ctx.refs[nodeOrComponent] : ctx;

	  if (node) {
	    //console.log('flushing!', node.constructor.displayName)
	    if (id) _react2['default'].findDOMNode(node).setAttribute('aria-activedescendant', id);else _react2['default'].findDOMNode(node).removeAttribute('aria-activedescendant');
	  }
	}

	exports['default'] = function (nodeOrComponent) {
	  var reconcileChildren = arguments[1] === undefined ? defaultReconcile : arguments[1];

	  return {
	    propTypes: {
	      ariaActiveDescendantKey: _react2['default'].PropTypes.string.isRequired
	    },

	    contextTypes: {
	      activeDescendants: shape
	    },

	    childContextTypes: {
	      activeDescendants: shape
	    },

	    ariaActiveDescendant: function ariaActiveDescendant(id) {
	      var key = arguments[1] === undefined ? this.props.ariaActiveDescendantKey : arguments[1];
	      var activeDescendants = this.context.activeDescendants;

	      var current = this.__ariaActiveDescendantId;

	      if (id === undefined) return current;

	      id = reconcileChildren.call(this, key, id);

	      if (id === undefined) id = current;else {
	        this.__ariaActiveDescendantId = id;
	        flushAriaToNode(id, nodeOrComponent, this);
	      }

	      activeDescendants && activeDescendants.reconcile(key, id);
	    },

	    getChildContext: function getChildContext() {
	      var _this = this;

	      return this._context || (this._context = {
	        activeDescendants: {
	          reconcile: function reconcile(key, id) {
	            return _this.ariaActiveDescendant(id, key);
	          }
	        }
	      });
	    }
	  };
	};

	module.exports = exports['default'];

/***/ },

/***/ 1441:
/***/ function(module, exports, __webpack_require__) {

	'use strict';

	var babelHelpers = __webpack_require__(1407);

	exports.__esModule = true;

	var _react = __webpack_require__(103);

	var _react2 = babelHelpers.interopRequireDefault(_react);

	var _ListOption = __webpack_require__(1436);

	var _ListOption2 = babelHelpers.interopRequireDefault(_ListOption);

	var _utilPropTypes = __webpack_require__(1413);

	var _utilPropTypes2 = babelHelpers.interopRequireDefault(_utilPropTypes);

	var _utilCompat = __webpack_require__(1412);

	var _utilCompat2 = babelHelpers.interopRequireDefault(_utilCompat);

	var _classnames = __webpack_require__(1411);

	var _classnames2 = babelHelpers.interopRequireDefault(_classnames);

	var _util_ = __webpack_require__(1408);

	var _util_2 = babelHelpers.interopRequireDefault(_util_);

	var _reactLibWarning = __webpack_require__(117);

	var _reactLibWarning2 = babelHelpers.interopRequireDefault(_reactLibWarning);

	var optionId = function optionId(id, idx) {
	  return '' + id + '__option__' + idx;
	};

	exports['default'] = _react2['default'].createClass({

	  displayName: 'List',

	  mixins: [__webpack_require__(1437), __webpack_require__(1438), __webpack_require__(1439), __webpack_require__(1440)()],

	  propTypes: {
	    data: _react2['default'].PropTypes.array,
	    onSelect: _react2['default'].PropTypes.func,
	    onMove: _react2['default'].PropTypes.func,

	    optionComponent: _utilPropTypes2['default'].elementType,
	    itemComponent: _utilPropTypes2['default'].elementType,
	    groupComponent: _utilPropTypes2['default'].elementType,

	    selected: _react2['default'].PropTypes.any,
	    focused: _react2['default'].PropTypes.any,

	    valueField: _react2['default'].PropTypes.string,
	    textField: _utilPropTypes2['default'].accessor,

	    optID: _react2['default'].PropTypes.string,

	    groupBy: _utilPropTypes2['default'].accessor,

	    messages: _react2['default'].PropTypes.shape({
	      emptyList: _utilPropTypes2['default'].message
	    })
	  },

	  getDefaultProps: function getDefaultProps() {
	    return {
	      optID: '',
	      onSelect: function onSelect() {},
	      data: [],
	      optionComponent: _ListOption2['default'],
	      ariaActiveDescendantKey: 'groupedList',
	      messages: {
	        emptyList: 'There are no items in this list'
	      }
	    };
	  },

	  getInitialState: function getInitialState() {
	    var keys = [];

	    return {
	      groups: this._group(this.props.groupBy, this.props.data, keys),

	      sortedKeys: keys
	    };
	  },

	  componentWillReceiveProps: function componentWillReceiveProps(nextProps) {
	    var keys = [];

	    if (nextProps.data !== this.props.data || nextProps.groupBy !== this.props.groupBy) this.setState({
	      groups: this._group(nextProps.groupBy, nextProps.data, keys),
	      sortedKeys: keys
	    });
	  },

	  componentDidMount: function componentDidMount() {
	    this.move();
	  },

	  componentDidUpdate: function componentDidUpdate() {
	    this.ariaActiveDescendant(this._currentActiveID);
	    this.move();
	  },

	  render: function render() {
	    var _this = this;

	    var _props = this.props;
	    var className = _props.className;
	    var role = _props.role;
	    var data = _props.data;
	    var messages = _props.messages;
	    var onSelect = _props.onSelect;
	    var selectedIndex = _props.selectedIndex;
	    var props = babelHelpers.objectWithoutProperties(_props, ['className', 'role', 'data', 'messages', 'onSelect', 'selectedIndex']);
	    var id = this._id();var _state = this.state;
	    var sortedKeys = _state.sortedKeys;
	    var groups = _state.groups;

	    var items = [],
	        idx = -1,
	        group = undefined;

	    this._currentActiveID = null;

	    if (data.length) {
	      items = sortedKeys.reduce(function (items, key) {
	        group = groups[key];
	        items.push(_this._renderGroupHeader(key));

	        for (var itemIdx = 0; itemIdx < group.length; itemIdx++) items.push(_this._renderItem(key, group[itemIdx], ++idx));

	        return items;
	      }, []);
	    } else items = _react2['default'].createElement(
	      'li',
	      { className: 'rw-list-empty' },
	      _util_2['default'].result(messages.emptyList, this.props)
	    );

	    return _react2['default'].createElement(
	      'ul',
	      babelHelpers._extends({
	        ref: 'scrollable',
	        id: id,
	        tabIndex: '-1',
	        className: (0, _classnames2['default'])(className, 'rw-list', 'rw-list-grouped'),
	        role: role === undefined ? 'listbox' : role
	      }, props),
	      items
	    );
	  },

	  _renderGroupHeader: function _renderGroupHeader(group) {
	    var GroupComponent = this.props.groupComponent,
	        id = this._id();

	    return _react2['default'].createElement(
	      'li',
	      {
	        key: 'item_' + group,
	        tabIndex: '-1',
	        role: 'separator',
	        id: id + '_group_' + group,
	        className: 'rw-list-optgroup'
	      },
	      GroupComponent ? _react2['default'].createElement(GroupComponent, { item: group }) : group
	    );
	  },

	  _renderItem: function _renderItem(group, item, idx) {
	    var _props2 = this.props;
	    var focused = _props2.focused;
	    var selected = _props2.selected;
	    var onSelect = _props2.onSelect;
	    var ItemComponent = _props2.itemComponent;
	    var Option = _props2.optionComponent;

	    var currentID = optionId(this._id(), idx);

	    if (focused === item) this._currentActiveID = currentID;

	    return _react2['default'].createElement(
	      Option,
	      {
	        key: 'item_' + group + '_' + idx,
	        id: currentID,
	        dataItem: item,
	        focused: focused === item,
	        selected: selected === item,
	        onClick: onSelect.bind(null, item)
	      },
	      ItemComponent ? _react2['default'].createElement(ItemComponent, {
	        item: item,
	        value: this._dataValue(item),
	        text: this._dataText(item)
	      }) : this._dataText(item)
	    );
	  },

	  _isIndexOf: function _isIndexOf(idx, item) {
	    return this.props.data[idx] === item;
	  },

	  _group: function _group(groupBy, data, keys) {
	    var iter = typeof groupBy === 'function' ? groupBy : function (item) {
	      return item[groupBy];
	    };

	    // the keys array ensures that groups are rendered in the order they came in
	    // which means that if you sort the data array it will render sorted,
	    // so long as you also sorted by group
	    keys = keys || [];

	    (0, _reactLibWarning2['default'])(typeof groupBy !== 'string' || !data.length || _util_2['default'].has(data[0], groupBy), '[React Widgets] You are seem to be trying to group this list by a ' + ('property `' + groupBy + '` that doesn\'t exist in the dataset items, this may be a typo'));

	    return data.reduce(function (grps, item) {
	      var group = iter(item);

	      _util_2['default'].has(grps, group) ? grps[group].push(item) : (keys.push(group), grps[group] = [item]);

	      return grps;
	    }, {});
	  },

	  _data: function _data() {
	    var groups = this.state.groups;

	    return this.state.sortedKeys.reduce(function (flat, grp) {
	      return flat.concat(groups[grp]);
	    }, []);
	  },

	  move: function move() {
	    var selected = this.getItemDOMNode(this.props.focused);

	    if (!selected) return;

	    this.notify('onMove', [selected, _utilCompat2['default'].findDOMNode(this), this.props.focused]);
	  },

	  getItemDOMNode: function getItemDOMNode(item) {
	    var list = _utilCompat2['default'].findDOMNode(this),
	        groups = this.state.groups,
	        idx = -1,
	        itemIdx,
	        child;

	    this.state.sortedKeys.some(function (group) {
	      itemIdx = groups[group].indexOf(item);
	      idx++;

	      if (itemIdx !== -1) return !!(child = list.children[idx + itemIdx + 1]);

	      idx += groups[group].length;
	    });

	    return child;
	  }

	});
	module.exports = exports['default'];

/***/ },

/***/ 1442:
/***/ function(module, exports, __webpack_require__) {

	/* WEBPACK VAR INJECTION */(function(process) {'use strict';
	var METHODS = ['next', 'prev', 'first', 'last'];

	module.exports = function validateListComponent(list) {

	  if (process.env.NODE_ENV !== 'production') {
	    METHODS.forEach(function (method) {
	      return assert(typeof list[method] === 'function', 'List components must implement a `' + method + '()` method');
	    });
	  }
	};

	function assert(condition, msg) {
	  var error;

	  if (!condition) {
	    error = new Error(msg);
	    error.framesToPop = 1;
	    throw error;
	  }
	}
	/* WEBPACK VAR INJECTION */}.call(exports, __webpack_require__(105)))

/***/ },

/***/ 1443:
/***/ function(module, exports, __webpack_require__) {

	/* WEBPACK VAR INJECTION */(function(process) {"use strict";
	var babelHelpers = __webpack_require__(1444);
	var React = __webpack_require__(103);
	var invariant = __webpack_require__(109);

	function customPropType(handler, propType, name) {

	  return function (props, propName, componentName, location) {

	    if (props[propName] !== undefined) {
	      if (!props[handler]) return new Error("You have provided a `" + propName + "` prop to " + "`" + name + "` without an `" + handler + "` handler. This will render a read-only field. " + "If the field should be mutable use `" + defaultKey(propName) + "`. Otherwise, set `" + handler + "`");

	      return propType && propType(props, propName, name, location);
	    }
	  };
	}

	var version = React.version.split(".").map(parseFloat);

	function getType(component) {
	  if (version[0] === 0 && version[1] >= 13) return component;

	  return component.type;
	}

	function getLinkName(name) {
	  return name === "value" ? "valueLink" : name === "checked" ? "checkedLink" : null;
	}

	module.exports = function (Component, controlledValues, taps) {
	  var name = Component.displayName || Component.name || "Component",
	      types = {};

	  if (process.env.NODE_ENV !== "production" && getType(Component).propTypes) {
	    types = transform(controlledValues, function (obj, handler, prop) {
	      var type = getType(Component).propTypes[prop];

	      invariant(typeof handler === "string" && handler.trim().length, "Uncontrollable - [%s]: the prop `%s` needs a valid handler key name in order to make it uncontrollable", Component.displayName, prop);

	      obj[prop] = customPropType(handler, type, Component.displayName);
	      if (type !== undefined) {
	        obj[defaultKey(prop)] = type;
	      }
	    }, {});
	  }

	  name = name[0].toUpperCase() + name.substr(1);

	  taps = taps || {};

	  return React.createClass({

	    displayName: "Uncontrolled" + name,

	    propTypes: types,

	    getInitialState: function () {
	      var props = this.props,
	          keys = Object.keys(controlledValues);

	      return transform(keys, function (state, key) {
	        state[key] = props[defaultKey(key)];
	      }, {});
	    },

	    shouldComponentUpdate: function () {
	      //let the setState trigger the update
	      return !this._notifying;
	    },

	    render: function () {
	      var _this = this;

	      var newProps = {};
	      var _props = this.props;
	      var valueLink = _props.valueLink;
	      var checkedLink = _props.checkedLink;
	      var props = babelHelpers.objectWithoutProperties(_props, ["valueLink", "checkedLink"]);

	      each(controlledValues, function (handle, propName) {
	        var linkPropName = getLinkName(propName),
	            prop = _this.props[propName];

	        if (linkPropName && !isProp(_this.props, propName) && isProp(_this.props, linkPropName)) {
	          prop = _this.props[linkPropName].value;
	        }

	        newProps[propName] = prop !== undefined ? prop : _this.state[propName];

	        newProps[handle] = setAndNotify.bind(_this, propName);
	      });

	      newProps = babelHelpers._extends({}, props, newProps);

	      //console.log('props: ', newProps)
	      each(taps, function (val, key) {
	        return newProps[key] = chain(_this, val, newProps[key]);
	      });

	      return React.createElement(Component, newProps);
	    }
	  });

	  function setAndNotify(propName, value) {
	    for (var _len = arguments.length, args = Array(_len > 2 ? _len - 2 : 0), _key = 2; _key < _len; _key++) {
	      args[_key - 2] = arguments[_key];
	    }

	    var linkName = getLinkName(propName),
	        handler = this.props[controlledValues[propName]];
	    //, controlled = handler && isProp(this.props, propName);

	    if (linkName && isProp(this.props, linkName) && !handler) {
	      handler = this.props[linkName].requestChange
	      //propName = propName === 'valueLink' ? 'value' : 'checked'
	      ;
	    }

	    if (handler) {
	      this._notifying = true;
	      handler.call.apply(handler, [this, value].concat(args));
	      this._notifying = false;
	    }

	    this.setState((function () {
	      var _setState = {};
	      _setState[propName] = value;
	      return _setState;
	    })());
	  }

	  function isProp(props, prop) {
	    return props[prop] !== undefined;
	  }
	};

	function defaultKey(key) {
	  return "default" + key.charAt(0).toUpperCase() + key.substr(1);
	}

	function chain(thisArg, a, b) {
	  return function chainedFunction() {
	    for (var _len = arguments.length, args = Array(_len), _key = 0; _key < _len; _key++) {
	      args[_key] = arguments[_key];
	    }

	    a && a.call.apply(a, [thisArg].concat(args));
	    b && b.call.apply(b, [thisArg].concat(args));
	  };
	}

	function transform(obj, cb, seed) {
	  each(obj, cb.bind(null, seed = seed || (Array.isArray(obj) ? [] : {})));
	  return seed;
	}

	function each(obj, cb, thisArg) {
	  if (Array.isArray(obj)) return obj.forEach(cb, thisArg);

	  for (var key in obj) if (has(obj, key)) cb.call(thisArg, obj[key], key, obj);
	}

	function has(o, k) {
	  return o ? Object.prototype.hasOwnProperty.call(o, k) : false;
	}
	//return !controlled
	/* WEBPACK VAR INJECTION */}.call(exports, __webpack_require__(105)))

/***/ },

/***/ 1444:
/***/ function(module, exports, __webpack_require__) {

	var __WEBPACK_AMD_DEFINE_FACTORY__, __WEBPACK_AMD_DEFINE_ARRAY__, __WEBPACK_AMD_DEFINE_RESULT__;(function (root, factory) {
	  if (true) {
	    !(__WEBPACK_AMD_DEFINE_ARRAY__ = [exports], __WEBPACK_AMD_DEFINE_FACTORY__ = (factory), __WEBPACK_AMD_DEFINE_RESULT__ = (typeof __WEBPACK_AMD_DEFINE_FACTORY__ === 'function' ? (__WEBPACK_AMD_DEFINE_FACTORY__.apply(exports, __WEBPACK_AMD_DEFINE_ARRAY__)) : __WEBPACK_AMD_DEFINE_FACTORY__), __WEBPACK_AMD_DEFINE_RESULT__ !== undefined && (module.exports = __WEBPACK_AMD_DEFINE_RESULT__));
	  } else if (typeof exports === "object") {
	    factory(exports);
	  } else {
	    factory(root.babelHelpers = {});
	  }
	})(this, function (global) {
	  var babelHelpers = global;

	  babelHelpers.objectWithoutProperties = function (obj, keys) {
	    var target = {};

	    for (var i in obj) {
	      if (keys.indexOf(i) >= 0) continue;
	      if (!Object.prototype.hasOwnProperty.call(obj, i)) continue;
	      target[i] = obj[i];
	    }

	    return target;
	  };

	  babelHelpers._extends = Object.assign || function (target) {
	    for (var i = 1; i < arguments.length; i++) {
	      var source = arguments[i];

	      for (var key in source) {
	        if (Object.prototype.hasOwnProperty.call(source, key)) {
	          target[key] = source[key];
	        }
	      }
	    }

	    return target;
	  };
	})

/***/ },

/***/ 1445:
/***/ function(module, exports, __webpack_require__) {

	'use strict';

	var _require = __webpack_require__(1408);

	var has = _require.has;

	module.exports = {

	  componentWillUnmount: function componentWillUnmount() {
	    var timers = this._timers || {};

	    this._unmounted = true;

	    for (var k in timers) if (has(timers, k)) clearTimeout(timers[k]);
	  },

	  setTimeout: function setTimeout(key, cb, duration) {
	    var timers = this._timers || (this._timers = Object.create(null));

	    if (this._unmounted) return;

	    clearTimeout(timers[key]);
	    timers[key] = window.setTimeout(cb, duration);
	  }

	};

/***/ },

/***/ 1446:
/***/ function(module, exports, __webpack_require__) {

	'use strict';
	var _ = __webpack_require__(1408);

	//backport PureRenderEqual
	module.exports = {

	  shouldComponentUpdate: function shouldComponentUpdate(nextProps, nextState) {
	    return !_.isShallowEqual(this.props, nextProps) || !_.isShallowEqual(this.state, nextState);
	  }
	};

/***/ },

/***/ 1447:
/***/ function(module, exports, __webpack_require__) {

	'use strict';
	var React = __webpack_require__(103),
	    filters = __webpack_require__(1430),
	    CustomPropTypes = __webpack_require__(1413),
	    helper = __webpack_require__(1438);

	var dflt = function dflt(f) {
	  return f === true ? 'startsWith' : f ? f : 'eq';
	};

	module.exports = {

	  propTypes: {
	    data: React.PropTypes.array,
	    value: React.PropTypes.any,
	    filter: CustomPropTypes.filter,
	    caseSensitive: React.PropTypes.bool,
	    minLength: React.PropTypes.number
	  },

	  getDefaultProps: function getDefaultProps() {
	    return {
	      caseSensitive: false,
	      minLength: 1
	    };
	  },

	  filterIndexOf: function filterIndexOf(items, searchTerm) {
	    var idx = -1,
	        matches = typeof this.props.filter === 'function' ? this.props.filter : getFilter(filters[dflt(this.props.filter)], searchTerm, this);

	    if (!searchTerm || !searchTerm.trim() || this.props.filter && searchTerm.length < (this.props.minLength || 1)) return -1;

	    items.every(function (item, i) {
	      if (matches(item, searchTerm, i)) return (idx = i, false);

	      return true;
	    });

	    return idx;
	  },

	  filter: function filter(items, searchTerm) {
	    var matches = typeof this.props.filter === 'string' ? getFilter(filters[this.props.filter], searchTerm, this) : this.props.filter;

	    if (!matches || !searchTerm || !searchTerm.trim() || searchTerm.length < (this.props.minLength || 1)) return items;

	    return items.filter(function (item, idx) {
	      return matches(item, searchTerm, idx);
	    });
	  }
	};

	function getFilter(matcher, searchTerm, ctx) {
	  searchTerm = !ctx.props.caseSensitive ? searchTerm.toLowerCase() : searchTerm;

	  return function (item) {
	    var val = helper._dataText.call(ctx, item);

	    if (!ctx.props.caseSensitive) val = val.toLowerCase();

	    return matcher(val, searchTerm);
	  };
	}

/***/ },

/***/ 1448:
/***/ function(module, exports, __webpack_require__) {

	'use strict';
	var scrollTo = __webpack_require__(1449);

	module.exports = {

	  _scrollTo: function _scrollTo(selected, list, focused) {
	    var state = this._scrollState || (this._scrollState = {}),
	        handler = this.props.onMove,
	        lastVisible = state.visible,
	        lastItem = state.focused,
	        shown,
	        changed;

	    state.visible = !(!list.offsetWidth || !list.offsetHeight);
	    state.focused = focused;

	    changed = lastItem !== focused;
	    shown = state.visible && !lastVisible;

	    if (shown || state.visible && changed) {
	      if (handler) handler(selected, list, focused);else {
	        state.scrollCancel && state.scrollCancel();
	        state.scrollCancel = scrollTo(selected, list);
	      }
	    }
	  }
	};

/***/ },

/***/ 1449:
/***/ function(module, exports, __webpack_require__) {

	'use strict';
	var getOffset = __webpack_require__(1433),
	    height = __webpack_require__(1432),
	    getScrollParent = __webpack_require__(1450),
	    scrollTop = __webpack_require__(1451),
	    raf = __webpack_require__(1452),
	    getWindow = __webpack_require__(1434);

	module.exports = function scrollTo(selected, scrollParent) {
	    var offset = getOffset(selected),
	        poff = { top: 0, left: 0 },
	        list,
	        listScrollTop,
	        selectedTop,
	        isWin,
	        selectedHeight,
	        listHeight,
	        bottom;

	    if (!selected) return;

	    list = scrollParent || getScrollParent(selected);
	    isWin = getWindow(list);
	    listScrollTop = scrollTop(list);

	    listHeight = height(list, true);
	    isWin = getWindow(list);

	    if (!isWin) poff = getOffset(list);

	    offset = {
	        top: offset.top - poff.top,
	        left: offset.left - poff.left,
	        height: offset.height,
	        width: offset.width
	    };

	    selectedHeight = offset.height;
	    selectedTop = offset.top + (isWin ? 0 : listScrollTop);
	    bottom = selectedTop + selectedHeight;

	    listScrollTop = listScrollTop > selectedTop ? selectedTop : bottom > listScrollTop + listHeight ? bottom - listHeight : listScrollTop;

	    var id = raf(function () {
	        return scrollTop(list, listScrollTop);
	    });

	    return function () {
	        return raf.cancel(id);
	    };
	};

/***/ },

/***/ 1450:
/***/ function(module, exports, __webpack_require__) {

	'use strict';

	var css = __webpack_require__(1421),
	    height = __webpack_require__(1432);

	module.exports = function scrollPrarent(node) {
	  var position = css(node, 'position'),
	      excludeStatic = position === 'absolute',
	      ownerDoc = node.ownerDocument;

	  if (position === 'fixed') return ownerDoc || document;

	  while ((node = node.parentNode) && node.nodeType !== 9) {

	    var isStatic = excludeStatic && css(node, 'position') === 'static',
	        style = css(node, 'overflow') + css(node, 'overflow-y') + css(node, 'overflow-x');

	    if (isStatic) continue;

	    if (/(auto|scroll)/.test(style) && height(node) < node.scrollHeight) return node;
	  }

	  return document;
	};

/***/ },

/***/ 1451:
/***/ function(module, exports, __webpack_require__) {

	'use strict';
	var getWindow = __webpack_require__(1434);

	module.exports = function scrollTop(node, val) {
	  var win = getWindow(node);

	  if (val === undefined) return win ? 'pageYOffset' in win ? win.pageYOffset : win.document.documentElement.scrollTop : node.scrollTop;

	  if (win) win.scrollTo('pageXOffset' in win ? win.pageXOffset : win.document.documentElement.scrollLeft, val);else node.scrollTop = val;
	};

/***/ },

/***/ 1452:
/***/ function(module, exports, __webpack_require__) {

	'use strict';

	var canUseDOM = __webpack_require__(1410);

	var vendors = ['', 'webkit', 'moz', 'o', 'ms'],
	    cancel = 'clearTimeout',
	    raf = fallback,
	    compatRaf;

	var getKey = function getKey(vendor, k) {
	  return vendor + (!vendor ? k : k[0].toUpperCase() + k.substr(1)) + 'AnimationFrame';
	};

	if (canUseDOM) {
	  vendors.some(function (vendor) {
	    var rafKey = getKey(vendor, 'request');

	    if (rafKey in window) {
	      cancel = getKey(vendor, 'cancel');
	      return raf = function (cb) {
	        return window[rafKey](cb);
	      };
	    }
	  });
	}

	/* https://github.com/component/raf */
	var prev = new Date().getTime();

	function fallback(fn) {
	  var curr = new Date().getTime(),
	      ms = Math.max(0, 16 - (curr - prev)),
	      req = setTimeout(fn, ms);

	  prev = curr;
	  return req;
	}

	compatRaf = function (cb) {
	  return raf(cb);
	};
	compatRaf.cancel = function (id) {
	  return window[cancel](id);
	};

	module.exports = compatRaf;

/***/ },

/***/ 1453:
/***/ function(module, exports, __webpack_require__) {

	'use strict';
	var React = __webpack_require__(103);

	module.exports = {

	  propTypes: {
	    isRtl: React.PropTypes.bool
	  },

	  contextTypes: {
	    isRtl: React.PropTypes.bool
	  },

	  childContextTypes: {
	    isRtl: React.PropTypes.bool
	  },

	  getChildContext: function getChildContext() {
	    return {
	      isRtl: this.props.isRtl || this.context && this.context.isRtl
	    };
	  },

	  isRtl: function isRtl() {
	    return !!(this.props.isRtl || this.context && this.context.isRtl);
	  }

	};

/***/ },

/***/ 1454:
/***/ function(module, exports, __webpack_require__) {

	'use strict';

	var babelHelpers = __webpack_require__(1407);

	exports.__esModule = true;

	var _react = __webpack_require__(103);

	var _react2 = babelHelpers.interopRequireDefault(_react);

	var _classnames = __webpack_require__(1411);

	var _classnames2 = babelHelpers.interopRequireDefault(_classnames);

	var _util_ = __webpack_require__(1408);

	var _util_2 = babelHelpers.interopRequireDefault(_util_);

	var _utilFilter = __webpack_require__(1430);

	var _utilFilter2 = babelHelpers.interopRequireDefault(_utilFilter);

	var _Popup = __webpack_require__(1431);

	var _Popup2 = babelHelpers.interopRequireDefault(_Popup);

	var _WidgetButton = __webpack_require__(1455);

	var _WidgetButton2 = babelHelpers.interopRequireDefault(_WidgetButton);

	var _ComboboxInput = __webpack_require__(1456);

	var _ComboboxInput2 = babelHelpers.interopRequireDefault(_ComboboxInput);

	var _utilCompat = __webpack_require__(1412);

	var _utilCompat2 = babelHelpers.interopRequireDefault(_utilCompat);

	var _utilPropTypes = __webpack_require__(1413);

	var _utilPropTypes2 = babelHelpers.interopRequireDefault(_utilPropTypes);

	var _List = __webpack_require__(1435);

	var _List2 = babelHelpers.interopRequireDefault(_List);

	var _ListGroupable = __webpack_require__(1441);

	var _ListGroupable2 = babelHelpers.interopRequireDefault(_ListGroupable);

	var _utilValidateListInterface = __webpack_require__(1442);

	var _utilValidateListInterface2 = babelHelpers.interopRequireDefault(_utilValidateListInterface);

	var _uncontrollable = __webpack_require__(1443);

	var _uncontrollable2 = babelHelpers.interopRequireDefault(_uncontrollable);

	var defaultSuggest = function defaultSuggest(f) {
	  return f === true ? 'startsWith' : f ? f : 'eq';
	};

	var omit = _util_2['default'].omit;
	var pick = _util_2['default'].pick;
	var result = _util_2['default'].result;

	var propTypes = {
	  //-- controlled props -----------
	  value: _react2['default'].PropTypes.any,
	  onChange: _react2['default'].PropTypes.func,
	  open: _react2['default'].PropTypes.bool,
	  onToggle: _react2['default'].PropTypes.func,
	  //------------------------------------

	  itemComponent: _utilPropTypes2['default'].elementType,
	  listComponent: _utilPropTypes2['default'].elementType,

	  groupComponent: _utilPropTypes2['default'].elementType,
	  groupBy: _utilPropTypes2['default'].accessor,

	  data: _react2['default'].PropTypes.array,
	  valueField: _react2['default'].PropTypes.string,
	  textField: _utilPropTypes2['default'].accessor,
	  name: _react2['default'].PropTypes.string,

	  onSelect: _react2['default'].PropTypes.func,

	  disabled: _react2['default'].PropTypes.oneOfType([_react2['default'].PropTypes.bool, _react2['default'].PropTypes.oneOf(['disabled'])]),

	  readOnly: _react2['default'].PropTypes.oneOfType([_react2['default'].PropTypes.bool, _react2['default'].PropTypes.oneOf(['readOnly'])]),

	  suggest: _utilPropTypes2['default'].filter,
	  filter: _utilPropTypes2['default'].filter,

	  busy: _react2['default'].PropTypes.bool,

	  dropUp: _react2['default'].PropTypes.bool,
	  duration: _react2['default'].PropTypes.number, //popup

	  placeholder: _react2['default'].PropTypes.string,

	  messages: _react2['default'].PropTypes.shape({
	    open: _utilPropTypes2['default'].message,
	    emptyList: _utilPropTypes2['default'].message,
	    emptyFilter: _utilPropTypes2['default'].message
	  })
	};

	var ComboBox = _react2['default'].createClass({

	  displayName: 'ComboBox',

	  mixins: [__webpack_require__(1437), __webpack_require__(1445), __webpack_require__(1447), __webpack_require__(1438), __webpack_require__(1448), __webpack_require__(1453), __webpack_require__(1440)('input')],

	  propTypes: propTypes,

	  getInitialState: function getInitialState() {
	    var items = this.process(this.props.data, this.props.value),
	        idx = this._dataIndexOf(items, this.props.value);

	    return {
	      selectedItem: items[idx],
	      focusedItem: items[! ~idx ? 0 : idx],
	      processedData: items,
	      open: false
	    };
	  },

	  getDefaultProps: function getDefaultProps() {
	    return {
	      data: [],
	      value: '',
	      open: false,
	      suggest: false,
	      filter: false,
	      delay: 500,

	      messages: msgs(),
	      ariaActiveDescendantKey: 'combobox'
	    };
	  },

	  componentDidUpdate: function componentDidUpdate() {
	    this.refs.list && (0, _utilValidateListInterface2['default'])(this.refs.list);
	  },

	  shouldComponentUpdate: function shouldComponentUpdate(nextProps, nextState) {
	    var isSuggesting = this.refs.input && this.refs.input.isSuggesting(),
	        stateChanged = !_util_2['default'].isShallowEqual(nextState, this.state),
	        valueChanged = !_util_2['default'].isShallowEqual(nextProps, this.props);

	    return isSuggesting || stateChanged || valueChanged;
	  },

	  componentWillReceiveProps: function componentWillReceiveProps(nextProps) {
	    var rawIdx = this._dataIndexOf(nextProps.data, nextProps.value),
	        valueItem = rawIdx === -1 ? nextProps.value : nextProps.data[rawIdx],
	        isSuggesting = this.refs.input.isSuggesting(),
	        items = this.process(nextProps.data, nextProps.value, (rawIdx === -1 || isSuggesting) && this._dataText(valueItem)),
	        idx = this._dataIndexOf(items, nextProps.value),
	        focused = this.filterIndexOf(items, this._dataText(valueItem));

	    this._searchTerm = '';

	    this.setState({
	      processedData: items,
	      selectedItem: items[idx],
	      focusedItem: items[idx === -1 ? focused !== -1 ? focused : 0 // focus the closest match
	      : idx]
	    });
	  },

	  render: function render() {
	    var _cx,
	        _this = this;

	    var _props = this.props;
	    var className = _props.className;
	    var tabIndex = _props.tabIndex;
	    var filter = _props.filter;
	    var suggest = _props.suggest;
	    var groupBy = _props.groupBy;
	    var messages = _props.messages;
	    var data = _props.data;
	    var busy = _props.busy;
	    var dropUp = _props.dropUp;
	    var name = _props.name;
	    var placeholder = _props.placeholder;
	    var value = _props.value;
	    var open = _props.open;
	    var disabled = _props.disabled;
	    var readOnly = _props.readOnly;
	    var List = _props.listComponent;

	    List = List || groupBy && _ListGroupable2['default'] || _List2['default'];

	    var elementProps = omit(this.props, Object.keys(propTypes));
	    var listProps = pick(this.props, Object.keys(_utilCompat2['default'].type(List).propTypes));
	    var popupProps = pick(this.props, Object.keys(_utilCompat2['default'].type(_Popup2['default']).propTypes));

	    var _state = this.state;
	    var focusedItem = _state.focusedItem;
	    var selectedItem = _state.selectedItem;
	    var focused = _state.focused;

	    var items = this._data(),
	        valueItem = this._dataItem(data, value) // take value from the raw data
	    ,
	        inputID = this._id('_input'),
	        listID = this._id('_listbox'),
	        completeType = this.props.suggest ? this.props.filter ? 'both' : 'inline' : this.props.filter ? 'list' : '';

	    var shouldRenderList = _util_2['default'].isFirstFocusedRender(this) || open;

	    messages = msgs(messages);

	    return _react2['default'].createElement(
	      'div',
	      babelHelpers._extends({}, elementProps, {
	        ref: 'element',
	        onKeyDown: this._keyDown,
	        onFocus: this._focus.bind(null, true),
	        onBlur: this._focus.bind(null, false),
	        tabIndex: '-1',
	        className: (0, _classnames2['default'])(className, 'rw-combobox', 'rw-widget', (_cx = {}, _cx['rw-state-focus'] = focused, _cx['rw-state-disabled'] = disabled, _cx['rw-state-readonly'] = readOnly, _cx['rw-rtl'] = this.isRtl(), _cx['rw-open' + (dropUp ? '-up' : '')] = open, _cx))
	      }),
	      _react2['default'].createElement(
	        _WidgetButton2['default'],
	        {
	          tabIndex: '-1',
	          className: 'rw-select',
	          onClick: this.toggle,
	          disabled: !!(this.props.disabled || this.props.readOnly)
	        },
	        _react2['default'].createElement(
	          'i',
	          { className: (0, _classnames2['default'])('rw-i rw-i-caret-down', { 'rw-loading': busy }) },
	          _react2['default'].createElement(
	            'span',
	            { className: 'rw-sr' },
	            _util_2['default'].result(messages.open, this.props)
	          )
	        )
	      ),
	      _react2['default'].createElement(_ComboboxInput2['default'], {
	        ref: 'input',
	        id: inputID,
	        tabIndex: tabIndex,
	        suggest: suggest,
	        name: name,
	        role: 'combobox',
	        'aria-owns': listID,
	        'aria-busy': !!busy,
	        'aria-autocomplete': completeType,
	        'aria-expanded': open,
	        'aria-haspopup': true,
	        placeholder: placeholder,
	        disabled: disabled,
	        readOnly: readOnly,
	        className: 'rw-input',
	        value: this._dataText(valueItem),
	        onChange: this._inputTyping,
	        onKeyDown: this._inputKeyDown
	      }),
	      _react2['default'].createElement(
	        _Popup2['default'],
	        babelHelpers._extends({}, popupProps, {
	          onOpening: function () {
	            return _this.refs.list.forceUpdate();
	          },
	          onRequestClose: this.close
	        }),
	        _react2['default'].createElement(
	          'div',
	          null,
	          shouldRenderList && _react2['default'].createElement(List, babelHelpers._extends({ ref: 'list'
	          }, listProps, {
	            id: listID,
	            data: items,
	            selected: selectedItem,
	            focused: focusedItem,
	            'aria-hidden': !open,
	            'aria-labelledby': inputID,
	            'aria-live': open && 'polite',
	            onSelect: this._onSelect,
	            onMove: this._scrollTo,
	            messages: {
	              emptyList: data.length ? messages.emptyFilter : messages.emptyList
	            } }))
	        )
	      )
	    );
	  },

	  _onSelect: _util_2['default'].ifNotDisabled(function (data) {
	    this.close();
	    this.notify('onSelect', data);
	    this.change(data);
	    this.focus();
	  }),

	  _inputKeyDown: function _inputKeyDown(e) {
	    this._deleting = e.key === 'Backspace' || e.key === 'Delete';
	    this._isTyping = true;
	  },

	  _inputTyping: function _inputTyping(e) {
	    var _this2 = this;

	    var self = this,
	        shouldSuggest = !!this.props.suggest,
	        strVal = e.target.value,
	        suggestion,
	        data;

	    suggestion = this._deleting || !shouldSuggest ? strVal : this.suggest(this._data(), strVal);

	    suggestion = suggestion || strVal;

	    data = _util_2['default'].find(self.props.data, function (item) {
	      return _this2._dataText(item).toLowerCase() === suggestion.toLowerCase();
	    });

	    this.change(!this._deleting && data ? data : strVal, true);

	    this.open();
	  },

	  focus: function focus() {
	    this.refs.input.focus();
	  },

	  _focus: _util_2['default'].ifNotDisabled(true, function (focused, e) {
	    var _this3 = this;

	    !focused && this.refs.input.accept(); //not suggesting anymore

	    this.setTimeout('focus', function () {

	      if (!focused) _this3.close();

	      if (focused !== _this3.state.focused) {
	        _this3.notify(focused ? 'onFocus' : 'onBlur', e);
	        _this3.setState({ focused: focused });
	      }
	    });
	  }),

	  _keyDown: _util_2['default'].ifNotDisabled(function (e) {
	    var self = this,
	        key = e.key,
	        alt = e.altKey,
	        list = this.refs.list,
	        focusedItem = this.state.focusedItem,
	        selectedItem = this.state.selectedItem,
	        isOpen = this.props.open;

	    if (key === 'End') if (isOpen) this.setState({ focusedItem: list.last() });else select(list.last(), true);else if (key === 'Home') if (isOpen) this.setState({ focusedItem: list.first() });else select(list.first(), true);else if (key === 'Escape' && isOpen) this.close();else if (key === 'Enter' && isOpen) {
	      select(this.state.focusedItem, true);
	    } else if (key === 'ArrowDown') {
	      if (alt) this.open();else {
	        if (isOpen) this.setState({ focusedItem: list.next(focusedItem) });else select(list.next(selectedItem), true);
	      }
	    } else if (key === 'ArrowUp') {
	      if (alt) this.close();else {
	        if (isOpen) this.setState({ focusedItem: list.prev(focusedItem) });else select(list.prev(selectedItem), true);
	      }
	    }

	    this.notify('onKeyDown', [e]);

	    function select(item, fromList) {
	      if (!item) return self.change(_utilCompat2['default'].findDOMNode(self.refs.input).value, false);

	      self.refs.input.accept(true); //removes caret

	      if (fromList) return self._onSelect(item);

	      self.change(item, false);
	    }
	  }),

	  change: function change(data, typing) {
	    this._typedChange = !!typing;
	    this.notify('onChange', data);
	  },

	  open: function open() {
	    if (!this.props.open) this.notify('onToggle', true);
	  },

	  close: function close() {
	    if (this.props.open) this.notify('onToggle', false);
	  },

	  toggle: _util_2['default'].ifNotDisabled(function () {
	    this.focus();

	    this.props.open ? this.close() : this.open();
	  }),

	  suggest: function suggest(data, value) {
	    var word = this._dataText(value),
	        suggest = defaultSuggest(this.props.suggest),
	        suggestion;

	    if (!(word || '').trim() || word.length < (this.props.minLength || 1)) return '';

	    suggestion = typeof value === 'string' ? _util_2['default'].find(data, getFilter(suggest, word, this)) : value;

	    if (suggestion && (!this.state || !this.state.deleting)) return this._dataText(suggestion);

	    return '';
	  },

	  _data: function _data() {
	    return this.state.processedData;
	  },

	  process: function process(data, values, searchTerm) {
	    if (this.props.filter && searchTerm) data = this.filter(data, searchTerm);

	    return data;
	  }
	});

	function msgs(msgs) {
	  return babelHelpers._extends({
	    open: 'open combobox',
	    emptyList: 'There are no items in this list',
	    emptyFilter: 'The filter returned no results' }, msgs);
	}

	function getFilter(suggest, word, ctx) {
	  return typeof suggest === 'string' ? function (item) {
	    return _utilFilter2['default'][suggest](ctx._dataText(item).toLowerCase(), word.toLowerCase());
	  } : function (item) {
	    return suggest(item, word);
	  };
	}

	var UncontrolledComboBox = (0, _uncontrollable2['default'])(ComboBox, { open: 'onToggle', value: 'onChange' });

	UncontrolledComboBox.BaseComboBox = ComboBox;

	exports['default'] = UncontrolledComboBox;
	module.exports = exports['default'];

/***/ },

/***/ 1455:
/***/ function(module, exports, __webpack_require__) {

	'use strict';

	var babelHelpers = __webpack_require__(1407);

	var React = __webpack_require__(103);
	var cn = __webpack_require__(1411);
	module.exports = React.createClass({
	  displayName: 'exports',

	  render: function render() {
	    var _props = this.props;
	    var className = _props.className;
	    var children = _props.children;
	    var props = babelHelpers.objectWithoutProperties(_props, ['className', 'children']);

	    return React.createElement(
	      'button',
	      babelHelpers._extends({}, props, { type: 'button', className: cn(className, 'rw-btn') }),
	      children
	    );
	  }
	});

/***/ },

/***/ 1456:
/***/ function(module, exports, __webpack_require__) {

	'use strict';

	var babelHelpers = __webpack_require__(1407);

	exports.__esModule = true;

	var _react = __webpack_require__(103);

	var _react2 = babelHelpers.interopRequireDefault(_react);

	var _utilCaret = __webpack_require__(1457);

	var _utilCaret2 = babelHelpers.interopRequireDefault(_utilCaret);

	var _utilCompat = __webpack_require__(1412);

	var _utilCompat2 = babelHelpers.interopRequireDefault(_utilCompat);

	exports['default'] = _react2['default'].createClass({

	  displayName: 'ComboboxInput',

	  propTypes: {
	    value: _react2['default'].PropTypes.string,
	    onChange: _react2['default'].PropTypes.func.isRequired
	  },

	  componentDidUpdate: function componentDidUpdate() {
	    var input = _utilCompat2['default'].findDOMNode(this),
	        val = this.props.value;

	    if (this.isSuggesting()) {
	      var start = val.toLowerCase().indexOf(this._last.toLowerCase()) + this._last.length,
	          end = val.length - start;

	      if (start >= 0) {
	        (0, _utilCaret2['default'])(input, start, start + end);
	      }
	    }
	  },

	  getDefaultProps: function getDefaultProps() {
	    return {
	      value: ''
	    };
	  },

	  render: function render() {
	    return _react2['default'].createElement('input', babelHelpers._extends({}, this.props, {
	      type: 'text',
	      'aria-disabled': this.props.disabled,
	      'aria-readonly': this.props.readOnly,
	      className: this.props.className + ' rw-input',
	      onKeyDown: this.props.onKeyDown,
	      onChange: this._change,
	      value: this.props.value == null ? '' : this.props.value
	    }));
	  },

	  isSuggesting: function isSuggesting() {
	    var val = this.props.value,
	        isSuggestion = this._last != null && val.toLowerCase().indexOf(this._last.toLowerCase()) !== -1;

	    return this.props.suggest && isSuggestion;
	  },

	  accept: function accept(removeCaret) {
	    var val = _utilCompat2['default'].findDOMNode(this).value || '',
	        end = val.length;

	    this._last = null;
	    removeCaret && (0, _utilCaret2['default'])(_utilCompat2['default'].findDOMNode(this), end, end);
	  },

	  _change: function _change(e) {
	    var val = e.target.value,
	        pl = !!this.props.placeholder;

	    // IE fires input events when setting/unsetting placeholders.
	    // issue #112
	    if (pl && !val && val === (this.props.value || '')) return;

	    this._last = val;
	    this.props.onChange(e, val);
	  },

	  focus: function focus() {
	    _utilCompat2['default'].findDOMNode(this).focus();
	  }
	});
	module.exports = exports['default'];

/***/ },

/***/ 1457:
/***/ function(module, exports) {

	/*eslint-disable no-empty */
	'use strict';

	module.exports = function caret(el, start, end) {
	  if (start === undefined) return get(el);

	  set(el, start, end);
	};

	function get(el) {
	  var start, end, rangeEl, clone;

	  if (el.selectionStart !== undefined) {
	    start = el.selectionStart;
	    end = el.selectionEnd;
	  } else {
	    try {
	      el.focus();
	      rangeEl = el.createTextRange();
	      clone = rangeEl.duplicate();

	      rangeEl.moveToBookmark(document.selection.createRange().getBookmark());
	      clone.setEndPoint('EndToStart', rangeEl);

	      start = clone.text.length;
	      end = start + rangeEl.text.length;
	    } catch (e) {}
	  }

	  return { start: start, end: end };
	}

	function set(el, start, end) {
	  var rangeEl;

	  try {
	    if (el.selectionStart !== undefined) {
	      el.focus();
	      el.setSelectionRange(start, end);
	    } else {
	      el.focus();
	      rangeEl = el.createTextRange();
	      rangeEl.collapse(true);
	      rangeEl.moveStart('character', start);
	      rangeEl.moveEnd('character', end - start);
	      rangeEl.select();
	    }
	  } catch (e) {}
	}
	/* not focused or not visible */ /* not focused or not visible */

/***/ },

/***/ 1458:
/***/ function(module, exports, __webpack_require__) {

	'use strict';

	var babelHelpers = __webpack_require__(1407);

	exports.__esModule = true;

	var _VIEW, _OPPOSITE_DIRECTION, _MULTIPLIER;

	var _react = __webpack_require__(103);

	var _react2 = babelHelpers.interopRequireDefault(_react);

	var _classnames = __webpack_require__(1411);

	var _classnames2 = babelHelpers.interopRequireDefault(_classnames);

	var _utilCompat = __webpack_require__(1412);

	var _utilCompat2 = babelHelpers.interopRequireDefault(_utilCompat);

	var _Header = __webpack_require__(1459);

	var _Header2 = babelHelpers.interopRequireDefault(_Header);

	var _Footer = __webpack_require__(1461);

	var _Footer2 = babelHelpers.interopRequireDefault(_Footer);

	var _Month = __webpack_require__(1462);

	var _Month2 = babelHelpers.interopRequireDefault(_Month);

	var _Year = __webpack_require__(1465);

	var _Year2 = babelHelpers.interopRequireDefault(_Year);

	var _Decade = __webpack_require__(1466);

	var _Decade2 = babelHelpers.interopRequireDefault(_Decade);

	var _Century = __webpack_require__(1467);

	var _Century2 = babelHelpers.interopRequireDefault(_Century);

	var _utilConfiguration = __webpack_require__(1414);

	var _utilConfiguration2 = babelHelpers.interopRequireDefault(_utilConfiguration);

	var _utilPropTypes = __webpack_require__(1413);

	var _utilPropTypes2 = babelHelpers.interopRequireDefault(_utilPropTypes);

	var _uncontrollable = __webpack_require__(1443);

	var _uncontrollable2 = babelHelpers.interopRequireDefault(_uncontrollable);

	var _SlideTransition = __webpack_require__(1468);

	var _SlideTransition2 = babelHelpers.interopRequireDefault(_SlideTransition);

	var _utilDates = __webpack_require__(1463);

	var _utilDates2 = babelHelpers.interopRequireDefault(_utilDates);

	var _utilConstants = __webpack_require__(1464);

	var _utilConstants2 = babelHelpers.interopRequireDefault(_utilConstants);

	var _util_ = __webpack_require__(1408);

	var _util_2 = babelHelpers.interopRequireDefault(_util_);

	//values, omit

	var dir = _utilConstants2['default'].directions,
	    values = function values(obj) {
	  return Object.keys(obj).map(function (k) {
	    return obj[k];
	  });
	},
	    invert = function invert(obj) {
	  return _util_2['default'].transform(obj, function (o, val, key) {
	    o[val] = key;
	  }, {});
	};

	var localizers = _utilConfiguration2['default'].locale,
	    views = _utilConstants2['default'].calendarViews,
	    VIEW_OPTIONS = values(views),
	    ALT_VIEW = invert(_utilConstants2['default'].calendarViewHierarchy),
	    NEXT_VIEW = _utilConstants2['default'].calendarViewHierarchy,
	    VIEW_UNIT = _utilConstants2['default'].calendarViewUnits,
	    VIEW = (_VIEW = {}, _VIEW[views.MONTH] = _Month2['default'], _VIEW[views.YEAR] = _Year2['default'], _VIEW[views.DECADE] = _Decade2['default'], _VIEW[views.CENTURY] = _Century2['default'], _VIEW);

	var ARROWS_TO_DIRECTION = {
	  ArrowDown: dir.DOWN,
	  ArrowUp: dir.UP,
	  ArrowRight: dir.RIGHT,
	  ArrowLeft: dir.LEFT
	};

	var OPPOSITE_DIRECTION = (_OPPOSITE_DIRECTION = {}, _OPPOSITE_DIRECTION[dir.LEFT] = dir.RIGHT, _OPPOSITE_DIRECTION[dir.RIGHT] = dir.LEFT, _OPPOSITE_DIRECTION);

	var MULTIPLIER = (_MULTIPLIER = {}, _MULTIPLIER[views.YEAR] = 1, _MULTIPLIER[views.DECADE] = 10, _MULTIPLIER[views.CENTURY] = 100, _MULTIPLIER);

	var format = function format(props, f) {
	  return props[f + 'Format'] || localizers.date.formats[f];
	};

	var propTypes = {

	  onChange: _react2['default'].PropTypes.func,
	  value: _react2['default'].PropTypes.instanceOf(Date),

	  min: _react2['default'].PropTypes.instanceOf(Date),
	  max: _react2['default'].PropTypes.instanceOf(Date),

	  initialView: _react2['default'].PropTypes.oneOf(VIEW_OPTIONS),

	  finalView: function finalView(props, propname, componentName) {
	    var err = _react2['default'].PropTypes.oneOf(VIEW_OPTIONS)(props, propname, componentName);

	    if (err) return err;
	    if (VIEW_OPTIONS.indexOf(props[propname]) < VIEW_OPTIONS.indexOf(props.initialView)) return new Error(('The `' + propname + '` prop: `' + props[propname] + '` cannot be \'lower\' than the `initialView`\n        prop. This creates a range that cannot be rendered.').replace(/\n\t/g, ''));
	  },

	  disabled: _react2['default'].PropTypes.oneOfType([_react2['default'].PropTypes.bool, _react2['default'].PropTypes.oneOf(['disabled'])]),

	  readOnly: _react2['default'].PropTypes.oneOfType([_react2['default'].PropTypes.bool, _react2['default'].PropTypes.oneOf(['readOnly'])]),

	  culture: _react2['default'].PropTypes.string,

	  footer: _react2['default'].PropTypes.bool,

	  dayComponent: _utilPropTypes2['default'].elementType,
	  headerFormat: _utilPropTypes2['default'].dateFormat,
	  footerFormat: _utilPropTypes2['default'].dateFormat,

	  dayFormat: _utilPropTypes2['default'].dateFormat,
	  dateFormat: _utilPropTypes2['default'].dateFormat,
	  monthFormat: _utilPropTypes2['default'].dateFormat,
	  yearFormat: _utilPropTypes2['default'].dateFormat,
	  decadeFormat: _utilPropTypes2['default'].dateFormat,
	  centuryFormat: _utilPropTypes2['default'].dateFormat,

	  messages: _react2['default'].PropTypes.shape({
	    moveBack: _react2['default'].PropTypes.string,
	    moveForward: _react2['default'].PropTypes.string
	  })
	};

	var Calendar = _react2['default'].createClass({

	  displayName: 'Calendar',

	  mixins: [__webpack_require__(1437), __webpack_require__(1445), __webpack_require__(1446), __webpack_require__(1453), __webpack_require__(1440)()],

	  propTypes: propTypes,

	  getInitialState: function getInitialState() {
	    var value = this.inRangeValue(this.props.value);

	    return {
	      selectedIndex: 0,
	      view: this.props.initialView || 'month',
	      currentDate: value ? new Date(value) : this.inRangeValue(new Date())
	    };
	  },

	  getDefaultProps: function getDefaultProps() {
	    return {

	      value: null,
	      min: new Date(1900, 0, 1),
	      max: new Date(2099, 11, 31),

	      initialView: 'month',
	      finalView: 'century',

	      tabIndex: '0',
	      footer: false,

	      ariaActiveDescendantKey: 'calendar',
	      messages: msgs({})
	    };
	  },

	  componentWillReceiveProps: function componentWillReceiveProps(nextProps) {
	    var bottom = VIEW_OPTIONS.indexOf(nextProps.initialView),
	        top = VIEW_OPTIONS.indexOf(nextProps.finalView),
	        current = VIEW_OPTIONS.indexOf(this.state.view),
	        view = this.state.view,
	        val = this.inRangeValue(nextProps.value);

	    if (current < bottom) this.setState({ view: view = nextProps.initialView });else if (current > top) this.setState({ view: view = nextProps.finalView });

	    //if the value changes reset views to the new one
	    if (!_utilDates2['default'].eq(val, dateOrNull(this.props.value), VIEW_UNIT[view])) this.setState({
	      currentDate: val ? new Date(val) : new Date()
	    });
	  },

	  render: function render() {
	    var _this = this;

	    var _props = this.props;
	    var className = _props.className;
	    var value = _props.value;
	    var footerFormat = _props.footerFormat;
	    var disabled = _props.disabled;
	    var readOnly = _props.readOnly;
	    var finalView = _props.finalView;
	    var footer = _props.footer;
	    var messages = _props.messages;
	    var min = _props.min;
	    var max = _props.max;
	    var culture = _props.culture;
	    var duration = _props.duration;
	    var _state = this.state;
	    var view = _state.view;
	    var currentDate = _state.currentDate;
	    var slideDirection = _state.slideDirection;
	    var focused = _state.focused;

	    var View = VIEW[view],
	        unit = VIEW_UNIT[view],
	        todaysDate = new Date(),
	        todayNotInRange = !_utilDates2['default'].inRange(todaysDate, min, max, view);

	    unit = unit === 'day' ? 'date' : unit;

	    var viewID = this._id('_calendar'),
	        labelID = this._id('_calendar_label'),
	        key = view + '_' + _utilDates2['default'][view](currentDate);

	    var elementProps = _util_2['default'].omit(this.props, Object.keys(propTypes)),
	        viewProps = _util_2['default'].pick(this.props, Object.keys(_utilCompat2['default'].type(View).propTypes));

	    var isDisabled = disabled || readOnly;

	    messages = msgs(this.props.messages);

	    return _react2['default'].createElement(
	      'div',
	      babelHelpers._extends({}, elementProps, {
	        role: 'group',
	        onKeyDown: this._keyDown,
	        onFocus: this._focus.bind(null, true),
	        onBlur: this._focus.bind(null, false),
	        className: (0, _classnames2['default'])(className, 'rw-calendar', 'rw-widget', {
	          'rw-state-focus': focused,
	          'rw-state-disabled': disabled,
	          'rw-state-readonly': readOnly,
	          'rw-rtl': this.isRtl()
	        })
	      }),
	      _react2['default'].createElement(_Header2['default'], {
	        label: this._label(),
	        labelId: labelID,
	        messages: messages,
	        upDisabled: isDisabled || view === finalView,
	        prevDisabled: isDisabled || !_utilDates2['default'].inRange(this.nextDate(dir.LEFT), min, max, view),
	        nextDisabled: isDisabled || !_utilDates2['default'].inRange(this.nextDate(dir.RIGHT), min, max, view),
	        onViewChange: this.navigate.bind(null, dir.UP, null),
	        onMoveLeft: this.navigate.bind(null, dir.LEFT, null),
	        onMoveRight: this.navigate.bind(null, dir.RIGHT, null)
	      }),
	      _react2['default'].createElement(
	        _SlideTransition2['default'],
	        {
	          ref: 'animation',
	          duration: duration,
	          direction: slideDirection,
	          onAnimate: function () {
	            return _this.focus(true);
	          }
	        },
	        _react2['default'].createElement(View, babelHelpers._extends({}, viewProps, {
	          tabIndex: '-1',
	          key: key,
	          id: viewID,
	          className: 'rw-calendar-grid',
	          'aria-labelledby': labelID,
	          today: todaysDate,
	          value: value,
	          focused: currentDate,
	          onChange: this._maybeHandle(this.change),
	          onKeyDown: this._keyDown,
	          ariaActiveDescendantKey: 'calendarView'
	        }))
	      ),
	      footer && _react2['default'].createElement(_Footer2['default'], {
	        value: todaysDate,
	        format: footerFormat,
	        culture: culture,
	        disabled: disabled || todayNotInRange,
	        readOnly: readOnly,
	        onClick: this._maybeHandle(this.select)
	      })
	    );
	  },

	  navigate: _util_2['default'].ifNotDisabled(function (direction, date) {
	    var view = this.state.view,
	        slideDir = direction === dir.LEFT || direction === dir.UP ? 'right' : 'left';

	    if (!date) date = [dir.LEFT, dir.RIGHT].indexOf(direction) !== -1 ? this.nextDate(direction) : this.state.currentDate;

	    if (direction === dir.DOWN) view = ALT_VIEW[view] || view;

	    if (direction === dir.UP) view = NEXT_VIEW[view] || view;

	    if (this.isValidView(view) && _utilDates2['default'].inRange(date, this.props.min, this.props.max, view)) {
	      this.notify('onNavigate', [date, slideDir, view]);
	      this.focus(true);

	      this.setState({
	        currentDate: date,
	        slideDirection: slideDir,
	        view: view
	      });
	    }
	  }),

	  focus: function focus() {
	    if (+this.props.tabIndex > -1) _utilCompat2['default'].findDOMNode(this).focus();
	  },

	  _focus: _util_2['default'].ifNotDisabled(true, function (focused, e) {
	    var _this2 = this;

	    if (+this.props.tabIndex === -1) return;

	    this.setTimeout('focus', function () {
	      if (focused !== _this2.state.focused) {
	        _this2.notify(focused ? 'onFocus' : 'onBlur', e);
	        _this2.setState({ focused: focused });
	      }
	    });
	  }),

	  change: function change(date) {
	    if (this.state.view === this.props.initialView) {
	      this.notify('onChange', date);
	      this.focus();
	      return;
	    }

	    this.navigate(dir.DOWN, date);
	  },

	  select: function select(date) {
	    var view = this.props.initialView,
	        slideDir = view !== this.state.view || _utilDates2['default'].gt(date, this.state.currentDate) ? 'left' // move down to a the view
	    : 'right';

	    this.notify('onChange', date);

	    if (this.isValidView(view) && _utilDates2['default'].inRange(date, this.props.min, this.props.max, view)) {
	      this.focus();

	      this.setState({
	        currentDate: date,
	        slideDirection: slideDir,
	        view: view
	      });
	    }
	  },

	  nextDate: function nextDate(direction) {
	    var method = direction === dir.LEFT ? 'subtract' : 'add',
	        view = this.state.view,
	        unit = view === views.MONTH ? view : views.YEAR,
	        multi = MULTIPLIER[view] || 1;

	    return _utilDates2['default'][method](this.state.currentDate, 1 * multi, unit);
	  },

	  _keyDown: _util_2['default'].ifNotDisabled(function (e) {
	    var ctrl = e.ctrlKey,
	        key = e.key,
	        direction = ARROWS_TO_DIRECTION[key],
	        current = this.state.currentDate,
	        view = this.state.view,
	        unit = VIEW_UNIT[view],
	        currentDate = current;

	    if (key === 'Enter') {
	      e.preventDefault();
	      return this.change(current);
	    }

	    if (direction) {
	      if (ctrl) {
	        e.preventDefault();
	        this.navigate(direction);
	      } else {
	        if (this.isRtl() && OPPOSITE_DIRECTION[direction]) direction = OPPOSITE_DIRECTION[direction];

	        currentDate = _utilDates2['default'].move(currentDate, this.props.min, this.props.max, view, direction);

	        if (!_utilDates2['default'].eq(current, currentDate, unit)) {
	          e.preventDefault();

	          if (_utilDates2['default'].gt(currentDate, current, view)) this.navigate(dir.RIGHT, currentDate);else if (_utilDates2['default'].lt(currentDate, current, view)) this.navigate(dir.LEFT, currentDate);else this.setState({ currentDate: currentDate });
	        }
	      }
	    }

	    this.notify('onKeyDown', [e]);
	  }),

	  _label: function _label() {
	    var _props2 = this.props;
	    var culture = _props2.culture;
	    var props = babelHelpers.objectWithoutProperties(_props2, ['culture']);
	    var view = this.state.view;
	    var dt = this.state.currentDate;

	    if (view === 'month') return localizers.date.format(dt, format(props, 'header'), culture);else if (view === 'year') return localizers.date.format(dt, format(props, 'year'), culture);else if (view === 'decade') return localizers.date.format(_utilDates2['default'].startOf(dt, 'decade'), format(props, 'decade'), culture);else if (view === 'century') return localizers.date.format(_utilDates2['default'].startOf(dt, 'century'), format(props, 'century'), culture);
	  },

	  inRangeValue: function inRangeValue(_value) {
	    var value = dateOrNull(_value);

	    if (value === null) return value;

	    return _utilDates2['default'].max(_utilDates2['default'].min(value, this.props.max), this.props.min);
	  },

	  isValidView: function isValidView(next) {
	    var bottom = VIEW_OPTIONS.indexOf(this.props.initialView),
	        top = VIEW_OPTIONS.indexOf(this.props.finalView),
	        current = VIEW_OPTIONS.indexOf(next);

	    return current >= bottom && current <= top;
	  }
	});

	function dateOrNull(dt) {
	  if (dt && !isNaN(dt.getTime())) return dt;
	  return null;
	}

	function msgs(msgs) {
	  return babelHelpers._extends({
	    moveBack: 'navigate back',
	    moveForward: 'navigate forward' }, msgs);
	}

	var UncontrolledCalendar = (0, _uncontrollable2['default'])(Calendar, { value: 'onChange' });

	UncontrolledCalendar.BaseCalendar = Calendar;

	exports['default'] = UncontrolledCalendar;
	module.exports = exports['default'];
	//console.log(document.activeElement)

/***/ },

/***/ 1459:
/***/ function(module, exports, __webpack_require__) {

	'use strict';
	var React = __webpack_require__(103),
	    Btn = __webpack_require__(1455);

	module.exports = React.createClass({
	  displayName: 'exports',

	  propTypes: {
	    label: React.PropTypes.string.isRequired,
	    labelId: React.PropTypes.string,

	    upDisabled: React.PropTypes.bool.isRequired,
	    prevDisabled: React.PropTypes.bool.isRequired,
	    nextDisabled: React.PropTypes.bool.isRequired,
	    onViewChange: React.PropTypes.func.isRequired,
	    onMoveLeft: React.PropTypes.func.isRequired,
	    onMoveRight: React.PropTypes.func.isRequired,

	    messages: React.PropTypes.shape({
	      moveBack: React.PropTypes.string,
	      moveForward: React.PropTypes.string
	    })
	  },

	  mixins: [__webpack_require__(1446), __webpack_require__(1460)],

	  getDefaultProps: function getDefaultProps() {
	    return {
	      messages: {
	        moveBack: 'navigate back',
	        moveForward: 'navigate forward'
	      }
	    };
	  },

	  render: function render() {
	    var _props = this.props;
	    var messages = _props.messages;
	    var label = _props.label;
	    var labelId = _props.labelId;
	    var onMoveRight = _props.onMoveRight;
	    var onMoveLeft = _props.onMoveLeft;
	    var onViewChange = _props.onViewChange;
	    var prevDisabled = _props.prevDisabled;
	    var upDisabled = _props.upDisabled;
	    var nextDisabled = _props.nextDisabled;

	    var rtl = this.isRtl();

	    return React.createElement(
	      'div',
	      { className: 'rw-header' },
	      React.createElement(
	        Btn,
	        { className: 'rw-btn-left',
	          tabIndex: '-1',
	          onClick: onMoveLeft,
	          disabled: prevDisabled,
	          'aria-disabled': prevDisabled,
	          'aria-label': messages.moveBack,
	          title: messages.moveBack
	        },
	        React.createElement('i', { 'aria-hidden': 'false',
	          className: 'rw-i rw-i-caret-' + (rtl ? 'right' : 'left')
	        })
	      ),
	      React.createElement(
	        Btn,
	        {
	          id: labelId,
	          tabIndex: '-1',
	          className: 'rw-btn-view',
	          disabled: upDisabled,
	          'aria-disabled': upDisabled,
	          'aria-live': 'polite',
	          'aria-atomic': 'true',
	          onClick: onViewChange
	        },
	        label
	      ),
	      React.createElement(
	        Btn,
	        { className: 'rw-btn-right',
	          tabIndex: '-1',
	          onClick: onMoveRight,
	          disabled: nextDisabled,
	          title: messages.moveForward,
	          'aria-label': messages.moveForward,
	          'aria-disabled': nextDisabled
	        },
	        React.createElement('i', { 'aria-hidden': 'false',
	          className: 'rw-i rw-i-caret-' + (rtl ? 'left' : 'right')
	        })
	      )
	    );
	  }
	});

/***/ },

/***/ 1460:
/***/ function(module, exports, __webpack_require__) {

	'use strict';
	var React = __webpack_require__(103);

	module.exports = {

	  contextTypes: {
	    isRtl: React.PropTypes.bool
	  },

	  isRtl: function isRtl() {
	    return !!this.context.isRtl;
	  }

	};

/***/ },

/***/ 1461:
/***/ function(module, exports, __webpack_require__) {

	'use strict';

	var React = __webpack_require__(103),
	    Btn = __webpack_require__(1455),
	    localizers = __webpack_require__(1414).locale;

	var format = function format(props) {
	  return props.format || localizers.date.formats.footer;
	};

	module.exports = React.createClass({

	  displayName: 'Footer',

	  render: function render() {
	    var now = this.props.value,
	        formatted = localizers.date.format(now, format(this.props), this.props.culture);

	    return React.createElement(
	      'div',
	      { className: 'rw-footer' },
	      React.createElement(
	        Btn,
	        { tabIndex: '-1',
	          'aria-disabled': !!this.props.disabled,
	          'aria-readonly': !!this.props.readOnly,
	          disabled: this.props.disabled,
	          readOnly: this.props.readOnly,
	          onClick: this.props.onClick.bind(null, now)
	        },
	        formatted
	      )
	    );
	  }

	});

/***/ },

/***/ 1462:
/***/ function(module, exports, __webpack_require__) {

	'use strict';

	var babelHelpers = __webpack_require__(1407);

	exports.__esModule = true;

	var _react = __webpack_require__(103);

	var _react2 = babelHelpers.interopRequireDefault(_react);

	var _classnames = __webpack_require__(1411);

	var _classnames2 = babelHelpers.interopRequireDefault(_classnames);

	var _utilDates = __webpack_require__(1463);

	var _utilDates2 = babelHelpers.interopRequireDefault(_utilDates);

	var _utilConfiguration = __webpack_require__(1414);

	var _utilConfiguration2 = babelHelpers.interopRequireDefault(_utilConfiguration);

	var _utilPropTypes = __webpack_require__(1413);

	var _utilPropTypes2 = babelHelpers.interopRequireDefault(_utilPropTypes);

	var _util_ = __webpack_require__(1408);

	var _util_2 = babelHelpers.interopRequireDefault(_util_);

	var localizers = _utilConfiguration2['default'].locale,
	    dayFormat = function dayFormat(props) {
	  return props.dayFormat || localizers.date.formats.weekday;
	},
	    dateFormat = function dateFormat(props) {
	  return props.dateFormat || localizers.date.formats.dayOfMonth;
	};

	var optionId = function optionId(id, date) {
	  return '' + id + '__month_' + _utilDates2['default'].month(date) + '-' + _utilDates2['default'].date(date);
	};

	var propTypes = {
	  optionID: _react2['default'].PropTypes.func,

	  culture: _react2['default'].PropTypes.string,
	  value: _react2['default'].PropTypes.instanceOf(Date),
	  focused: _react2['default'].PropTypes.instanceOf(Date),
	  min: _react2['default'].PropTypes.instanceOf(Date),
	  max: _react2['default'].PropTypes.instanceOf(Date),

	  dayComponent: _utilPropTypes2['default'].elementType,

	  dayFormat: _utilPropTypes2['default'].dateFormat,
	  dateFormat: _utilPropTypes2['default'].dateFormat,
	  footerFormat: _utilPropTypes2['default'].dateFormat,

	  onChange: _react2['default'].PropTypes.func.isRequired
	};

	var isEqual = function isEqual(dateA, dateB) {
	  return _utilDates2['default'].eq(dateA, dateB, 'day');
	};

	var MonthView = _react2['default'].createClass({

	  displayName: 'MonthView',

	  statics: {
	    isEqual: isEqual
	  },

	  mixins: [__webpack_require__(1437), __webpack_require__(1460), __webpack_require__(1440)()],

	  propTypes: propTypes,

	  componentDidUpdate: function componentDidUpdate() {
	    var activeId = optionId(this._id(), this.props.focused);
	    this.ariaActiveDescendant(activeId, null);
	  },

	  render: function render() {
	    var _props = this.props;
	    var className = _props.className;
	    var focused = _props.focused;
	    var focusID = _props.focusID;
	    var culture = _props.culture;
	    var month = _utilDates2['default'].visibleDays(focused, culture);
	    var rows = _util_2['default'].chunk(month, 7);

	    var elementProps = _util_2['default'].omit(this.props, Object.keys(propTypes));

	    return _react2['default'].createElement(
	      'table',
	      babelHelpers._extends({}, elementProps, {
	        role: 'grid'
	      }),
	      _react2['default'].createElement(
	        'thead',
	        null,
	        _react2['default'].createElement(
	          'tr',
	          null,
	          this._headers(dayFormat(this.props), culture)
	        )
	      ),
	      _react2['default'].createElement(
	        'tbody',
	        null,
	        rows.map(this._row)
	      )
	    );
	  },

	  _row: function _row(row, rowIdx) {
	    var _this = this;

	    var _props2 = this.props;
	    var focused = _props2.focused;
	    var selected = _props2.selected;
	    var disabled = _props2.disabled;
	    var onChange = _props2.onChange;
	    var value = _props2.value;
	    var today = _props2.today;
	    var culture = _props2.culture;
	    var min = _props2.min;
	    var max = _props2.max;
	    var Day = _props2.dayComponent;
	    var id = this._id();
	    var labelFormat = localizers.date.formats.footer;

	    return _react2['default'].createElement(
	      'tr',
	      { key: 'week_' + rowIdx, role: 'row' },
	      row.map(function (day, colIdx) {

	        var isFocused = isEqual(day, focused),
	            isSelected = isEqual(day, value),
	            today = isEqual(day, today),
	            date = localizers.date.format(day, dateFormat(_this.props), culture),
	            label = localizers.date.format(day, labelFormat, culture);

	        var currentID = optionId(id, day);

	        return !_utilDates2['default'].inRange(day, min, max) ? _react2['default'].createElement(
	          'td',
	          { key: 'day_' + colIdx, role: 'presentation', className: 'rw-empty-cell' },
	          ' '
	        ) : _react2['default'].createElement(
	          'td',
	          {
	            key: 'day_' + colIdx,
	            role: 'gridcell',
	            id: currentID,
	            title: label,
	            'aria-selected': isSelected,
	            'aria-label': label,
	            'aria-readonly': disabled
	          },
	          _react2['default'].createElement(
	            'span',
	            {
	              'aria-labelledby': currentID,
	              onClick: onChange.bind(null, day),
	              className: (0, _classnames2['default'])('rw-btn', {
	                'rw-off-range': _utilDates2['default'].month(day) !== _utilDates2['default'].month(focused),
	                'rw-state-focus': isFocused,
	                'rw-state-selected': isSelected,
	                'rw-now': today
	              })
	            },
	            Day ? _react2['default'].createElement(Day, { date: day, label: date }) : date
	          )
	        );
	      })
	    );
	  },

	  _headers: function _headers(format, culture) {
	    return [0, 1, 2, 3, 4, 5, 6].map(function (day) {
	      return _react2['default'].createElement(
	        'th',
	        { key: 'header_' + day },
	        localizers.date.format(day, format, culture)
	      );
	    });
	  }

	});

	exports['default'] = MonthView;
	module.exports = exports['default'];

/***/ },

/***/ 1463:
/***/ function(module, exports, __webpack_require__) {

	'use strict';

	var babelHelpers = __webpack_require__(1407);

	var dateMath = __webpack_require__(1417);

	var _require = __webpack_require__(1464);

	var directions = _require.directions;
	var calendarViewUnits = _require.calendarViewUnits;
	var locale = __webpack_require__(1414).locale;

	var dates = module.exports = babelHelpers._extends(dateMath, {

	  parse: function parse(date, format, culture) {
	    return locale.date.parse(date, format, culture);
	  },

	  format: function format(date, _format, culture) {
	    return locale.date.format(date, _format, culture);
	  },

	  monthsInYear: function monthsInYear(year) {
	    var months = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11],
	        date = new Date(year, 0, 1);

	    return months.map(function (i) {
	      return dates.month(date, i);
	    });
	  },

	  firstVisibleDay: function firstVisibleDay(date, culture) {
	    var firstOfMonth = dates.startOf(date, 'month');

	    return dates.startOf(firstOfMonth, 'week', locale.date.startOfWeek(culture));
	  },

	  lastVisibleDay: function lastVisibleDay(date, culture) {
	    var endOfMonth = dates.endOf(date, 'month');

	    return dates.endOf(endOfMonth, 'week', locale.date.startOfWeek(culture));
	  },

	  visibleDays: function visibleDays(date, culture) {
	    var current = dates.firstVisibleDay(date, culture),
	        last = dates.lastVisibleDay(date, culture),
	        days = [];

	    while (dates.lte(current, last, 'day')) {
	      days.push(current);
	      current = dates.add(current, 1, 'day');
	    }

	    return days;
	  },

	  move: function move(date, min, max, unit, direction) {
	    var isMonth = unit === 'month',
	        isUpOrDown = direction === directions.UP || direction === directions.DOWN,
	        rangeUnit = calendarViewUnits[unit],
	        addUnit = isMonth && isUpOrDown ? 'week' : calendarViewUnits[unit],
	        amount = isMonth || !isUpOrDown ? 1 : 4,
	        newDate;

	    if (direction === directions.UP || direction === directions.LEFT) amount *= -1;

	    newDate = dates.add(date, amount, addUnit);

	    return dates.inRange(newDate, min, max, rangeUnit) ? newDate : date;
	  },

	  merge: function merge(date, time) {
	    if (time == null && date == null) return null;

	    if (time == null) time = new Date();
	    if (date == null) date = new Date();

	    date = dates.startOf(date, 'day');
	    date = dates.hours(date, dates.hours(time));
	    date = dates.minutes(date, dates.minutes(time));
	    date = dates.seconds(date, dates.seconds(time));
	    return dates.milliseconds(date, dates.milliseconds(time));
	  },

	  sameMonth: function sameMonth(dateA, dateB) {
	    return dates.eq(dateA, dateB, 'month');
	  },

	  today: function today() {
	    return this.startOf(new Date(), 'day');
	  },

	  yesterday: function yesterday() {
	    return this.add(this.startOf(new Date(), 'day'), -1, 'day');
	  },

	  tomorrow: function tomorrow() {
	    return this.add(this.startOf(new Date(), 'day'), 1, 'day');
	  }
	});

/***/ },

/***/ 1464:
/***/ function(module, exports) {

	'use strict';

	var _calendarViewHierarchy, _calendarViewUnits;

	var views = {
	  MONTH: 'month',
	  YEAR: 'year',
	  DECADE: 'decade',
	  CENTURY: 'century'
	};

	module.exports = {

	  directions: {
	    LEFT: 'LEFT',
	    RIGHT: 'RIGHT',
	    UP: 'UP',
	    DOWN: 'DOWN'
	  },

	  datePopups: {
	    TIME: 'time',
	    CALENDAR: 'calendar'
	  },

	  calendarViews: views,

	  calendarViewHierarchy: (_calendarViewHierarchy = {}, _calendarViewHierarchy[views.MONTH] = views.YEAR, _calendarViewHierarchy[views.YEAR] = views.DECADE, _calendarViewHierarchy[views.DECADE] = views.CENTURY, _calendarViewHierarchy),

	  calendarViewUnits: (_calendarViewUnits = {}, _calendarViewUnits[views.MONTH] = 'day', _calendarViewUnits[views.YEAR] = views.MONTH, _calendarViewUnits[views.DECADE] = views.YEAR, _calendarViewUnits[views.CENTURY] = views.DECADE, _calendarViewUnits)
	};

/***/ },

/***/ 1465:
/***/ function(module, exports, __webpack_require__) {

	'use strict';

	var babelHelpers = __webpack_require__(1407);

	exports.__esModule = true;

	var _react = __webpack_require__(103);

	var _react2 = babelHelpers.interopRequireDefault(_react);

	var _classnames = __webpack_require__(1411);

	var _classnames2 = babelHelpers.interopRequireDefault(_classnames);

	var _utilDates = __webpack_require__(1463);

	var _utilDates2 = babelHelpers.interopRequireDefault(_utilDates);

	var _utilConfiguration = __webpack_require__(1414);

	var _utilConfiguration2 = babelHelpers.interopRequireDefault(_utilConfiguration);

	var _util_ = __webpack_require__(1408);

	var _util_2 = babelHelpers.interopRequireDefault(_util_);

	var _utilPropTypes = __webpack_require__(1413);

	var _utilPropTypes2 = babelHelpers.interopRequireDefault(_utilPropTypes);

	var localizers = _utilConfiguration2['default'].locale;
	var format = function format(props) {
	  return props.monthFormat || localizers.date.formats.month;
	};

	var propTypes = {
	  optionID: _react2['default'].PropTypes.func,
	  culture: _react2['default'].PropTypes.string,
	  value: _react2['default'].PropTypes.instanceOf(Date),
	  focused: _react2['default'].PropTypes.instanceOf(Date),
	  min: _react2['default'].PropTypes.instanceOf(Date),
	  max: _react2['default'].PropTypes.instanceOf(Date),
	  onChange: _react2['default'].PropTypes.func.isRequired,

	  monthFormat: _utilPropTypes2['default'].dateFormat
	};

	var isEqual = function isEqual(dateA, dateB) {
	  return _utilDates2['default'].eq(dateA, dateB, 'month');
	};
	var optionId = function optionId(id, date) {
	  return '' + id + '__year_' + _utilDates2['default'].year(date) + '-' + _utilDates2['default'].month(date);
	};

	var YearView = _react2['default'].createClass({

	  displayName: 'YearView',

	  mixins: [__webpack_require__(1437), __webpack_require__(1460), __webpack_require__(1440)()],

	  propTypes: propTypes,

	  componentDidUpdate: function componentDidUpdate() {
	    var activeId = optionId(this._id(), this.props.focused);
	    this.ariaActiveDescendant(activeId);
	  },

	  render: function render() {
	    var _props = this.props;
	    var className = _props.className;
	    var focused = _props.focused;
	    var months = _utilDates2['default'].monthsInYear(_utilDates2['default'].year(focused));
	    var rows = _util_2['default'].chunk(months, 4);

	    var elementProps = _util_2['default'].omit(this.props, Object.keys(propTypes));

	    return _react2['default'].createElement(
	      'table',
	      babelHelpers._extends({}, elementProps, {
	        role: 'grid',
	        className: (0, _classnames2['default'])(className, 'rw-nav-view')
	      }),
	      _react2['default'].createElement(
	        'tbody',
	        null,
	        rows.map(this._row)
	      )
	    );
	  },

	  _row: function _row(row, rowIdx) {
	    var _this = this;

	    var _props2 = this.props;
	    var focused = _props2.focused;
	    var selected = _props2.selected;
	    var disabled = _props2.disabled;
	    var onChange = _props2.onChange;
	    var value = _props2.value;
	    var today = _props2.today;
	    var culture = _props2.culture;
	    var min = _props2.min;
	    var max = _props2.max;
	    var Day = _props2.dayComponent;
	    var id = this._id();
	    var labelFormat = localizers.date.formats.header;

	    return _react2['default'].createElement(
	      'tr',
	      { key: rowIdx, role: 'row' },
	      row.map(function (date, colIdx) {
	        var isFocused = isEqual(date, focused),
	            isSelected = isEqual(date, value),
	            currentMonth = isEqual(date, today),
	            label = localizers.date.format(date, labelFormat, culture);

	        var currentID = optionId(id, date);

	        return _utilDates2['default'].inRange(date, min, max, 'month') ? _react2['default'].createElement(
	          'td',
	          {
	            key: colIdx,
	            role: 'gridcell',
	            id: currentID,
	            title: label,
	            'aria-selected': isSelected,
	            'aria-readonly': disabled,
	            'aria-label': label
	          },
	          _react2['default'].createElement(
	            'span',
	            {
	              'aria-labelledby': currentID,
	              onClick: onChange.bind(null, date),
	              className: (0, _classnames2['default'])('rw-btn', {
	                'rw-state-focus': isFocused,
	                'rw-state-selected': isSelected,
	                'rw-now': currentMonth
	              })
	            },
	            localizers.date.format(date, format(_this.props), culture)
	          )
	        ) : _react2['default'].createElement(
	          'td',
	          { key: colIdx, className: 'rw-empty-cell', role: 'presentation' },
	          ' '
	        );
	      })
	    );
	  }

	});

	exports['default'] = YearView;
	module.exports = exports['default'];

/***/ },

/***/ 1466:
/***/ function(module, exports, __webpack_require__) {

	'use strict';

	var babelHelpers = __webpack_require__(1407);

	exports.__esModule = true;

	var _react = __webpack_require__(103);

	var _react2 = babelHelpers.interopRequireDefault(_react);

	var _classnames = __webpack_require__(1411);

	var _classnames2 = babelHelpers.interopRequireDefault(_classnames);

	var _utilDates = __webpack_require__(1463);

	var _utilDates2 = babelHelpers.interopRequireDefault(_utilDates);

	var _utilConfiguration = __webpack_require__(1414);

	var _utilConfiguration2 = babelHelpers.interopRequireDefault(_utilConfiguration);

	var _util_ = __webpack_require__(1408);

	var _util_2 = babelHelpers.interopRequireDefault(_util_);

	var _utilPropTypes = __webpack_require__(1413);

	var _utilPropTypes2 = babelHelpers.interopRequireDefault(_utilPropTypes);

	var localizers = _utilConfiguration2['default'].locale;

	var format = function format(props) {
	  return props.yearFormat || localizers.date.formats.year;
	};

	var propTypes = {
	  optionID: _react2['default'].PropTypes.func,
	  culture: _react2['default'].PropTypes.string,

	  value: _react2['default'].PropTypes.instanceOf(Date),
	  focused: _react2['default'].PropTypes.instanceOf(Date),
	  min: _react2['default'].PropTypes.instanceOf(Date),
	  max: _react2['default'].PropTypes.instanceOf(Date),
	  onChange: _react2['default'].PropTypes.func.isRequired,

	  yearFormat: _utilPropTypes2['default'].dateFormat
	};

	var isEqual = function isEqual(dataA, dateB) {
	  return _utilDates2['default'].eq(dataA, dateB, 'year');
	};
	var optionId = function optionId(id, date) {
	  return '' + id + '__decade_' + _utilDates2['default'].year(date);
	};

	exports['default'] = _react2['default'].createClass({

	  displayName: 'DecadeView',

	  mixins: [__webpack_require__(1437), __webpack_require__(1446), __webpack_require__(1460), __webpack_require__(1440)()],

	  propTypes: propTypes,

	  componentDidUpdate: function componentDidUpdate() {
	    var activeId = optionId(this._id(), this.props.focused);
	    this.ariaActiveDescendant(activeId);
	  },

	  render: function render() {
	    var _props = this.props;
	    var className = _props.className;
	    var focused = _props.focused;
	    var years = getDecadeYears(focused);
	    var rows = _util_2['default'].chunk(years, 4);

	    var elementProps = _util_2['default'].omit(this.props, Object.keys(propTypes));

	    return _react2['default'].createElement(
	      'table',
	      babelHelpers._extends({}, elementProps, {
	        role: 'grid',
	        className: (0, _classnames2['default'])(className, 'rw-nav-view')
	      }),
	      _react2['default'].createElement(
	        'tbody',
	        null,
	        rows.map(this._row)
	      )
	    );
	  },

	  _row: function _row(row, rowIdx) {
	    var _this = this;

	    var _props2 = this.props;
	    var focused = _props2.focused;
	    var selected = _props2.selected;
	    var disabled = _props2.disabled;
	    var onChange = _props2.onChange;
	    var value = _props2.value;
	    var today = _props2.today;
	    var culture = _props2.culture;
	    var min = _props2.min;
	    var max = _props2.max;
	    var Day = _props2.dayComponent;
	    var id = this._id();

	    return _react2['default'].createElement(
	      'tr',
	      { key: 'row_' + rowIdx, role: 'row' },
	      row.map(function (date, colIdx) {
	        var isFocused = isEqual(date, focused),
	            isSelected = isEqual(date, value),
	            currentYear = isEqual(date, today),
	            label = localizers.date.format(date, format(_this.props), culture);

	        var currentID = optionId(id, date);

	        return !_utilDates2['default'].inRange(date, min, max, 'year') ? _react2['default'].createElement(
	          'td',
	          { key: colIdx, role: 'presentation', className: 'rw-empty-cell' },
	          ' '
	        ) : _react2['default'].createElement(
	          'td',
	          {
	            key: colIdx,
	            role: 'gridcell',
	            id: currentID,
	            title: label,
	            'aria-selected': isSelected,
	            'aria-label': label,
	            'aria-readonly': disabled
	          },
	          _react2['default'].createElement(
	            'span',
	            {
	              'aria-labelledby': currentID,
	              onClick: onChange.bind(null, date),
	              className: (0, _classnames2['default'])('rw-btn', {
	                'rw-off-range': !inDecade(date, focused),
	                'rw-state-focus': isFocused,
	                'rw-state-selected': isSelected,
	                'rw-now': currentYear
	              })
	            },
	            label
	          )
	        );
	      })
	    );
	  }
	});

	function inDecade(date, start) {
	  return _utilDates2['default'].gte(date, _utilDates2['default'].startOf(start, 'decade'), 'year') && _utilDates2['default'].lte(date, _utilDates2['default'].endOf(start, 'decade'), 'year');
	}

	function getDecadeYears(_date) {
	  var days = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
	      date = _utilDates2['default'].add(_utilDates2['default'].startOf(_date, 'decade'), -2, 'year');

	  return days.map(function () {
	    return date = _utilDates2['default'].add(date, 1, 'year');
	  });
	}
	module.exports = exports['default'];

/***/ },

/***/ 1467:
/***/ function(module, exports, __webpack_require__) {

	'use strict';

	var babelHelpers = __webpack_require__(1407);

	exports.__esModule = true;

	var _react = __webpack_require__(103);

	var _react2 = babelHelpers.interopRequireDefault(_react);

	var _classnames = __webpack_require__(1411);

	var _classnames2 = babelHelpers.interopRequireDefault(_classnames);

	var _utilDates = __webpack_require__(1463);

	var _utilDates2 = babelHelpers.interopRequireDefault(_utilDates);

	var _utilConfiguration = __webpack_require__(1414);

	var _utilConfiguration2 = babelHelpers.interopRequireDefault(_utilConfiguration);

	var _util_ = __webpack_require__(1408);

	var _util_2 = babelHelpers.interopRequireDefault(_util_);

	var _utilPropTypes = __webpack_require__(1413);

	var _utilPropTypes2 = babelHelpers.interopRequireDefault(_utilPropTypes);

	var localizers = _utilConfiguration2['default'].locale;
	var format = function format(props) {
	  return props.decadeFormat || localizers.date.formats.decade;
	};

	var isEqual = function isEqual(dateA, dateB) {
	  return _utilDates2['default'].eq(dateA, dateB, 'decade');
	};
	var optionId = function optionId(id, date) {
	  return '' + id + '__century_' + _utilDates2['default'].year(date);
	};

	var propTypes = {
	  optionID: _react2['default'].PropTypes.func,
	  culture: _react2['default'].PropTypes.string,
	  value: _react2['default'].PropTypes.instanceOf(Date),
	  min: _react2['default'].PropTypes.instanceOf(Date),
	  max: _react2['default'].PropTypes.instanceOf(Date),

	  onChange: _react2['default'].PropTypes.func.isRequired,
	  decadeFormat: _utilPropTypes2['default'].dateFormat
	};

	exports['default'] = _react2['default'].createClass({

	  displayName: 'CenturyView',

	  mixins: [__webpack_require__(1437), __webpack_require__(1446), __webpack_require__(1460), __webpack_require__(1440)()],

	  propTypes: propTypes,

	  componentDidUpdate: function componentDidUpdate() {
	    var activeId = optionId(this._id(), this.props.focused);
	    this.ariaActiveDescendant(activeId);
	  },

	  render: function render() {
	    var _props = this.props;
	    var className = _props.className;
	    var focused = _props.focused;
	    var years = getCenturyDecades(focused);
	    var rows = _util_2['default'].chunk(years, 4);

	    var elementProps = _util_2['default'].omit(this.props, Object.keys(propTypes));

	    return _react2['default'].createElement(
	      'table',
	      babelHelpers._extends({}, elementProps, {
	        role: 'grid',
	        className: (0, _classnames2['default'])(className, 'rw-nav-view')
	      }),
	      _react2['default'].createElement(
	        'tbody',
	        null,
	        rows.map(this._row)
	      )
	    );
	  },

	  _row: function _row(row, rowIdx) {
	    var _this = this;

	    var _props2 = this.props;
	    var focused = _props2.focused;
	    var selected = _props2.selected;
	    var disabled = _props2.disabled;
	    var onChange = _props2.onChange;
	    var value = _props2.value;
	    var today = _props2.today;
	    var culture = _props2.culture;
	    var min = _props2.min;
	    var max = _props2.max;
	    var id = this._id('_century');

	    return _react2['default'].createElement(
	      'tr',
	      { key: 'row_' + rowIdx, role: 'row' },
	      row.map(function (date, colIdx) {
	        var isFocused = isEqual(date, focused),
	            isSelected = isEqual(date, value),
	            currentDecade = isEqual(date, today),
	            label = localizers.date.format(_utilDates2['default'].startOf(date, 'decade'), format(_this.props), culture);

	        var currentID = optionId(id, date);

	        return !inRange(date, min, max) ? _react2['default'].createElement(
	          'td',
	          { key: colIdx, role: 'gridcell', className: 'rw-empty-cell' },
	          ' '
	        ) : _react2['default'].createElement(
	          'td',
	          {
	            key: colIdx,
	            role: 'gridcell',
	            id: currentID,
	            title: label,
	            'aria-selected': isSelected,
	            'aria-label': label,
	            'aria-readonly': disabled
	          },
	          _react2['default'].createElement(
	            'span',
	            {
	              'aria-labelledby': currentID,
	              onClick: onChange.bind(null, inRangeDate(date, min, max)),
	              className: (0, _classnames2['default'])('rw-btn', {
	                'rw-off-range': !inCentury(date, focused),
	                'rw-state-focus': isFocused,
	                'rw-state-selected': isSelected,
	                'rw-now': currentDecade
	              })
	            },
	            label
	          )
	        );
	      })
	    );
	  }

	});

	function inRangeDate(decade, min, max) {
	  return _utilDates2['default'].max(_utilDates2['default'].min(decade, max), min);
	}

	function inRange(decade, min, max) {
	  return _utilDates2['default'].gte(decade, _utilDates2['default'].startOf(min, 'decade'), 'year') && _utilDates2['default'].lte(decade, _utilDates2['default'].endOf(max, 'decade'), 'year');
	}

	function inCentury(date, start) {
	  return _utilDates2['default'].gte(date, _utilDates2['default'].startOf(start, 'century'), 'year') && _utilDates2['default'].lte(date, _utilDates2['default'].endOf(start, 'century'), 'year');
	}

	function getCenturyDecades(_date) {
	  var days = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
	      date = _utilDates2['default'].add(_utilDates2['default'].startOf(_date, 'century'), -20, 'year');

	  return days.map(function () {
	    return date = _utilDates2['default'].add(date, 10, 'year');
	  });
	}
	module.exports = exports['default'];

/***/ },

/***/ 1468:
/***/ function(module, exports, __webpack_require__) {

	'use strict';

	var babelHelpers = __webpack_require__(1407);

	var React = __webpack_require__(103),
	    ReplaceTransitionGroup = __webpack_require__(1469),
	    compat = __webpack_require__(1412),
	    css = __webpack_require__(1421),
	    getWidth = __webpack_require__(1470),
	    config = __webpack_require__(1414);

	var SlideChildGroup = React.createClass({
	  displayName: 'SlideChildGroup',

	  propTypes: {
	    direction: React.PropTypes.oneOf(['left', 'right']),
	    duration: React.PropTypes.number
	  },

	  componentWillEnter: function componentWillEnter(done) {
	    var _this = this;

	    var node = compat.findDOMNode(this),
	        width = getWidth(node),
	        direction = this.props.direction;

	    width = direction === 'left' ? width : -width;

	    this.ORGINAL_POSITION = node.style.position;

	    css(node, { position: 'absolute', left: width + 'px', top: 0 });

	    config.animate(node, { left: 0 }, this.props.duration, function () {

	      css(node, {
	        position: _this.ORGINAL_POSITION,
	        overflow: 'hidden'
	      });

	      _this.ORGINAL_POSITION = null;
	      done && done();
	    });
	  },

	  componentWillLeave: function componentWillLeave(done) {
	    var _this2 = this;

	    var node = compat.findDOMNode(this),
	        width = getWidth(node),
	        direction = this.props.direction;

	    width = direction === 'left' ? -width : width;

	    this.ORGINAL_POSITION = node.style.position;

	    css(node, { position: 'absolute', top: 0, left: 0 });

	    config.animate(node, { left: width + 'px' }, this.props.duration, function () {
	      css(node, {
	        position: _this2.ORGINAL_POSITION,
	        overflow: 'hidden'
	      });

	      _this2.ORGINAL_POSITION = null;
	      done && done();
	    });
	  },

	  render: function render() {
	    return React.Children.only(this.props.children);
	  }

	});

	module.exports = React.createClass({
	  displayName: 'exports',

	  propTypes: {
	    direction: React.PropTypes.oneOf(['left', 'right']),
	    duration: React.PropTypes.number
	  },

	  getDefaultProps: function getDefaultProps() {
	    return {
	      direction: 'left',
	      duration: 250
	    };
	  },

	  _wrapChild: function _wrapChild(child, ref) {
	    return React.createElement(
	      SlideChildGroup,
	      { key: child.key, ref: ref,
	        direction: this.props.direction,
	        duration: this.props.duration },
	      child
	    );
	  },

	  render: function render() {
	    var _props = this.props;
	    var style = _props.style;
	    var children = _props.children;
	    var props = babelHelpers.objectWithoutProperties(_props, ['style', 'children']);

	    style = babelHelpers._extends({}, style, { position: 'relative', overflow: 'hidden' });

	    return React.createElement(
	      ReplaceTransitionGroup,
	      babelHelpers._extends({}, props, {
	        ref: 'container',
	        childFactory: this._wrapChild,
	        style: style,
	        component: 'div' }),
	      children
	    );
	  },

	  isTransitioning: function isTransitioning() {
	    return this.isMounted() && this.refs.container.isTransitioning();
	  }
	});

/***/ },

/***/ 1469:
/***/ function(module, exports, __webpack_require__) {

	/**
	 * A streamlined version of TransitionGroup built for managing at most two active children
	 * also provides additional hooks for animation start/end
	 * https://github.com/facebook/react/blob/master/src/addons/transitions/ReactTransitionGroup.js
	 * relevent code is licensed accordingly
	 */
	'use strict';

	var React = __webpack_require__(103),
	    css = __webpack_require__(1421),
	    height = __webpack_require__(1432),
	    width = __webpack_require__(1470),
	    compat = __webpack_require__(1412),
	    _ = __webpack_require__(1408);

	module.exports = React.createClass({

	  displayName: 'ReplaceTransitionGroup',

	  propTypes: {
	    component: React.PropTypes.oneOfType([React.PropTypes.element, React.PropTypes.string]),
	    childFactory: React.PropTypes.func,

	    onAnimating: React.PropTypes.func,
	    onAnimate: React.PropTypes.func
	  },

	  getDefaultProps: function getDefaultProps() {
	    return {
	      component: 'span',
	      childFactory: function childFactory(a) {
	        return a;
	      },

	      onAnimating: _.noop,
	      onAnimate: _.noop
	    };
	  },

	  getInitialState: function getInitialState() {
	    return {
	      children: _.splat(this.props.children)
	    };
	  },

	  componentWillReceiveProps: function componentWillReceiveProps(nextProps) {
	    var nextChild = getChild(nextProps.children),
	        stack = this.state.children.slice(),
	        next = stack[1],
	        last = stack[0];

	    var isLastChild = last && key(last) === key(nextChild),
	        isNextChild = next && key(next) === key(nextChild);

	    //no children
	    if (!last) {
	      stack.push(nextChild);
	      this.entering = nextChild;
	    } else if (last && !next && !isLastChild) {
	      //new child
	      stack.push(nextChild);
	      this.leaving = last;
	      this.entering = nextChild;
	    } else if (last && next && !isLastChild && !isNextChild) {
	      // the child is not the current one, exit the current one, add the new one
	      //  - shift the stack down
	      stack.shift();
	      stack.push(nextChild);
	      this.leaving = next;
	      this.entering = nextChild;
	    }
	    //new child that just needs to be re-rendered
	    else if (isLastChild) stack.splice(0, 1, nextChild);else if (isNextChild) stack.splice(1, 1, nextChild);

	    if (this.state.children[0] !== stack[0] || this.state.children[1] !== stack[1]) this.setState({ children: stack });
	  },

	  componentWillMount: function componentWillMount() {
	    this.animatingKeys = {};
	    this.leaving = null;
	    this.entering = null;
	  },

	  componentDidUpdate: function componentDidUpdate() {
	    var entering = this.entering,
	        leaving = this.leaving,
	        first = this.refs[key(entering) || key(leaving)],
	        node = compat.findDOMNode(this),
	        el = first && compat.findDOMNode(first);

	    if (el) css(node, {
	      overflow: 'hidden',
	      height: height(el) + 'px',
	      width: width(el) + 'px'
	    });

	    this.props.onAnimating();

	    this.entering = null;
	    this.leaving = null;

	    if (entering) this.performEnter(key(entering));
	    if (leaving) this.performLeave(key(leaving));
	  },

	  performEnter: function performEnter(key) {
	    var component = this.refs[key];

	    if (!component) return;

	    this.animatingKeys[key] = true;

	    if (component.componentWillEnter) component.componentWillEnter(this._handleDoneEntering.bind(this, key));else this._handleDoneEntering(key);
	  },

	  _tryFinish: function _tryFinish() {

	    if (this.isTransitioning()) return;

	    if (this.isMounted()) css(compat.findDOMNode(this), { overflow: 'visible', height: '', width: '' });

	    this.props.onAnimate();
	  },

	  _handleDoneEntering: function _handleDoneEntering(enterkey) {
	    var component = this.refs[enterkey];

	    if (component && component.componentDidEnter) component.componentDidEnter();

	    delete this.animatingKeys[enterkey];

	    if (key(this.props.children) !== enterkey) this.performLeave(enterkey); // This was removed before it had fully entered. Remove it.

	    this._tryFinish();
	  },

	  isTransitioning: function isTransitioning() {
	    return Object.keys(this.animatingKeys).length !== 0;
	  },

	  performLeave: function performLeave(key) {
	    var component = this.refs[key];

	    if (!component) return;

	    this.animatingKeys[key] = true;

	    if (component.componentWillLeave) component.componentWillLeave(this._handleDoneLeaving.bind(this, key));else this._handleDoneLeaving(key);
	  },

	  _handleDoneLeaving: function _handleDoneLeaving(leavekey) {
	    var component = this.refs[leavekey];

	    if (component && component.componentDidLeave) component.componentDidLeave();

	    delete this.animatingKeys[leavekey];

	    if (key(this.props.children) === leavekey) this.performEnter(leavekey);else if (this.isMounted()) this.setState({
	      children: this.state.children.filter(function (c) {
	        return key(c) !== leavekey;
	      })
	    });

	    this._tryFinish();
	  },

	  render: function render() {
	    var _this = this;

	    var Component = this.props.component;
	    return React.createElement(
	      Component,
	      this.props,
	      this.state.children.map(function (c) {
	        return _this.props.childFactory(c, key(c));
	      })
	    );
	  }
	});

	function getChild(children) {
	  return React.Children.only(children);
	}

	function key(child) {
	  return child && child.key;
	}
	// This entered again before it fully left. Add it again.

/***/ },

/***/ 1470:
/***/ function(module, exports, __webpack_require__) {

	'use strict';

	var offset = __webpack_require__(1433),
	    getWindow = __webpack_require__(1434);

	module.exports = function width(node, client) {
	  var win = getWindow(node);
	  return win ? win.innerWidth : client ? node.clientWidth : offset(node).width;
	};

/***/ },

/***/ 1471:
/***/ function(module, exports, __webpack_require__) {

	'use strict';

	var babelHelpers = __webpack_require__(1407);

	exports.__esModule = true;

	var _react = __webpack_require__(103);

	var _react2 = babelHelpers.interopRequireDefault(_react);

	var _reactLibInvariant = __webpack_require__(109);

	var _reactLibInvariant2 = babelHelpers.interopRequireDefault(_reactLibInvariant);

	var _reactLibGetActiveElement = __webpack_require__(236);

	var _reactLibGetActiveElement2 = babelHelpers.interopRequireDefault(_reactLibGetActiveElement);

	var _classnames = __webpack_require__(1411);

	var _classnames2 = babelHelpers.interopRequireDefault(_classnames);

	var _utilCompat = __webpack_require__(1412);

	var _utilCompat2 = babelHelpers.interopRequireDefault(_utilCompat);

	var _util_ = __webpack_require__(1408);

	var _util_2 = babelHelpers.interopRequireDefault(_util_);

	//pick, omit, has

	var _utilDates = __webpack_require__(1463);

	var _utilDates2 = babelHelpers.interopRequireDefault(_utilDates);

	var _utilConfiguration = __webpack_require__(1414);

	var _utilConfiguration2 = babelHelpers.interopRequireDefault(_utilConfiguration);

	var _utilConstants = __webpack_require__(1464);

	var _utilConstants2 = babelHelpers.interopRequireDefault(_utilConstants);

	var _Popup = __webpack_require__(1431);

	var _Popup2 = babelHelpers.interopRequireDefault(_Popup);

	var _Calendar2 = __webpack_require__(1458);

	var _Calendar3 = babelHelpers.interopRequireDefault(_Calendar2);

	var _TimeList = __webpack_require__(1472);

	var _TimeList2 = babelHelpers.interopRequireDefault(_TimeList);

	var _DateInput = __webpack_require__(1473);

	var _DateInput2 = babelHelpers.interopRequireDefault(_DateInput);

	var _WidgetButton = __webpack_require__(1455);

	var _WidgetButton2 = babelHelpers.interopRequireDefault(_WidgetButton);

	var _utilPropTypes = __webpack_require__(1413);

	var _utilPropTypes2 = babelHelpers.interopRequireDefault(_utilPropTypes);

	var _uncontrollable = __webpack_require__(1443);

	var _uncontrollable2 = babelHelpers.interopRequireDefault(_uncontrollable);

	var views = _utilConstants2['default'].calendarViews;
	var popups = _utilConstants2['default'].datePopups;

	var Calendar = _Calendar3['default'].BaseCalendar;
	var localizers = _utilConfiguration2['default'].locale;
	var viewEnum = Object.keys(views).map(function (k) {
	  return views[k];
	});

	var omit = _util_2['default'].omit;
	var pick = _util_2['default'].pick;
	var result = _util_2['default'].result;

	var propTypes = babelHelpers._extends({}, _utilCompat2['default'].type(Calendar).propTypes, {

	  //-- controlled props -----------
	  value: _react2['default'].PropTypes.instanceOf(Date),
	  onChange: _react2['default'].PropTypes.func,
	  open: _react2['default'].PropTypes.oneOf([false, popups.TIME, popups.CALENDAR]),
	  onToggle: _react2['default'].PropTypes.func,
	  //------------------------------------

	  onSelect: _react2['default'].PropTypes.func,

	  min: _react2['default'].PropTypes.instanceOf(Date),
	  max: _react2['default'].PropTypes.instanceOf(Date),

	  culture: _react2['default'].PropTypes.string,

	  format: _utilPropTypes2['default'].dateFormat,
	  timeFormat: _utilPropTypes2['default'].dateFormat,
	  editFormat: _utilPropTypes2['default'].dateFormat,

	  calendar: _react2['default'].PropTypes.bool,
	  time: _react2['default'].PropTypes.bool,

	  timeComponent: _utilPropTypes2['default'].elementType,

	  //popup
	  dropUp: _react2['default'].PropTypes.bool,
	  duration: _react2['default'].PropTypes.number,

	  placeholder: _react2['default'].PropTypes.string,
	  name: _react2['default'].PropTypes.string,

	  initialView: _react2['default'].PropTypes.oneOf(viewEnum),
	  finalView: _react2['default'].PropTypes.oneOf(viewEnum),

	  disabled: _react2['default'].PropTypes.oneOfType([_react2['default'].PropTypes.bool, _react2['default'].PropTypes.oneOf(['disabled'])]),

	  readOnly: _react2['default'].PropTypes.oneOfType([_react2['default'].PropTypes.bool, _react2['default'].PropTypes.oneOf(['readOnly'])]),

	  parse: _react2['default'].PropTypes.oneOfType([_react2['default'].PropTypes.arrayOf(_react2['default'].PropTypes.string), _react2['default'].PropTypes.string, _react2['default'].PropTypes.func]),

	  'aria-labelledby': _react2['default'].PropTypes.string,

	  messages: _react2['default'].PropTypes.shape({
	    calendarButton: _react2['default'].PropTypes.string,
	    timeButton: _react2['default'].PropTypes.string
	  })
	});

	var DateTimePicker = _react2['default'].createClass({

	  displayName: 'DateTimePicker',

	  mixins: [__webpack_require__(1437), __webpack_require__(1445), __webpack_require__(1446), __webpack_require__(1448), __webpack_require__(1453), __webpack_require__(1440)('valueInput', function (key, id) {
	    var open = this.props.open;
	    var current = this.ariaActiveDescendant();
	    var calIsActive = open === popups.CALENDAR && key === 'calendar';
	    var timeIsActive = open === popups.TIME && key === 'timelist';

	    if (!current || (timeIsActive || calIsActive)) return id;
	  })],

	  propTypes: propTypes,

	  getInitialState: function getInitialState() {
	    return {
	      focused: false
	    };
	  },

	  getDefaultProps: function getDefaultProps() {

	    return {
	      value: null,

	      min: new Date(1900, 0, 1),
	      max: new Date(2099, 11, 31),
	      calendar: true,
	      time: true,
	      open: false,

	      //calendar override
	      footer: true,

	      messages: {
	        calendarButton: 'Select Date',
	        timeButton: 'Select Time'
	      },

	      ariaActiveDescendantKey: 'dropdownlist'
	    };
	  },

	  render: function render() {
	    var _cx,
	        _this = this;

	    var _props = this.props;
	    var className = _props.className;
	    var calendar = _props.calendar;
	    var time = _props.time;
	    var open = _props.open;
	    var tabIndex = _props.tabIndex;
	    var value = _props.value;
	    var format = _props.format;
	    var editFormat = _props.editFormat;
	    var timeFormat = _props.timeFormat;
	    var culture = _props.culture;
	    var duration = _props.duration;
	    var step = _props.step;
	    var messages = _props.messages;
	    var min = _props.min;
	    var max = _props.max;
	    var busy = _props.busy;
	    var placeholder = _props.placeholder;
	    var disabled = _props.disabled;
	    var readOnly = _props.readOnly;
	    var name = _props.name;
	    var dropUp = _props.dropUp;
	    var timeComponent = _props.timeComponent;
	    var ariaLabelledby = _props['aria-labelledby'];
	    var focused = this.state.focused;

	    var inputID = this._id('_input'),
	        timeListID = this._id('_time_listbox'),
	        dateListID = this._id('_cal'),
	        owns = '';

	    var elementProps = omit(this.props, Object.keys(propTypes)),
	        calProps = pick(this.props, Object.keys(_utilCompat2['default'].type(Calendar).propTypes));

	    var shouldRenderList = _util_2['default'].isFirstFocusedRender(this) || open,
	        disabledOrReadonly = this.isDisabled() || this.isReadOnly(),
	        calendarIsOpen = open === popups.CALENDAR,
	        timeIsOpen = open === popups.TIME;

	    if (calendar) owns += dateListID;
	    if (time) owns += ' ' + timeListID;

	    value = dateOrNull(value);

	    return _react2['default'].createElement(
	      'div',
	      babelHelpers._extends({}, elementProps, {
	        ref: 'element',
	        tabIndex: '-1',
	        onKeyDown: this._maybeHandle(this._keyDown),
	        onFocus: this._maybeHandle(this._focus.bind(null, true), true),
	        onBlur: this._focus.bind(null, false),
	        className: (0, _classnames2['default'])(className, 'rw-datetimepicker', 'rw-widget', (_cx = {}, _cx['rw-state-focus'] = focused, _cx['rw-state-disabled'] = this.isDisabled(), _cx['rw-state-readonly'] = this.isReadOnly(), _cx['rw-has-both'] = calendar && time, _cx['rw-has-neither'] = !calendar && !time, _cx['rw-rtl'] = this.isRtl(), _cx['rw-open' + (dropUp ? '-up' : '')] = open, _cx))
	      }),
	      _react2['default'].createElement(_DateInput2['default'], {
	        ref: 'valueInput',
	        id: inputID,
	        tabIndex: tabIndex || 0,
	        role: 'combobox',
	        'aria-expanded': !!open,
	        'aria-busy': !!busy,
	        'aria-owns': owns.trim(),
	        'aria-haspopup': true,
	        placeholder: placeholder,
	        name: name,
	        disabled: this.isDisabled(),
	        readOnly: this.isReadOnly(),
	        value: value,
	        format: getFormat(this.props),
	        editFormat: editFormat,
	        editing: focused,
	        culture: culture,
	        parse: this._parse,
	        onChange: this._change
	      }),
	      (calendar || time) && _react2['default'].createElement(
	        'span',
	        { className: 'rw-select' },
	        calendar && _react2['default'].createElement(
	          _WidgetButton2['default'],
	          {
	            tabIndex: '-1',
	            className: 'rw-btn-calendar',
	            disabled: disabledOrReadonly,
	            'aria-disabled': disabledOrReadonly,
	            'aria-label': messages.calendarButton,
	            onClick: this._maybeHandle(this._click.bind(null, popups.CALENDAR))
	          },
	          _react2['default'].createElement('i', { className: 'rw-i rw-i-calendar',
	            'aria-hidden': 'true'
	          })
	        ),
	        time && _react2['default'].createElement(
	          _WidgetButton2['default'],
	          {
	            tabIndex: '-1',
	            className: 'rw-btn-time',
	            disabled: disabledOrReadonly,
	            'aria-disabled': disabledOrReadonly,
	            'aria-label': messages.timeButton,
	            onClick: this._maybeHandle(this._click.bind(null, popups.TIME))
	          },
	          _react2['default'].createElement('i', { className: 'rw-i rw-i-clock-o',
	            'aria-hidden': 'true'
	          })
	        )
	      ),
	      _react2['default'].createElement(
	        _Popup2['default'],
	        {
	          dropUp: dropUp,
	          open: timeIsOpen,
	          onRequestClose: this.close,
	          duration: duration,
	          onOpening: function () {
	            return _this.refs.timePopup.forceUpdate();
	          }
	        },
	        _react2['default'].createElement(
	          'div',
	          null,
	          shouldRenderList && _react2['default'].createElement(_TimeList2['default'], { ref: 'timePopup',
	            id: timeListID,
	            ariaActiveDescendantKey: 'timelist',
	            'aria-labelledby': inputID,
	            'aria-live': open && 'polite',
	            'aria-hidden': !open,
	            value: value,
	            format: timeFormat,
	            step: step,
	            min: min,
	            max: max,
	            culture: culture,
	            onMove: this._scrollTo,
	            preserveDate: !!calendar,
	            itemComponent: timeComponent,
	            onSelect: this._maybeHandle(this._selectTime)
	          })
	        )
	      ),
	      _react2['default'].createElement(
	        _Popup2['default'],
	        {
	          className: 'rw-calendar-popup',
	          dropUp: dropUp,
	          open: calendarIsOpen,
	          duration: duration,
	          onRequestClose: this.close
	        },
	        shouldRenderList && _react2['default'].createElement(Calendar, babelHelpers._extends({}, calProps, {
	          ref: 'calPopup',
	          tabIndex: '-1',
	          id: dateListID,
	          value: value,
	          'aria-hidden': !open,
	          'aria-live': 'polite',
	          ariaActiveDescendantKey: 'calendar',
	          onChange: this._maybeHandle(this._selectDate),

	          onNavigate: function () {
	            return _this.focus();
	          }
	        }))
	      )
	    );
	  },

	  _change: function _change(date, str, constrain) {
	    var _props2 = this.props;
	    var onChange = _props2.onChange;
	    var value = _props2.value;

	    if (constrain) date = this.inRangeValue(date);

	    if (onChange) {
	      if (date == null || value == null) {
	        if (date != value) //eslint-disable-line eqeqeq
	          onChange(date, str);
	      } else if (!_utilDates2['default'].eq(date, value)) onChange(date, str);
	    }
	  },

	  _keyDown: function _keyDown(e) {
	    var _props3 = this.props;
	    var open = _props3.open;
	    var calendar = _props3.calendar;
	    var time = _props3.time;

	    if (e.key === 'Escape' && open) this.close();else if (e.altKey) {
	      e.preventDefault();

	      if (e.key === 'ArrowDown') {
	        if (calendar && time) this.open(open === popups.CALENDAR ? popups.TIME : popups.CALENDAR);else if (time) this.open(popups.TIME);else if (calendar) this.open(popups.CALENDAR);
	      } else if (e.key === 'ArrowUp') this.close();
	    } else if (open) {
	      if (open === popups.CALENDAR) this.refs.calPopup._keyDown(e);
	      if (open === popups.TIME) this.refs.timePopup._keyDown(e);
	    }

	    this.notify('onKeyDown', [e]);
	  },

	  _focus: function _focus(focused, e) {
	    var _this2 = this;

	    this.setTimeout('focus', function () {
	      if (!focused) _this2.close();

	      if (focused !== _this2.state.focused) {
	        _this2.notify(focused ? 'onFocus' : 'onBlur', e);
	        _this2.setState({ focused: focused });
	      }
	    });
	  },

	  focus: function focus() {
	    if ((0, _reactLibGetActiveElement2['default'])() !== _utilCompat2['default'].findDOMNode(this.refs.valueInput)) this.refs.valueInput.focus();
	  },

	  _selectDate: function _selectDate(date) {
	    var format = getFormat(this.props),
	        dateTime = _utilDates2['default'].merge(date, this.props.value),
	        dateStr = formatDate(date, format, this.props.culture);

	    this.close();
	    this.notify('onSelect', [dateTime, dateStr]);
	    this._change(dateTime, dateStr, true);
	    this.focus();
	  },

	  _selectTime: function _selectTime(datum) {
	    var format = getFormat(this.props),
	        dateTime = _utilDates2['default'].merge(this.props.value, datum.date),
	        dateStr = formatDate(datum.date, format, this.props.culture);

	    this.close();
	    this.notify('onSelect', [dateTime, dateStr]);
	    this._change(dateTime, dateStr, true);
	    this.focus();
	  },

	  _click: function _click(view, e) {
	    this.focus();
	    this.toggle(view, e);
	  },

	  _parse: function _parse(string) {
	    var format = getFormat(this.props, true),
	        editFormat = this.props.editFormat,
	        parse = this.props.parse,
	        formats = [];

	    if (typeof parse === 'function') return parse(string, this.props.culture);

	    if (typeof format === 'string') formats.push(format);

	    if (typeof editFormat === 'string') formats.push(editFormat);

	    if (parse) formats = formats.concat(this.props.parse);

	    (0, _reactLibInvariant2['default'])(formats.length, 'React Widgets: there are no specified `parse` formats provided and the `format` prop is a function. ' + 'the DateTimePicker is unable to parse `%s` into a dateTime, ' + 'please provide either a parse function or Globalize.js compatible string for `format`', string);

	    return formatsParser(formats, this.props.culture, string);
	  },

	  toggle: function toggle(view) {
	    this.props.open ? this.props.open !== view ? this.open(view) : this.close(view) : this.open(view);
	  },

	  open: function open(view) {
	    if (this.props.open !== view && this.props[view] === true) this.notify('onToggle', view);
	  },

	  close: function close() {
	    if (this.props.open) this.notify('onToggle', false);
	  },

	  inRangeValue: function inRangeValue(value) {
	    if (value == null) return value;

	    return _utilDates2['default'].max(_utilDates2['default'].min(value, this.props.max), this.props.min);
	  }

	});

	var UncontrolledDateTimePicker = (0, _uncontrollable2['default'])(DateTimePicker, { open: 'onToggle', value: 'onChange' });

	UncontrolledDateTimePicker.BaseDateTimePicker = DateTimePicker;

	exports['default'] = UncontrolledDateTimePicker;

	function getFormat(props) {
	  var cal = props[popups.CALENDAR] != null ? props.calendar : true,
	      time = props[popups.TIME] != null ? props.time : true;

	  return props.format ? props.format : cal && time || !cal && !time ? localizers.date.formats['default'] : localizers.date.formats[cal ? 'date' : 'time'];
	}

	function formatDate(date, format, culture) {
	  var val = '';

	  if (date instanceof Date && !isNaN(date.getTime())) val = localizers.date.format(date, format, culture);

	  return val;
	}

	function formatsParser(formats, culture, str) {
	  var date;

	  for (var i = 0; i < formats.length; i++) {
	    date = localizers.date.parse(str, formats[i], culture);
	    if (date) return date;
	  }
	  return null;
	}

	function dateOrNull(dt) {
	  if (dt && !isNaN(dt.getTime())) return dt;
	  return null;
	}
	module.exports = exports['default'];
	// #75: need to aggressively reclaim focus from the calendar otherwise
	// disabled header/footer buttons will drop focus completely from the widget

/***/ },

/***/ 1472:
/***/ function(module, exports, __webpack_require__) {

	'use strict';

	var babelHelpers = __webpack_require__(1407);

	var React = __webpack_require__(103),
	    dates = __webpack_require__(1463),
	    List = __webpack_require__(1435),
	    localizers = __webpack_require__(1414).locale,
	    CustomPropTypes = __webpack_require__(1413);

	var format = function format(props) {
	  return props.format || localizers.date.formats.time;
	};

	module.exports = React.createClass({

	  displayName: 'TimeList',

	  propTypes: {
	    value: React.PropTypes.instanceOf(Date),
	    min: React.PropTypes.instanceOf(Date),
	    max: React.PropTypes.instanceOf(Date),
	    step: React.PropTypes.number,
	    itemComponent: CustomPropTypes.elementType,
	    format: CustomPropTypes.dateFormat,
	    onSelect: React.PropTypes.func,
	    preserveDate: React.PropTypes.bool,
	    culture: React.PropTypes.string
	  },

	  mixins: [__webpack_require__(1445)],

	  getDefaultProps: function getDefaultProps() {
	    return {
	      step: 30,
	      onSelect: function onSelect() {},
	      min: new Date(1900, 0, 1),
	      max: new Date(2099, 11, 31),
	      preserveDate: true,
	      delay: 300
	    };
	  },

	  getInitialState: function getInitialState() {
	    var data = this._dates(this.props),
	        focusedItem = this._closestDate(data, this.props.value);

	    return {
	      focusedItem: focusedItem || data[0],
	      dates: data
	    };
	  },

	  componentWillReceiveProps: function componentWillReceiveProps(nextProps) {
	    var data = this._dates(nextProps),
	        focusedItem = this._closestDate(data, nextProps.value),
	        valChanged = !dates.eq(nextProps.value, this.props.value, 'minutes'),
	        minChanged = !dates.eq(nextProps.min, this.props.min, 'minutes'),
	        maxChanged = !dates.eq(nextProps.max, this.props.max, 'minutes');

	    if (valChanged || minChanged || maxChanged) {
	      this.setState({
	        focusedItem: focusedItem || data[0],
	        dates: data
	      });
	    }
	  },

	  render: function render() {
	    var _props = this.props;
	    var min = _props.min;
	    var max = _props.max;
	    var value = _props.value;
	    var step = _props.step;
	    var props = babelHelpers.objectWithoutProperties(_props, ['min', 'max', 'value', 'step']);

	    var times = this.state.dates,
	        date = this._closestDate(times, value);

	    return React.createElement(List, babelHelpers._extends({}, props, {
	      ref: 'list',
	      data: times,
	      textField: 'label',
	      valueField: 'date',
	      selected: date,
	      focused: this.state.focusedItem
	    }));
	  },

	  _closestDate: function _closestDate(times, date) {
	    var roundTo = 1000 * 60 * this.props.step,
	        inst = null,
	        label;

	    if (!date) return null;

	    date = new Date(Math.floor(date.getTime() / roundTo) * roundTo);
	    label = dates.format(date, this.props.format, this.props.culture);

	    times.some(function (time) {
	      if (time.label === label) return inst = time;
	    });

	    return inst;
	  },

	  _data: function _data() {
	    return this.state.dates;
	  },

	  _dates: function _dates(props) {
	    var times = [],
	        i = 0,
	        values = this._dateValues(props),
	        start = values.min,
	        startDay = dates.date(start);

	    while (dates.date(start) === startDay && dates.lte(start, values.max)) {
	      i++;
	      times.push({ date: start, label: localizers.date.format(start, format(props), props.culture) });
	      start = dates.add(start, props.step || 30, 'minutes');
	    }
	    return times;
	  },

	  _dateValues: function _dateValues(props) {
	    var value = props.value || dates.today(),
	        useDate = props.preserveDate,
	        min = props.min,
	        max = props.max,
	        start,
	        end;

	    //compare just the time regradless of whether they fall on the same day
	    if (!useDate) {
	      start = dates.startOf(dates.merge(new Date(), min), 'minutes');
	      end = dates.startOf(dates.merge(new Date(), max), 'minutes');

	      if (dates.lte(end, start) && dates.gt(max, min, 'day')) end = dates.tomorrow();

	      return {
	        min: start,
	        max: end
	      };
	    }

	    start = dates.today();
	    end = dates.tomorrow();
	    //date parts are equal
	    return {
	      min: dates.eq(value, min, 'day') ? dates.merge(start, min) : start,
	      max: dates.eq(value, max, 'day') ? dates.merge(start, max) : end
	    };
	  },

	  _keyDown: function _keyDown(e) {
	    var _this = this;

	    var key = e.key,
	        character = String.fromCharCode(e.keyCode),
	        focusedItem = this.state.focusedItem,
	        list = this.refs.list;

	    if (key === 'End') this.setState({ focusedItem: list.last() });else if (key === 'Home') this.setState({ focusedItem: list.first() });else if (key === 'Enter') this.props.onSelect(focusedItem);else if (key === 'ArrowDown') {
	      e.preventDefault();
	      this.setState({ focusedItem: list.next(focusedItem) });
	    } else if (key === 'ArrowUp') {
	      e.preventDefault();
	      this.setState({ focusedItem: list.prev(focusedItem) });
	    } else {
	      e.preventDefault();

	      this.search(character, function (item) {
	        _this.setState({ focusedItem: item });
	      });
	    }
	  },

	  scrollTo: function scrollTo() {
	    this.refs.list.move && this.refs.list.move();
	  },

	  search: function search(character, cb) {
	    var _this2 = this;

	    var word = ((this._searchTerm || '') + character).toLowerCase();

	    this._searchTerm = word;

	    this.setTimeout('search', function () {
	      var list = _this2.refs.list,
	          item = list.next(_this2.state.focusedItem, word);

	      _this2._searchTerm = '';
	      if (item) cb(item);
	    }, this.props.delay);
	  }

	});

/***/ },

/***/ 1473:
/***/ function(module, exports, __webpack_require__) {

	'use strict';

	var babelHelpers = __webpack_require__(1407);

	var React = __webpack_require__(103),
	    cx = __webpack_require__(1411),
	    compat = __webpack_require__(1412),
	    localizers = __webpack_require__(1414).locale,
	    CustomPropTypes = __webpack_require__(1413);

	module.exports = React.createClass({

	  displayName: 'DatePickerInput',

	  propTypes: {
	    format: CustomPropTypes.dateFormat.isRequired,
	    editFormat: CustomPropTypes.dateFormat,
	    parse: React.PropTypes.func.isRequired,

	    value: React.PropTypes.instanceOf(Date),
	    onChange: React.PropTypes.func.isRequired,
	    culture: React.PropTypes.string
	  },

	  getDefaultProps: function getDefaultProps() {
	    return {
	      textValue: ''
	    };
	  },

	  componentWillReceiveProps: function componentWillReceiveProps(nextProps) {
	    var text = formatDate(nextProps.value, nextProps.editing && nextProps.editFormat ? nextProps.editFormat : nextProps.format, nextProps.culture);

	    this.startValue = text;

	    this.setState({
	      textValue: text
	    });
	  },

	  getInitialState: function getInitialState() {
	    var text = formatDate(this.props.value, this.props.editing && this.props.editFormat ? this.props.editFormat : this.props.format, this.props.culture);

	    this.startValue = text;

	    return {
	      textValue: text
	    };
	  },

	  render: function render() {
	    var value = this.state.textValue;

	    return React.createElement('input', babelHelpers._extends({}, this.props, {
	      type: 'text',
	      className: cx({ 'rw-input': true }),
	      value: value,
	      'aria-disabled': this.props.disabled,
	      'aria-readonly': this.props.readOnly,
	      disabled: this.props.disabled,
	      readOnly: this.props.readOnly,
	      onChange: this._change,
	      onBlur: chain(this.props.blur, this._blur, this) }));
	  },

	  _change: function _change(e) {
	    this.setState({ textValue: e.target.value });
	    this._needsFlush = true;
	  },

	  _blur: function _blur(e) {
	    var val = e.target.value,
	        date;

	    if (this._needsFlush) {
	      this._needsFlush = false;
	      date = this.props.parse(val);

	      this.props.onChange(date, formatDate(date, this.props.format, this.props.culture));
	    }
	  },

	  focus: function focus() {
	    compat.findDOMNode(this).focus();
	  }

	});

	function isValid(d) {
	  return !isNaN(d.getTime());
	}

	function formatDate(date, format, culture) {
	  var val = '';

	  if (date instanceof Date && isValid(date)) val = localizers.date.format(date, format, culture);

	  return val;
	}

	function chain(a, b, thisArg) {
	  return function () {
	    a && a.apply(thisArg, arguments);
	    b && b.apply(thisArg, arguments);
	  };
	}

/***/ },

/***/ 1474:
/***/ function(module, exports, __webpack_require__) {

	'use strict';

	var babelHelpers = __webpack_require__(1407);

	var React = __webpack_require__(103),
	    cx = __webpack_require__(1411),
	    _ = __webpack_require__(1408) //omit
	,
	    compat = __webpack_require__(1412),
	    CustomPropTypes = __webpack_require__(1413),
	    createUncontrolledWidget = __webpack_require__(1443),
	    directions = __webpack_require__(1464).directions,
	    repeater = __webpack_require__(1475),
	    localizers = __webpack_require__(1414).locale,
	    Input = __webpack_require__(1476);

	var Btn = __webpack_require__(1455);

	var format = function format(props) {
	  return props.format || localizers.number.formats['default'];
	};

	var propTypes = {

	  // -- controlled props -----------
	  value: React.PropTypes.number,
	  onChange: React.PropTypes.func,
	  //------------------------------------

	  min: React.PropTypes.number,
	  max: React.PropTypes.number,
	  step: React.PropTypes.number,

	  precision: React.PropTypes.number,

	  culture: React.PropTypes.string,

	  format: CustomPropTypes.numberFormat,

	  name: React.PropTypes.string,

	  parse: React.PropTypes.func,

	  disabled: React.PropTypes.oneOfType([React.PropTypes.bool, React.PropTypes.oneOf(['disabled'])]),

	  readOnly: React.PropTypes.oneOfType([React.PropTypes.bool, React.PropTypes.oneOf(['readOnly'])]),

	  messages: React.PropTypes.shape({
	    increment: React.PropTypes.string,
	    decrement: React.PropTypes.string
	  })
	};

	var NumberPicker = React.createClass({

	  displayName: 'NumberPicker',

	  mixins: [__webpack_require__(1437), __webpack_require__(1445), __webpack_require__(1446), __webpack_require__(1453)],

	  propTypes: propTypes,

	  getDefaultProps: function getDefaultProps() {
	    return {
	      value: null,
	      open: false,

	      min: -Infinity,
	      max: Infinity,
	      step: 1,

	      messages: {
	        increment: 'increment value',
	        decrement: 'decrement value'
	      }
	    };
	  },

	  getInitialState: function getInitialState() {
	    return {
	      focused: false,
	      active: false
	    };
	  },

	  render: function render() {
	    var _$omit = _.omit(this.props, Object.keys(propTypes));

	    var className = _$omit.className;
	    var onKeyDown = _$omit.onKeyDown;
	    var onKeyPress = _$omit.onKeyPress;
	    var onKeyUp = _$omit.onKeyUp;
	    var props = babelHelpers.objectWithoutProperties(_$omit, ['className', 'onKeyDown', 'onKeyPress', 'onKeyUp']);
	    var val = this.constrainValue(this.props.value);

	    return React.createElement(
	      'div',
	      babelHelpers._extends({}, props, {
	        ref: 'element',
	        onKeyDown: this._keyDown,
	        onFocus: this._focus.bind(null, true),
	        onBlur: this._focus.bind(null, false),
	        tabIndex: '-1',
	        className: cx(className, 'rw-numberpicker', 'rw-widget', {
	          'rw-state-focus': this.state.focused,
	          'rw-state-disabled': this.props.disabled,
	          'rw-state-readonly': this.props.readOnly,
	          'rw-rtl': this.isRtl()
	        }) }),
	      React.createElement(
	        'span',
	        { className: 'rw-select' },
	        React.createElement(
	          Btn,
	          {
	            tabIndex: '-1',
	            className: cx({ 'rw-state-active': this.state.active === directions.UP }),
	            onMouseDown: this._mouseDown.bind(null, directions.UP),
	            onMouseUp: this._mouseUp.bind(null, directions.UP),
	            onClick: this._focus.bind(null, true),
	            disabled: val === this.props.max || this.props.disabled,
	            'aria-disabled': val === this.props.max || this.props.disabled },
	          React.createElement(
	            'i',
	            { className: 'rw-i rw-i-caret-up' },
	            React.createElement(
	              'span',
	              { className: 'rw-sr' },
	              this.props.messages.increment
	            )
	          )
	        ),
	        React.createElement(
	          Btn,
	          {
	            tabIndex: '-1',
	            className: cx({ 'rw-state-active': this.state.active === directions.DOWN }),
	            onMouseDown: this._mouseDown.bind(null, directions.DOWN),
	            onMouseUp: this._mouseUp.bind(null, directions.DOWN),
	            onClick: this._focus.bind(null, true),
	            disabled: val === this.props.min || this.props.disabled,
	            'aria-disabled': val === this.props.min || this.props.disabled },
	          React.createElement(
	            'i',
	            { className: 'rw-i rw-i-caret-down' },
	            React.createElement(
	              'span',
	              { className: 'rw-sr' },
	              this.props.messages.decrement
	            )
	          )
	        )
	      ),
	      React.createElement(Input, {
	        ref: 'input',
	        tabIndex: props.tabIndex,
	        value: val,
	        editing: this.state.focused,
	        format: this.props.format,
	        parse: this.props.parse,
	        name: this.props.name,
	        role: 'spinbutton',
	        min: this.props.min,
	        'aria-valuenow': val,
	        'aria-valuemin': isFinite(this.props.min) ? this.props.min : null,
	        'aria-valuemax': isFinite(this.props.max) ? this.props.max : null,
	        'aria-disabled': this.props.disabled,
	        'aria-readonly': this.props.readonly,
	        disabled: this.props.disabled,
	        readOnly: this.props.readOnly,
	        onChange: this.change,
	        onKeyDown: onKeyDown,
	        onKeyPress: onKeyPress,
	        onKeyUp: onKeyUp })
	    );
	  },

	  //allow for styling, focus stealing keeping me from the normal what have you
	  _mouseDown: _.ifNotDisabled(function (dir) {
	    var method = dir === directions.UP ? this.increment : this.decrement;

	    this.setState({ active: dir });

	    var val = method.call(this);

	    if (!(dir === directions.UP && val === this.props.max || dir === directions.DOWN && val === this.props.min)) {
	      if (!this._cancelRepeater) this._cancelRepeater = repeater(this._mouseDown.bind(null, dir));
	    } else this._mouseUp();
	  }),

	  _mouseUp: _.ifNotDisabled(function () {
	    this.setState({ active: false });
	    this._cancelRepeater && this._cancelRepeater();
	    this._cancelRepeater = null;
	  }),

	  _focus: _.ifNotDisabled(true, function (focused, e) {
	    var _this = this;

	    focused && compat.findDOMNode(this.refs.input).focus();

	    this.setTimeout('focus', function () {
	      if (focused !== _this.state.focused) {
	        _this.notify(focused ? 'onFocus' : 'onBlur', e);
	        _this.setState({ focused: focused });
	      }
	    }, 0);
	  }),

	  _keyDown: _.ifNotDisabled(function (e) {
	    var key = e.key;

	    if (key === 'End' && isFinite(this.props.max)) this.change(this.props.max);else if (key === 'Home' && isFinite(this.props.min)) this.change(this.props.min);else if (key === 'ArrowDown') {
	      e.preventDefault();
	      this.decrement();
	    } else if (key === 'ArrowUp') {
	      e.preventDefault();
	      this.increment();
	    }
	  }),

	  increment: function increment() {
	    return this.step(this.props.step);
	  },

	  decrement: function decrement() {
	    return this.step(-this.props.step);
	  },

	  step: function step(amount) {
	    var value = (this.props.value || 0) + amount;

	    var decimals = this.props.precision != null ? this.props.precision : localizers.number.precision(format(this.props));

	    this.change(decimals != null ? round(value, decimals) : value);

	    return value;
	  },

	  change: function change(val) {
	    val = this.constrainValue(val);

	    if (this.props.value !== val) this.notify('onChange', val);
	  },

	  constrainValue: function constrainValue(value) {
	    var max = this.props.max == null ? Infinity : this.props.max,
	        min = this.props.min == null ? -Infinity : this.props.min;

	    if (value == null || value === '') return null;

	    return Math.max(Math.min(value, max), min);
	  }

	});

	// thank you kendo ui core
	// https://github.com/telerik/kendo-ui-core/blob/master/src/kendo.core.js#L1036
	function round(value, precision) {
	  precision = precision || 0;

	  value = ('' + value).split('e');
	  value = Math.round(+(value[0] + 'e' + (value[1] ? +value[1] + precision : precision)));

	  value = ('' + value).split('e');
	  value = +(value[0] + 'e' + (value[1] ? +value[1] - precision : -precision));

	  return value.toFixed(precision);
	}

	module.exports = createUncontrolledWidget(NumberPicker, { value: 'onChange' });

	module.exports.BaseNumberPicker = NumberPicker;

/***/ },

/***/ 1475:
/***/ function(module, exports) {

	// my tests in ie11/chrome/FF indicate that keyDown repeats
	// at about 35ms+/- 5ms after an initial 500ms delay. callback fires on the leading edge
	"use strict";

	function Repeater(callback) {
	  var id,
	      cancel = function cancel() {
	    return clearInterval(id);
	  };

	  id = setInterval(function () {
	    cancel();
	    id = setInterval(callback, 35);
	    callback();
	  }, 500);

	  return cancel;
	}

	module.exports = Repeater;
	//fire after everything in case the user cancels on the first call

/***/ },

/***/ 1476:
/***/ function(module, exports, __webpack_require__) {

	'use strict';

	var babelHelpers = __webpack_require__(1407);

	var React = __webpack_require__(103),
	    CustomPropTypes = __webpack_require__(1413),
	    localizers = __webpack_require__(1414).locale;

	var format = function format(props) {
	  return props.format || localizers.number.formats['default'];
	};

	module.exports = React.createClass({

	  displayName: 'NumberPickerInput',

	  propTypes: {
	    value: React.PropTypes.number,

	    format: CustomPropTypes.numberFormat,
	    parse: React.PropTypes.func.isRequired,
	    culture: React.PropTypes.string,

	    min: React.PropTypes.number,

	    onChange: React.PropTypes.func.isRequired,
	    onKeyDown: React.PropTypes.func
	  },

	  getDefaultProps: function getDefaultProps() {
	    return {
	      value: null,
	      editing: false,
	      parse: function parse(number, culture) {
	        return localizers.number.parse(number, culture);
	      }
	    };
	  },

	  getDefaultState: function getDefaultState(props) {
	    var value = props.editing ? props.value : formatNumber(props.value, format(props), props.culture);

	    if (value == null || isNaN(props.value)) value = '';

	    return {
	      stringValue: '' + value
	    };
	  },

	  getInitialState: function getInitialState() {
	    return this.getDefaultState(this.props);
	  },

	  componentWillReceiveProps: function componentWillReceiveProps(nextProps) {
	    this.setState(this.getDefaultState(nextProps));
	  },

	  render: function render() {
	    var value = this.state.stringValue;

	    return React.createElement('input', babelHelpers._extends({}, this.props, {
	      type: 'text',
	      className: 'rw-input',
	      onChange: this._change,
	      onBlur: this._finish,
	      'aria-disabled': this.props.disabled,
	      'aria-readonly': this.props.readOnly,
	      disabled: this.props.disabled,
	      readOnly: this.props.readOnly,
	      value: value }));
	  },

	  _change: function _change(e) {
	    var val = e.target.value,
	        number = this.props.parse(e.target.value, this.props.culture),
	        valid = this.isValid(number);

	    if (val == null || val.trim() === '') return this.props.onChange(null);

	    if (valid && number !== this.props.value && !this.isAtDelimiter(number, val)) return this.props.onChange(number);

	    //console.log(val !== 0 && !val)
	    if (!isNaN(number) || this.isAtDelimiter(number, val)) this.current(e.target.value);
	  },

	  _finish: function _finish() {
	    var str = this.state.stringValue,
	        number = this.props.parse(str, this.props.culture);

	    // if number is below the min
	    // we need to flush low values and decimal stops, onBlur means i'm done inputing
	    if (!isNaN(number) && (number < this.props.min || this.isAtDelimiter(number, str))) {
	      this.props.onChange(number);
	    }
	  },

	  isAtDelimiter: function isAtDelimiter(num, str) {
	    var next;

	    if (str.length <= 1) return false;

	    next = this.props.parse(str.substr(0, str.length - 1), this.props.culture);

	    return typeof next === 'number' && !isNaN(next) && next === num;
	  },

	  isValid: function isValid(num) {
	    if (typeof num !== 'number' || isNaN(num)) return false;
	    return num >= this.props.min;
	  },

	  //this intermediate state is for when one runs into the decimal or are typing the number
	  current: function current(val) {
	    this.setState({ stringValue: val });
	  }

	});

	// function parseLocaleFloat(number, parser, culture) {
	//   if ( typeof format === 'function')
	//     return format(number, culture)

	//   return config.globalize.parseFloat(number, 10, culture)
	// }

	function formatNumber(number, format, culture) {
	  return localizers.number.format(number, format, culture);
	}

/***/ },

/***/ 1477:
/***/ function(module, exports, __webpack_require__) {

	'use strict';

	var babelHelpers = __webpack_require__(1407);

	var React = __webpack_require__(103),
	    cx = __webpack_require__(1411),
	    _ = __webpack_require__(1408),
	    support = __webpack_require__(1478),
	    compat = __webpack_require__(1412),
	    SelectInput = __webpack_require__(1479),
	    TagList = __webpack_require__(1480),
	    Popup = __webpack_require__(1431),
	    PlainList = __webpack_require__(1435),
	    GroupableList = __webpack_require__(1441),
	    validateList = __webpack_require__(1442),
	    createUncontrolledWidget = __webpack_require__(1443),
	    CustomPropTypes = __webpack_require__(1413);

	var compatCreate = function compatCreate(props, msgs) {
	  return typeof msgs.createNew === 'function' ? msgs.createNew(props) : [React.createElement(
	    'strong',
	    null,
	    '"' + props.searchTerm + '"'
	  ), ' ' + msgs.createNew];
	};

	var omit = _.omit;
	var pick = _.pick;
	var result = _.result;
	var splat = _.splat;

	var propTypes = {
	  data: React.PropTypes.array,
	  //-- controlled props --
	  value: React.PropTypes.array,
	  onChange: React.PropTypes.func,

	  searchTerm: React.PropTypes.string,
	  onSearch: React.PropTypes.func,

	  open: React.PropTypes.bool,
	  onToggle: React.PropTypes.func,
	  //-------------------------------------------

	  valueField: React.PropTypes.string,
	  textField: CustomPropTypes.accessor,

	  tagComponent: CustomPropTypes.elementType,
	  itemComponent: CustomPropTypes.elementType,
	  listComponent: CustomPropTypes.elementType,

	  groupComponent: CustomPropTypes.elementType,
	  groupBy: CustomPropTypes.accessor,

	  createComponent: CustomPropTypes.elementType,

	  onSelect: React.PropTypes.func,
	  onCreate: React.PropTypes.oneOfType([React.PropTypes.oneOf([false]), React.PropTypes.func]),

	  dropUp: React.PropTypes.bool,
	  duration: React.PropTypes.number, //popup

	  placeholder: React.PropTypes.string,

	  disabled: React.PropTypes.oneOfType([React.PropTypes.bool, React.PropTypes.array, React.PropTypes.oneOf(['disabled'])]),

	  readOnly: React.PropTypes.oneOfType([React.PropTypes.bool, React.PropTypes.array, React.PropTypes.oneOf(['readonly'])]),

	  messages: React.PropTypes.shape({
	    open: CustomPropTypes.message,
	    emptyList: CustomPropTypes.message,
	    emptyFilter: CustomPropTypes.message,
	    createNew: CustomPropTypes.message
	  })
	};

	var Multiselect = React.createClass({

	  displayName: 'Multiselect',

	  mixins: [__webpack_require__(1437), __webpack_require__(1445), __webpack_require__(1447), __webpack_require__(1438), __webpack_require__(1448), __webpack_require__(1453), __webpack_require__(1440)('input', function (key, id) {
	    var myKey = this.props.ariaActiveDescendantKey;

	    var createIsActive = (!this._data().length || this.state.focusedItem === null) && key === myKey;

	    var tagIsActive = this.state.focusedTag != null && key === 'taglist';
	    var listIsActive = this.state.focusedTag == null && key === 'list';

	    if (createIsActive || tagIsActive || listIsActive) return id;
	  })],

	  propTypes: propTypes,

	  getDefaultProps: function getDefaultProps() {
	    return {
	      data: [],
	      filter: 'startsWith',
	      value: [],
	      open: false,
	      searchTerm: '',
	      ariaActiveDescendantKey: 'multiselect',
	      messages: {
	        createNew: '(create new tag)',
	        emptyList: 'There are no items in this list',
	        emptyFilter: 'The filter returned no results',
	        tagsLabel: 'selected items',
	        selectedItems: 'selected items',
	        noneSelected: 'no selected items',
	        removeLabel: 'remove selected item'
	      }
	    };
	  },

	  getInitialState: function getInitialState() {
	    var _this = this;

	    var dataItems = splat(this.props.value).map(function (item) {
	      return _this._dataItem(_this.props.data, item);
	    }),
	        data = this.process(this.props.data, dataItems, this.props.searchTerm);

	    return {
	      focusedTag: null,
	      focusedItem: data[0],
	      processedData: data,
	      dataItems: dataItems
	    };
	  },

	  componentDidUpdate: function componentDidUpdate() {
	    this.ariaActiveDescendant(this._id('__createlist_option'));

	    this.refs.list && validateList(this.refs.list);
	  },

	  componentDidMount: function componentDidMount() {
	    // https://github.com/facebook/react/issues/1169
	    if (support.ios) compat.findDOMNode(this.refs.wrapper).onClick = function () {};
	  },

	  componentWillReceiveProps: function componentWillReceiveProps(nextProps) {
	    var _this2 = this;

	    var values = _.splat(nextProps.value),
	        current = this.state.focusedItem,
	        items = this.process(nextProps.data, values, nextProps.searchTerm);

	    this.setState({
	      processedData: items,
	      focusedItem: items.indexOf(current) === -1 ? items[0] : current,
	      dataItems: values.map(function (item) {
	        return _this2._dataItem(nextProps.data, item);
	      })
	    });
	  },

	  render: function render() {
	    var _cx,
	        _this3 = this;

	    var _props = this.props;
	    var searchTerm = _props.searchTerm;
	    var maxLength = _props.maxLength;
	    var className = _props.className;
	    var children = _props.children;
	    var tabIndex = _props.tabIndex;
	    var groupBy = _props.groupBy;
	    var messages = _props.messages;
	    var data = _props.data;
	    var busy = _props.busy;
	    var dropUp = _props.dropUp;
	    var placeholder = _props.placeholder;
	    var value = _props.value;
	    var open = _props.open;
	    var disabled = _props.disabled;
	    var readOnly = _props.readOnly;
	    var TagComponent = _props.tagComponent;
	    var List = _props.listComponent;

	    List = List || groupBy && GroupableList || PlainList;

	    messages = msgs(messages);

	    var elementProps = omit(this.props, Object.keys(propTypes));
	    var tagsProps = pick(this.props, ['valueField', 'textField']);
	    var inputProps = pick(this.props, ['maxLength', 'searchTerm']);
	    var listProps = pick(this.props, Object.keys(compat.type(List).propTypes));
	    var popupProps = pick(this.props, Object.keys(compat.type(Popup).propTypes));

	    var _state = this.state;
	    var focusedTag = _state.focusedTag;
	    var focusedItem = _state.focusedItem;
	    var selectedItem = _state.selectedItem;
	    var focused = _state.focused;
	    var dataItems = _state.dataItems;

	    var items = this._data(),
	        tagsID = this._id('_taglist'),
	        listID = this._id('__listbox'),
	        createID = this._id('__createlist'),
	        createOptionID = this._id('__createlist_option');

	    var shouldRenderTags = !!dataItems.length,
	        shouldRenderPopup = _.isFirstFocusedRender(this) || open,
	        shouldShowCreate = this._shouldShowCreate(),
	        createIsFocused = !items.length || focusedItem === null;

	    if (focused) {
	      var notify = dataItems.length ? messages.selectedItems + ': ' + dataItems.map(this._dataText).join(', ') : messages.noneSelected;
	    }

	    return React.createElement(
	      'div',
	      babelHelpers._extends({}, elementProps, {
	        ref: 'element',
	        id: this._id(),
	        onKeyDown: this._maybeHandle(this._keyDown),
	        onFocus: this._maybeHandle(this._focus.bind(null, true), true),
	        onBlur: this._focus.bind(null, false),
	        tabIndex: '-1',
	        className: cx(className, 'rw-widget', 'rw-multiselect', (_cx = {}, _cx['rw-state-focus'] = focused, _cx['rw-state-disabled'] = disabled === true, _cx['rw-state-readonly'] = readOnly === true, _cx['rw-rtl'] = this.isRtl(), _cx['rw-open' + (dropUp ? '-up' : '')] = open, _cx)) }),
	      React.createElement(
	        'span',
	        {
	          ref: 'status',
	          id: this._id('__notify'),
	          role: 'status',
	          className: 'sr-only',
	          'aria-live': 'assertive',
	          'aria-atomic': 'true',
	          'aria-relevant': 'additions removals text'
	        },
	        notify
	      ),
	      React.createElement(
	        'div',
	        { className: 'rw-multiselect-wrapper', ref: 'wrapper' },
	        busy && React.createElement('i', { className: 'rw-i rw-loading' }),
	        shouldRenderTags && React.createElement(TagList, babelHelpers._extends({}, tagsProps, {
	          ref: 'tagList',
	          id: tagsID,
	          'aria-label': messages.tagsLabel,
	          value: dataItems,
	          focused: focusedTag,
	          disabled: disabled,
	          readOnly: readOnly,
	          onDelete: this._delete,
	          valueComponent: TagComponent,
	          ariaActiveDescendantKey: 'taglist'
	        })),
	        React.createElement(SelectInput, babelHelpers._extends({}, inputProps, {
	          ref: 'input',
	          tabIndex: tabIndex || 0,
	          role: 'listbox',
	          'aria-expanded': open,
	          'aria-busy': !!busy,
	          'aria-owns': listID + ' ' + this._id('__notify') + (shouldRenderTags ? ' ' + tagsID : '') + (shouldShowCreate ? ' ' + createID : ''),
	          'aria-haspopup': true,
	          value: searchTerm,
	          maxLength: maxLength,
	          disabled: disabled === true,
	          readOnly: readOnly === true,
	          placeholder: this._placeholder(),
	          onKeyDown: this._searchKeyDown,
	          onKeyUp: this._searchgKeyUp,
	          onChange: this._typing,
	          onFocus: this._inputFocus,
	          onClick: this._inputFocus
	        }))
	      ),
	      React.createElement(
	        Popup,
	        babelHelpers._extends({}, popupProps, {
	          onOpening: function () {
	            return _this3.refs.list.forceUpdate();
	          },
	          onRequestClose: this.close
	        }),
	        React.createElement(
	          'div',
	          null,
	          shouldRenderPopup && [React.createElement(List, babelHelpers._extends({ ref: 'list',
	            key: '0'
	          }, listProps, {
	            readOnly: !!readOnly,
	            disabled: !!disabled,
	            id: listID,
	            'aria-live': 'polite',
	            'aria-labelledby': this._id(),
	            'aria-hidden': !open,
	            ariaActiveDescendantKey: 'list',
	            data: items,
	            focused: focusedItem,
	            onSelect: this._maybeHandle(this._onSelect),
	            onMove: this._scrollTo,
	            messages: {
	              emptyList: data.length ? messages.emptyFilter : messages.emptyList
	            }
	          })), shouldShowCreate && React.createElement(
	            'ul',
	            { role: 'listbox', id: createID, className: 'rw-list rw-multiselect-create-tag', key: '1' },
	            React.createElement(
	              'li',
	              { onClick: this._onCreate.bind(null, searchTerm),
	                role: 'option',
	                id: createOptionID,
	                className: cx({
	                  'rw-list-option': true,
	                  'rw-state-focus': createIsFocused
	                }) },
	              compatCreate(this.props, messages)
	            )
	          )]
	        )
	      )
	    );
	  },

	  _data: function _data() {
	    return this.state.processedData;
	  },

	  _delete: function _delete(value) {
	    this._focus(true);
	    this.change(this.state.dataItems.filter(function (d) {
	      return d !== value;
	    }));
	  },

	  _inputFocus: function _inputFocus() {
	    this._focus(true);
	    !this.props.open && this.open();
	  },

	  _focus: function _focus(focused, e) {
	    var _this4 = this;

	    if (this.props.disabled === true) return;

	    if (focused) this.refs.input.focus();

	    this.setTimeout('focus', function () {
	      if (!focused) _this4.refs.tagList && _this4.setState({ focusedTag: null });

	      if (focused !== _this4.state.focused) {
	        focused ? _this4.open() : _this4.close();

	        _this4.notify(focused ? 'onFocus' : 'onBlur', e);
	        _this4.setState({ focused: focused });
	      }
	    });
	  },

	  _searchKeyDown: function _searchKeyDown(e) {
	    if (e.key === 'Backspace' && e.target.value && !this._deletingText) this._deletingText = true;
	  },

	  _searchgKeyUp: function _searchgKeyUp(e) {
	    if (e.key === 'Backspace' && this._deletingText) this._deletingText = false;
	  },

	  _typing: function _typing(e) {
	    this.notify('onSearch', [e.target.value]);
	    this.open();
	  },

	  _onSelect: function _onSelect(data) {

	    if (data === undefined) {
	      if (this.props.onCreate) this._onCreate(this.props.searchTerm);

	      return;
	    }

	    this.notify('onSelect', data);
	    this.change(this.state.dataItems.concat(data));

	    this.close();
	    this._focus(true);
	  },

	  _onCreate: function _onCreate(tag) {
	    if (tag.trim() === '') return;

	    this.notify('onCreate', tag);
	    this.props.searchTerm && this.notify('onSearch', ['']);

	    this.close();
	    this._focus(true);
	  },

	  _keyDown: function _keyDown(e) {
	    var key = e.key;
	    var altKey = e.altKey;
	    var ctrlKey = e.ctrlKey;
	    var noSearch = !this.props.searchTerm && !this._deletingText;
	    var isOpen = this.props.open;var _state2 = this.state;
	    var focusedTag = _state2.focusedTag;
	    var focusedItem = _state2.focusedItem;
	    var _refs = this.refs;
	    var list = _refs.list;
	    var tagList = _refs.tagList;

	    var nullTag = { focusedTag: null };

	    if (key === 'ArrowDown') {
	      var next = list.next(focusedItem),
	          creating = this._shouldShowCreate() && focusedItem === next || focusedItem === null;

	      next = creating ? null : next;

	      e.preventDefault();
	      if (isOpen) this.setState(babelHelpers._extends({ focusedItem: next }, nullTag));else this.open();
	    } else if (key === 'ArrowUp') {
	      var prev = focusedItem === null ? list.last() : list.prev(focusedItem);

	      e.preventDefault();

	      if (altKey) this.close();else if (isOpen) this.setState(babelHelpers._extends({ focusedItem: prev }, nullTag));
	    } else if (key === 'End') {
	      if (isOpen) this.setState(babelHelpers._extends({ focusedItem: list.last() }, nullTag));else tagList && this.setState({ focusedTag: tagList.last() });
	    } else if (key === 'Home') {
	      if (isOpen) this.setState(babelHelpers._extends({ focusedItem: list.first() }, nullTag));else tagList && this.setState({ focusedTag: tagList.first() });
	    } else if (isOpen && key === 'Enter') ctrlKey && this.props.onCreate || focusedItem === null ? this._onCreate(this.props.searchTerm) : this._onSelect(this.state.focusedItem);else if (key === 'Escape') isOpen ? this.close() : tagList && this.setState(nullTag);else if (noSearch && key === 'ArrowLeft') tagList && this.setState({ focusedTag: tagList.prev(focusedTag) });else if (noSearch && key === 'ArrowRight') tagList && this.setState({ focusedTag: tagList.next(focusedTag) });else if (noSearch && key === 'Delete') tagList && tagList.remove(focusedTag);else if (noSearch && key === 'Backspace') tagList && tagList.removeNext();

	    this.notify('onKeyDown', [e]);
	  },

	  // _firstFocus(){
	  //   this.open()
	  // }

	  change: function change(data) {
	    this.notify('onChange', [data]);
	    this.props.searchTerm && this.notify('onSearch', ['']);
	  },

	  open: function open() {
	    if (!(this.props.disabled === true || this.props.readOnly === true)) this.notify('onToggle', true);
	  },

	  close: function close() {
	    this.notify('onToggle', false);
	  },

	  toggle: function toggle() {
	    this.props.open ? this.close() : this.open();
	  },

	  process: function process(data, values, searchTerm) {
	    var _this5 = this;

	    var items = data.filter(function (i) {
	      return !values.some(_this5._valueMatcher.bind(null, i), _this5);
	    }, this);

	    if (searchTerm) items = this.filter(items, searchTerm);

	    return items;
	  },

	  _shouldShowCreate: function _shouldShowCreate() {
	    var _this6 = this;

	    var text = this.props.searchTerm;

	    if (!this.props.onCreate || !text) return false;

	    // if there is an exact match on textFields: "john" => { name: "john" }, don't show
	    return !this._data().some(function (v) {
	      return _this6._dataText(v) === text;
	    }) && !this.state.dataItems.some(function (v) {
	      return _this6._dataText(v) === text;
	    });
	  },

	  _placeholder: function _placeholder() {
	    return (this.props.value || []).length ? '' : this.props.placeholder || '';
	  }

	});

	function msgs(msgs) {
	  return babelHelpers._extends({
	    createNew: '(create new tag)',
	    emptyList: 'There are no items in this list',
	    emptyFilter: 'The filter returned no results',
	    tagsLabel: 'selected items',
	    selectedItems: 'selected items',
	    removeLabel: 'remove selected item' }, msgs);
	}

	module.exports = createUncontrolledWidget(Multiselect, { open: 'onToggle', value: 'onChange', searchTerm: 'onSearch' });

	// function defaultChange(){
	//   if ( this.props.searchTerm === undefined )
	//     this.setState({ searchTerm: '' })
	// }

	module.exports.BaseMultiselect = Multiselect;

/***/ },

/***/ 1478:
/***/ function(module, exports) {

	'use strict';

	module.exports = {
	  ios: typeof navigator !== 'undefined' && navigator.userAgent.match(/(iPod|iPhone|iPad)/) && navigator.userAgent.match(/AppleWebKit/)
	};

/***/ },

/***/ 1479:
/***/ function(module, exports, __webpack_require__) {

	'use strict';

	var babelHelpers = __webpack_require__(1407);

	var React = __webpack_require__(103),
	    compat = __webpack_require__(1412);

	module.exports = React.createClass({

	  displayName: 'MultiselectInput',

	  propTypes: {
	    value: React.PropTypes.string,
	    maxLength: React.PropTypes.number,
	    onChange: React.PropTypes.func.isRequired,
	    onFocus: React.PropTypes.func,

	    disabled: React.PropTypes.bool,
	    readOnly: React.PropTypes.bool
	  },

	  componentDidUpdate: function componentDidUpdate() {
	    this.props.focused && this.focus();
	  },

	  render: function render() {
	    var value = this.props.value,
	        placeholder = this.props.placeholder,
	        size = Math.max((value || placeholder).length, 1) + 1;

	    return React.createElement('input', babelHelpers._extends({}, this.props, {
	      className: 'rw-input',
	      autoComplete: 'off',
	      'aria-disabled': this.props.disabled,
	      'aria-readonly': this.props.readOnly,
	      disabled: this.props.disabled,
	      readOnly: this.props.readOnly,
	      size: size
	    }));
	  },

	  focus: function focus() {
	    compat.findDOMNode(this).focus();
	  }

	});

/***/ },

/***/ 1480:
/***/ function(module, exports, __webpack_require__) {

	'use strict';

	var babelHelpers = __webpack_require__(1407);

	var _mixinsWidgetMixin = __webpack_require__(1437);

	var _mixinsWidgetMixin2 = babelHelpers.interopRequireDefault(_mixinsWidgetMixin);

	var React = __webpack_require__(103),
	    _ = __webpack_require__(1408),
	    cx = __webpack_require__(1411),
	    CustomPropTypes = __webpack_require__(1413);

	var optionId = function optionId(id, idx) {
	  return '' + id + '__option__' + idx;
	};

	module.exports = React.createClass({

	  displayName: 'MultiselectTagList',

	  mixins: [__webpack_require__(1438), __webpack_require__(1446), __webpack_require__(1440)()],

	  propTypes: {
	    value: React.PropTypes.array,
	    focused: React.PropTypes.number,

	    valueField: React.PropTypes.string,
	    textField: CustomPropTypes.accessor,

	    valueComponent: React.PropTypes.func,

	    disabled: React.PropTypes.oneOfType([React.PropTypes.bool, React.PropTypes.array, React.PropTypes.oneOf(['disabled'])]),

	    readOnly: React.PropTypes.oneOfType([React.PropTypes.bool, React.PropTypes.array, React.PropTypes.oneOf(['readonly'])])
	  },

	  getDefaultProps: function getDefaultProps() {
	    return {
	      ariaActiveDescendantKey: 'taglist'
	    };
	  },

	  componentDidUpdate: function componentDidUpdate() {
	    var _props = this.props;
	    var value = _props.value;
	    var focused = _props.focused;
	    var activeId = optionId(_mixinsWidgetMixin2['default']._id.call(this), focused);

	    this.ariaActiveDescendant(focused == null || this.isDisabled(focused) ? null : activeId);
	  },

	  render: function render() {
	    var _this = this;

	    var ValueComponent = this.props.valueComponent;
	    var props = _.omit(this.props, ['value', 'disabled', 'readOnly']);
	    var _props2 = this.props;
	    var focused = _props2.focused;
	    var optionID = _props2.optionID;
	    var value = _props2.value;

	    var id = _mixinsWidgetMixin2['default']._id.call(this);

	    return React.createElement(
	      'ul',
	      babelHelpers._extends({}, props, {
	        role: 'listbox',
	        tabIndex: '-1',
	        className: 'rw-multiselect-taglist'
	      }),
	      value.map(function (item, i) {
	        var isDisabled = _this.isDisabled(item),
	            isReadonly = _this.isReadOnly(item),
	            isFocused = !isDisabled && focused === i,
	            currentID = optionId(id, i);

	        return React.createElement(
	          'li',
	          {
	            key: i,
	            id: currentID,
	            tabIndex: '-1',
	            role: 'option',
	            className: cx({
	              'rw-state-focus': isFocused,
	              'rw-state-disabled': isDisabled,
	              'rw-state-readonly': isReadonly
	            })
	          },
	          ValueComponent ? React.createElement(ValueComponent, { item: item }) : _this._dataText(item),
	          React.createElement(
	            'span',
	            {
	              tabIndex: '-1',
	              onClick: !(isDisabled || isReadonly) && _this._delete.bind(null, item),
	              'aria-disabled': isDisabled,
	              'aria-label': 'Unselect',
	              disabled: isDisabled
	            },
	            React.createElement(
	              'span',
	              { className: 'rw-tag-btn', 'aria-hidden': 'true' },
	              '×'
	            )
	          )
	        );
	      })
	    );
	  },

	  _delete: function _delete(val) {
	    this.props.onDelete(val);
	  },

	  remove: function remove(idx) {
	    var val = this.props.value[idx];

	    if (val && !(this.isDisabled(val) || this.isReadOnly(val))) this.props.onDelete(val);
	  },

	  removeNext: function removeNext() {
	    var val = this.props.value[this.props.value.length - 1];

	    if (val && !(this.isDisabled(val) || this.isReadOnly(val))) this.props.onDelete(val);
	  },

	  isDisabled: function isDisabled(val, isIdx) {
	    if (isIdx) val = this.props.value[val];

	    return this.props.disabled === true || this._dataIndexOf(this.props.disabled || [], val) !== -1;
	  },

	  isReadOnly: function isReadOnly(val, isIdx) {
	    if (isIdx) val = this.props.value[val];

	    return this.props.readOnly === true || this._dataIndexOf(this.props.readOnly || [], val) !== -1;
	  },

	  clear: function clear() {
	    this.setState({ focused: null });
	  },

	  first: function first() {
	    var idx = 0,
	        l = this.props.value.length;

	    while (idx < l && this.isDisabled(idx, true)) idx++;

	    return idx !== l ? idx : null;
	  },

	  last: function last() {
	    var idx = this.props.value.length - 1;

	    while (idx > -1 && this.isDisabled(idx, true)) idx--;

	    return idx >= 0 ? idx : null;
	  },

	  next: function next(current) {
	    var nextIdx = current + 1,
	        l = this.props.value.length;

	    while (nextIdx < l && this.isDisabled(nextIdx, true)) nextIdx++;

	    if (current === null || nextIdx >= l) return null;

	    return nextIdx;
	  },

	  prev: function prev(current) {
	    var nextIdx = current;

	    if (nextIdx === null || nextIdx === 0) nextIdx = this.props.value.length;

	    nextIdx--;

	    while (nextIdx > -1 && this.isDisabled(nextIdx, true)) nextIdx--;

	    return nextIdx >= 0 ? nextIdx : null;
	  }
	});

/***/ },

/***/ 1481:
/***/ function(module, exports, __webpack_require__) {

	'use strict';

	var babelHelpers = __webpack_require__(1407);

	exports.__esModule = true;

	var _react = __webpack_require__(103);

	var _react2 = babelHelpers.interopRequireDefault(_react);

	var _util_ = __webpack_require__(1408);

	var _util_2 = babelHelpers.interopRequireDefault(_util_);

	var _classnames = __webpack_require__(1411);

	var _classnames2 = babelHelpers.interopRequireDefault(_classnames);

	var _uncontrollable = __webpack_require__(1443);

	var _uncontrollable2 = babelHelpers.interopRequireDefault(_uncontrollable);

	var _utilCompat = __webpack_require__(1412);

	var _utilCompat2 = babelHelpers.interopRequireDefault(_utilCompat);

	var _utilPropTypes = __webpack_require__(1413);

	var _utilPropTypes2 = babelHelpers.interopRequireDefault(_utilPropTypes);

	var _List = __webpack_require__(1435);

	var _List2 = babelHelpers.interopRequireDefault(_List);

	var _ListGroupable = __webpack_require__(1441);

	var _ListGroupable2 = babelHelpers.interopRequireDefault(_ListGroupable);

	var _utilValidateListInterface = __webpack_require__(1442);

	var _utilValidateListInterface2 = babelHelpers.interopRequireDefault(_utilValidateListInterface);

	var _domHelpersUtilScrollTo = __webpack_require__(1449);

	var _domHelpersUtilScrollTo2 = babelHelpers.interopRequireDefault(_domHelpersUtilScrollTo);

	var omit = _util_2['default'].omit;
	var pick = _util_2['default'].pick;
	var result = _util_2['default'].result;

	var propTypes = {

	  data: _react2['default'].PropTypes.array,
	  value: _react2['default'].PropTypes.oneOfType([_react2['default'].PropTypes.any, _react2['default'].PropTypes.array]),
	  onChange: _react2['default'].PropTypes.func,
	  onMove: _react2['default'].PropTypes.func,

	  multiple: _react2['default'].PropTypes.bool,

	  itemComponent: _utilPropTypes2['default'].elementType,
	  listComponent: _utilPropTypes2['default'].elementType,

	  valueField: _react2['default'].PropTypes.string,
	  textField: _utilPropTypes2['default'].accessor,

	  busy: _react2['default'].PropTypes.bool,

	  filter: _react2['default'].PropTypes.string,
	  delay: _react2['default'].PropTypes.number,

	  disabled: _react2['default'].PropTypes.oneOfType([_react2['default'].PropTypes.array, _react2['default'].PropTypes.bool, _react2['default'].PropTypes.oneOf(['disabled'])]),

	  readOnly: _react2['default'].PropTypes.oneOfType([_react2['default'].PropTypes.bool, _react2['default'].PropTypes.array, _react2['default'].PropTypes.oneOf(['readonly'])]),

	  messages: _react2['default'].PropTypes.shape({
	    emptyList: _react2['default'].PropTypes.string
	  })
	};

	var SelectList = _react2['default'].createClass({
	  displayName: 'SelectList',

	  propTypes: propTypes,

	  mixins: [__webpack_require__(1437), __webpack_require__(1445), __webpack_require__(1438), __webpack_require__(1453), __webpack_require__(1440)()],

	  getDefaultProps: function getDefaultProps() {
	    return {
	      delay: 250,
	      value: [],
	      data: [],
	      ariaActiveDescendantKey: 'selectlist',
	      messages: {
	        emptyList: 'There are no items in this list'
	      }
	    };
	  },

	  getDefaultState: function getDefaultState(props) {
	    var _this = this;

	    var isRadio = !props.multiple,
	        values = _util_2['default'].splat(props.value),
	        first = isRadio && this._dataItem(props.data, values[0]);

	    first = isRadio && first ? first : (this.state || {}).focusedItem || null;

	    return {
	      focusedItem: first,
	      dataItems: !isRadio && values.map(function (item) {
	        return _this._dataItem(props.data, item);
	      })
	    };
	  },

	  getInitialState: function getInitialState() {
	    var state = this.getDefaultState(this.props);

	    state.ListItem = getListItem(this);

	    return state;
	  },

	  componentWillReceiveProps: function componentWillReceiveProps(nextProps) {
	    return this.setState(this.getDefaultState(nextProps));
	  },

	  componentDidMount: function componentDidMount() {
	    (0, _utilValidateListInterface2['default'])(this.refs.list);
	  },

	  render: function render() {
	    var _props = this.props;
	    var className = _props.className;
	    var tabIndex = _props.tabIndex;
	    var filter = _props.filter;
	    var suggest = _props.suggest;
	    var groupBy = _props.groupBy;
	    var messages = _props.messages;
	    var data = _props.data;
	    var busy = _props.busy;
	    var dropUp = _props.dropUp;
	    var name = _props.name;
	    var placeholder = _props.placeholder;
	    var value = _props.value;
	    var open = _props.open;
	    var disabled = _props.disabled;
	    var readOnly = _props.readOnly;
	    var List = _props.listComponent;

	    List = List || groupBy && _ListGroupable2['default'] || _List2['default'];

	    var elementProps = omit(this.props, Object.keys(propTypes));
	    var listProps = pick(this.props, Object.keys(_utilCompat2['default'].type(List).propTypes));

	    var _state = this.state;
	    var ListItem = _state.ListItem;
	    var focusedItem = _state.focusedItem;
	    var selectedItem = _state.selectedItem;
	    var focused = _state.focused;

	    var items = this._data(),
	        listID = this._id('_listbox');

	    focusedItem = focused && !this.isDisabled() && !this.isReadOnly() && focusedItem;

	    return _react2['default'].createElement(
	      'div',
	      babelHelpers._extends({}, elementProps, {
	        onKeyDown: this._maybeHandle(this._keyDown),
	        onFocus: this._focus.bind(null, true),
	        onBlur: this._focus.bind(null, false),
	        role: 'radiogroup',
	        'aria-busy': !!busy,
	        'aria-disabled': this.isDisabled(),
	        'aria-readonly': this.isReadOnly(),
	        tabIndex: '-1',
	        className: (0, _classnames2['default'])(className, 'rw-widget', 'rw-selectlist', {
	          'rw-state-focus': focused,
	          'rw-state-disabled': this.isDisabled(),
	          'rw-state-readonly': this.isReadOnly(),
	          'rw-rtl': this.isRtl(),
	          'rw-loading-mask': busy
	        })
	      }),
	      _react2['default'].createElement(List, babelHelpers._extends({}, listProps, {
	        ref: 'list',
	        id: listID,
	        role: 'radiogroup',
	        tabIndex: tabIndex || '0',
	        data: items,
	        focused: focusedItem,
	        optionComponent: ListItem,
	        itemComponent: this.props.itemComponent,
	        onMove: this._scrollTo
	      }))
	    );
	  },

	  _scrollTo: function _scrollTo(selected, list) {
	    var handler = this.props.onMove;

	    if (handler) handler(selected, list);else {
	      this._scrollCancel && this._scrollCancel();
	      // default behavior is to scroll the whole page not just the widget
	      this._scrollCancel = (0, _domHelpersUtilScrollTo2['default'])(selected);
	    }
	  },

	  _keyDown: function _keyDown(e) {
	    var self = this,
	        key = e.key,
	        multiple = !!this.props.multiple,
	        list = this.refs.list,
	        focusedItem = this.state.focusedItem;

	    if (key === 'End') {
	      e.preventDefault();

	      if (multiple) this.setState({ focusedItem: move('prev', null) });else change(move('prev', null));
	    } else if (key === 'Home') {
	      e.preventDefault();

	      if (multiple) this.setState({ focusedItem: move('next', null) });else change(move('next', null));
	    } else if (key === 'Enter' || key === ' ') {
	      e.preventDefault();
	      change(focusedItem);
	    } else if (key === 'ArrowDown' || key === 'ArrowRight') {
	      e.preventDefault();

	      if (multiple) this.setState({ focusedItem: move('next', focusedItem) });else change(move('next', focusedItem));
	    } else if (key === 'ArrowUp' || key === 'ArrowLeft') {
	      e.preventDefault();

	      if (multiple) this.setState({ focusedItem: move('prev', focusedItem) });else change(move('prev', focusedItem));
	    } else if (this.props.multiple && e.keyCode === 65 && e.ctrlKey) {
	      e.preventDefault();
	      this._selectAll();
	    } else this.search(String.fromCharCode(e.keyCode));

	    function change(item) {
	      if (item) {
	        self._change(item, multiple ? !self._contains(item, self._values()) // toggle value
	        : true);
	      }
	    }

	    function move(dir, item) {
	      var isDisabled = function isDisabled(item) {
	        return self.isDisabledItem(item) || self.isReadOnlyItem(item);
	      },
	          stop = dir === 'next' ? list.last() : list.first(),
	          next = list[dir](item);

	      while (next !== stop && isDisabled(next)) next = list[dir](next);

	      return isDisabled(next) ? item : next;
	    }
	  },

	  _selectAll: function _selectAll() {
	    var _this2 = this;

	    var values = this.state.dataItems,
	        disabled = this.props.disabled || this.props.readOnly,
	        data = this._data(),
	        blacklist;

	    disabled = Array.isArray(disabled) ? disabled : [];
	    //disabled values that are not selected
	    blacklist = disabled.filter(function (v) {
	      return !_this2._contains(v, values);
	    });
	    data = data.filter(function (v) {
	      return !_this2._contains(v, blacklist);
	    });

	    if (data.length === values.length) {
	      data = disabled.filter(function (v) {
	        return _this2._contains(v, values);
	      });
	      data = data.map(function (v) {
	        return _this2._dataItem(_this2._data(), v);
	      });
	    }

	    this.notify('onChange', [data]);
	  },

	  _change: function _change(item, checked) {
	    var multiple = !!this.props.multiple,
	        blacklist = this.props.disabled || this.props.readOnly,
	        values = this.state.dataItems;

	    blacklist = Array.isArray(blacklist) ? blacklist : [];

	    if (!multiple) return this.notify('onChange', checked ? item : null);

	    values = checked ? values.concat(item) : values.filter(function (v) {
	      return v !== item;
	    });

	    this.notify('onChange', [values || []]);
	  },

	  _focus: _util_2['default'].ifNotDisabled(true, function (focused, e) {
	    var _this3 = this;

	    if (focused) _utilCompat2['default'].findDOMNode(this.refs.list).focus();

	    this.setTimeout('focus', function () {
	      if (focused !== _this3.state.focused) {
	        _this3.notify(focused ? 'onFocus' : 'onBlur', e);
	        _this3.setState({ focused: focused });
	      }
	    });
	  }),

	  isDisabledItem: function isDisabledItem(item) {
	    return this.isDisabled() || this._contains(item, this.props.disabled);
	  },

	  isReadOnlyItem: function isReadOnlyItem(item) {
	    return this.isReadOnly() || this._contains(item, this.props.readOnly);
	  },

	  search: function search(character) {
	    var _this4 = this;

	    var word = ((this._searchTerm || '') + character).toLowerCase(),
	        list = this.refs.list;

	    this._searchTerm = word;

	    this.setTimeout('search', function () {
	      var focusedItem = list.next(_this4.state.focusedItem, word);

	      _this4._searchTerm = '';

	      if (focusedItem) _this4.setState({ focusedItem: focusedItem });
	    }, this.props.delay);
	  },

	  _data: function _data() {
	    return this.props.data;
	  },

	  _contains: function _contains(item, values) {
	    return Array.isArray(values) ? values.some(this._valueMatcher.bind(null, item)) : this._valueMatcher(item, values);
	  },

	  _values: function _values() {
	    return this.props.multiple ? this.state.dataItems : this.props.value;
	  }

	});

	function getListItem(parent) {

	  return _react2['default'].createClass({

	    displayName: 'SelectItem',

	    render: function render() {
	      var _props2 = this.props;
	      var children = _props2.children;
	      var focused = _props2.focused;
	      var selected = _props2.selected;
	      var item = _props2.dataItem;
	      var props = babelHelpers.objectWithoutProperties(_props2, ['children', 'focused', 'selected', 'dataItem']);
	      var _parent$props = parent.props;
	      var multiple = _parent$props.multiple;
	      var _parent$props$name = _parent$props.name;
	      var name = _parent$props$name === undefined ? parent._id('_name') : _parent$props$name;

	      var checked = parent._contains(item, parent._values()),
	          change = parent._change.bind(null, item),
	          disabled = parent.isDisabledItem(item),
	          readonly = parent.isReadOnlyItem(item),
	          type = multiple ? 'checkbox' : 'radio';

	      return _react2['default'].createElement(
	        'li',
	        babelHelpers._extends({}, props, {
	          tabIndex: '-1',
	          role: type,
	          'aria-checked': !!checked,
	          'aria-disabled': disabled || readonly,
	          className: (0, _classnames2['default'])('rw-list-option', {
	            'rw-state-focus': focused,
	            'rw-state-selected': selected,
	            'rw-state-disabled': disabled,
	            'rw-state-readonly': readonly
	          })
	        }),
	        _react2['default'].createElement(
	          'label',
	          null,
	          _react2['default'].createElement('input', {
	            name: name,
	            tabIndex: '-1',
	            role: 'presentation',
	            type: type,
	            onChange: onChange,
	            checked: checked,
	            disabled: disabled || readonly
	          }),
	          children
	        )
	      );

	      function onChange(e) {
	        if (!disabled && !readonly) change(e.target.checked);
	      }
	    }
	  });
	}

	var UncontrolledSelectList = (0, _uncontrollable2['default'])(SelectList, { value: 'onChange' });

	UncontrolledSelectList.BaseSelectList = SelectList;

	exports['default'] = UncontrolledSelectList;
	module.exports = exports['default'];

/***/ },

/***/ 1482:
/***/ function(module, exports, __webpack_require__) {

	'use strict';

	var warning = __webpack_require__(117);
	var configuration = __webpack_require__(1414);

	var _require = __webpack_require__(1416);

	var NumberLocalizer = _require.NumberLocalizer;
	var DateLocalizer = _require.DateLocalizer;

	var _require2 = __webpack_require__(1415);

	var globalizeNumberLocalizer = _require2.globalizeNumberLocalizer;
	var globalizeDateLocalizer = _require2.globalizeDateLocalizer;

	module.exports = {

	  setGlobalizeInstance: depreciateMethod(function (globalize) {
	    configuration.locale.date = globalizeDateLocalizer(globalize);
	    configuration.locale.number = globalizeNumberLocalizer(globalize);
	  }),

	  setAnimate: function setAnimate(animatefn) {
	    configuration.animate = animatefn;
	  },

	  setDateLocalizer: function setDateLocalizer(spec) {
	    configuration.locale.date = new DateLocalizer(spec);
	  },

	  setNumberLocalizer: function setNumberLocalizer(spec) {
	    configuration.locale.number = new NumberLocalizer(spec);
	  }
	};

	function depreciateMethod(fn) {
	  return function () {
	    warning(false, 'setGlobalizeInstance() is depreciated. use setDateLocalizer() and setNumberLocalizer() with the Globalize localizers. ' + ' TODO DOC LINK');

	    return fn.apply(this, arguments);
	  };
	}

/***/ },

/***/ 1483:
/***/ function(module, exports) {

	// removed by extract-text-webpack-plugin

/***/ }

});