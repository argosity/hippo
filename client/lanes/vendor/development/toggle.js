webpackJsonp([3],{

/***/ 0:
/***/ function(module, exports, __webpack_require__) {

	/* WEBPACK VAR INJECTION */(function(global) {var Lanes = ( global.Lanes || (global.Lanes = {}) );
	Lanes.Vendor = ( Lanes.Vendor || {} );

	Lanes.Vendor.ReactToggle = __webpack_require__(737).default;
	__webpack_require__(743);

	/* WEBPACK VAR INJECTION */}.call(exports, (function() { return this; }())))

/***/ },

/***/ 737:
/***/ function(module, exports, __webpack_require__) {

	'use strict';

	Object.defineProperty(exports, "__esModule", {
	  value: true
	});

	var _extends = Object.assign || function (target) { for (var i = 1; i < arguments.length; i++) { var source = arguments[i]; for (var key in source) { if (Object.prototype.hasOwnProperty.call(source, key)) { target[key] = source[key]; } } } return target; };

	var _createClass = function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; }();

	var _react = __webpack_require__(11);

	var _react2 = _interopRequireDefault(_react);

	var _classnames = __webpack_require__(731);

	var _classnames2 = _interopRequireDefault(_classnames);

	var _check = __webpack_require__(738);

	var _check2 = _interopRequireDefault(_check);

	var _x = __webpack_require__(739);

	var _x2 = _interopRequireDefault(_x);

	var _util = __webpack_require__(740);

	var _reactAddonsShallowCompare = __webpack_require__(741);

	var _reactAddonsShallowCompare2 = _interopRequireDefault(_reactAddonsShallowCompare);

	function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

	function _objectWithoutProperties(obj, keys) { var target = {}; for (var i in obj) { if (keys.indexOf(i) >= 0) continue; if (!Object.prototype.hasOwnProperty.call(obj, i)) continue; target[i] = obj[i]; } return target; }

	function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

	function _possibleConstructorReturn(self, call) { if (!self) { throw new ReferenceError("this hasn't been initialised - super() hasn't been called"); } return call && (typeof call === "object" || typeof call === "function") ? call : self; }

	function _inherits(subClass, superClass) { if (typeof superClass !== "function" && superClass !== null) { throw new TypeError("Super expression must either be null or a function, not " + typeof superClass); } subClass.prototype = Object.create(superClass && superClass.prototype, { constructor: { value: subClass, enumerable: false, writable: true, configurable: true } }); if (superClass) Object.setPrototypeOf ? Object.setPrototypeOf(subClass, superClass) : subClass.__proto__ = superClass; }

	var Toggle = function (_Component) {
	  _inherits(Toggle, _Component);

	  function Toggle(props) {
	    _classCallCheck(this, Toggle);

	    var _this = _possibleConstructorReturn(this, (Toggle.__proto__ || Object.getPrototypeOf(Toggle)).call(this, props));

	    _this.handleClick = _this.handleClick.bind(_this);
	    _this.handleTouchStart = _this.handleTouchStart.bind(_this);
	    _this.handleTouchMove = _this.handleTouchMove.bind(_this);
	    _this.handleTouchEnd = _this.handleTouchEnd.bind(_this);
	    _this.handleFocus = _this.setState.bind(_this, { hasFocus: true }, function () {});
	    _this.handleBlur = _this.setState.bind(_this, { hasFocus: false }, function () {});
	    _this.previouslyChecked = !!(props.checked || props.defaultChecked);
	    _this.state = {
	      checked: !!(props.checked || props.defaultChecked),
	      hasFocus: false
	    };
	    return _this;
	  }

	  _createClass(Toggle, [{
	    key: 'componentWillReceiveProps',
	    value: function componentWillReceiveProps(nextProps) {
	      if ('checked' in nextProps) {
	        this.setState({ checked: !!nextProps.checked });
	      }
	    }
	  }, {
	    key: 'handleClick',
	    value: function handleClick(event) {
	      var checkbox = this.input;
	      if (event.target !== checkbox && !this.moved) {
	        this.previouslyChecked = checkbox.checked;
	        event.preventDefault();
	        checkbox.focus();
	        checkbox.click();
	        return;
	      }

	      this.setState({ checked: checkbox.checked });
	    }
	  }, {
	    key: 'handleTouchStart',
	    value: function handleTouchStart(event) {
	      this.startX = (0, _util.pointerCoord)(event).x;
	      this.activated = true;
	    }
	  }, {
	    key: 'handleTouchMove',
	    value: function handleTouchMove(event) {
	      if (!this.activated) return;
	      this.moved = true;

	      if (this.startX) {
	        var currentX = (0, _util.pointerCoord)(event).x;
	        if (this.state.checked && currentX + 15 < this.startX) {
	          this.setState({ checked: false });
	          this.startX = currentX;
	          this.activated = true;
	        } else if (currentX - 15 > this.startX) {
	          this.setState({ checked: true });
	          this.startX = currentX;
	          this.activated = currentX < this.startX + 5;
	        }
	      }
	    }
	  }, {
	    key: 'handleTouchEnd',
	    value: function handleTouchEnd(event) {
	      if (!this.moved) return;
	      var checkbox = this.input;
	      event.preventDefault();

	      if (this.startX) {
	        var endX = (0, _util.pointerCoord)(event).x;
	        if (this.previouslyChecked === true && this.startX + 4 > endX) {
	          if (this.previouslyChecked !== this.state.checked) {
	            this.setState({ checked: false });
	            this.previouslyChecked = this.state.checked;
	            checkbox.click();
	          }
	        } else if (this.startX - 4 < endX) {
	          if (this.previouslyChecked !== this.state.checked) {
	            this.setState({ checked: true });
	            this.previouslyChecked = this.state.checked;
	            checkbox.click();
	          }
	        }

	        this.activated = false;
	        this.startX = null;
	        this.moved = false;
	      }
	    }
	  }, {
	    key: 'getIcon',
	    value: function getIcon(type) {
	      var icons = this.props.icons;

	      if (!icons) {
	        return null;
	      }
	      return icons[type] === undefined ? Toggle.defaultProps.icons[type] : icons[type];
	    }
	  }, {
	    key: 'shouldComponentUpdate',
	    value: function shouldComponentUpdate(nextProps, nextState) {
	      return (0, _reactAddonsShallowCompare2.default)(this, nextProps, nextState);
	    }
	  }, {
	    key: 'render',
	    value: function render() {
	      var _this2 = this;

	      var _props = this.props,
	          className = _props.className,
	          _icons = _props.icons,
	          inputProps = _objectWithoutProperties(_props, ['className', 'icons']);

	      var classes = (0, _classnames2.default)('react-toggle', {
	        'react-toggle--checked': this.state.checked,
	        'react-toggle--focus': this.state.hasFocus,
	        'react-toggle--disabled': this.props.disabled
	      }, className);

	      return _react2.default.createElement(
	        'div',
	        { className: classes,
	          onClick: this.handleClick,
	          onTouchStart: this.handleTouchStart,
	          onTouchMove: this.handleTouchMove,
	          onTouchEnd: this.handleTouchEnd },
	        _react2.default.createElement(
	          'div',
	          { className: 'react-toggle-track' },
	          _react2.default.createElement(
	            'div',
	            { className: 'react-toggle-track-check' },
	            this.getIcon('checked')
	          ),
	          _react2.default.createElement(
	            'div',
	            { className: 'react-toggle-track-x' },
	            this.getIcon('unchecked')
	          )
	        ),
	        _react2.default.createElement('div', { className: 'react-toggle-thumb' }),
	        _react2.default.createElement('input', _extends({}, inputProps, {
	          ref: function ref(_ref) {
	            _this2.input = _ref;
	          },
	          onFocus: this.handleFocus,
	          onBlur: this.handleBlur,
	          className: 'react-toggle-screenreader-only',
	          type: 'checkbox' }))
	      );
	    }
	  }]);

	  return Toggle;
	}(_react.Component);

	exports.default = Toggle;


	Toggle.displayName = 'Toggle';

	Toggle.defaultProps = {
	  icons: {
	    checked: _react2.default.createElement(_check2.default, null),
	    unchecked: _react2.default.createElement(_x2.default, null)
	  }
	};

	Toggle.propTypes = {
	  checked: _react.PropTypes.bool,
	  disabled: _react.PropTypes.bool,
	  defaultChecked: _react.PropTypes.bool,
	  onChange: _react.PropTypes.func,
	  className: _react.PropTypes.string,
	  name: _react.PropTypes.string,
	  value: _react.PropTypes.string,
	  id: _react.PropTypes.string,
	  'aria-labelledby': _react.PropTypes.string,
	  'aria-label': _react.PropTypes.string,
	  icons: _react.PropTypes.oneOfType([_react.PropTypes.bool, _react.PropTypes.shape({
	    checked: _react.PropTypes.node,
	    unchecked: _react.PropTypes.node
	  })])
	};

/***/ },

/***/ 738:
/***/ function(module, exports, __webpack_require__) {

	'use strict';

	Object.defineProperty(exports, "__esModule", {
	  value: true
	});

	var _react = __webpack_require__(11);

	var _react2 = _interopRequireDefault(_react);

	function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

	exports.default = function () {
	  return _react2.default.createElement(
	    'svg',
	    { width: '14', height: '11', viewBox: '0 0 14 11' },
	    _react2.default.createElement(
	      'title',
	      null,
	      'switch-check'
	    ),
	    _react2.default.createElement('path', { d: 'M11.264 0L5.26 6.004 2.103 2.847 0 4.95l5.26 5.26 8.108-8.107L11.264 0', fill: '#fff', fillRule: 'evenodd' })
	  );
	};

/***/ },

/***/ 739:
/***/ function(module, exports, __webpack_require__) {

	'use strict';

	Object.defineProperty(exports, "__esModule", {
	  value: true
	});

	var _react = __webpack_require__(11);

	var _react2 = _interopRequireDefault(_react);

	function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

	exports.default = function () {
	  return _react2.default.createElement(
	    'svg',
	    { width: '10', height: '10', viewBox: '0 0 10 10' },
	    _react2.default.createElement(
	      'title',
	      null,
	      'switch-x'
	    ),
	    _react2.default.createElement('path', { d: 'M9.9 2.12L7.78 0 4.95 2.828 2.12 0 0 2.12l2.83 2.83L0 7.776 2.123 9.9 4.95 7.07 7.78 9.9 9.9 7.776 7.072 4.95 9.9 2.12', fill: '#fff', fillRule: 'evenodd' })
	  );
	};

/***/ },

/***/ 740:
/***/ function(module, exports) {

	"use strict";

	Object.defineProperty(exports, "__esModule", {
	  value: true
	});
	exports.pointerCoord = pointerCoord;
	// Copyright 2015-present Drifty Co.
	// http://drifty.com/
	// from: https://github.com/driftyco/ionic/blob/master/src/util/dom.ts

	function pointerCoord(event) {
	  // get coordinates for either a mouse click
	  // or a touch depending on the given event
	  if (event) {
	    var changedTouches = event.changedTouches;
	    if (changedTouches && changedTouches.length > 0) {
	      var touch = changedTouches[0];
	      return { x: touch.clientX, y: touch.clientY };
	    }
	    var pageX = event.pageX;
	    if (pageX !== undefined) {
	      return { x: pageX, y: event.pageY };
	    }
	  }
	  return { x: 0, y: 0 };
	}

/***/ },

/***/ 741:
/***/ function(module, exports, __webpack_require__) {

	module.exports = __webpack_require__(742);

/***/ },

/***/ 742:
/***/ function(module, exports, __webpack_require__) {

	/**
	 * Copyright 2013-present, Facebook, Inc.
	 * All rights reserved.
	 *
	 * This source code is licensed under the BSD-style license found in the
	 * LICENSE file in the root directory of this source tree. An additional grant
	 * of patent rights can be found in the PATENTS file in the same directory.
	 *
	 */

	'use strict';

	var shallowEqual = __webpack_require__(308);

	/**
	 * Does a shallow comparison for props and state.
	 * See ReactComponentWithPureRenderMixin
	 * See also https://facebook.github.io/react/docs/shallow-compare.html
	 */
	function shallowCompare(instance, nextProps, nextState) {
	  return !shallowEqual(instance.props, nextProps) || !shallowEqual(instance.state, nextState);
	}

	module.exports = shallowCompare;

/***/ },

/***/ 743:
/***/ function(module, exports) {

	// removed by extract-text-webpack-plugin

/***/ }

});