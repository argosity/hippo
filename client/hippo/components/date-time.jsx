import React from 'react';
import PropTypes    from 'prop-types';
import { observer } from 'mobx-react';
import { autobind } from 'core-decorators';
import Flatpickr    from 'flatpickr';
import { defaults, has, omit } from 'lodash';
import { observable, action }  from 'mobx';
import './date-time.scss';

const hooks = [
    'onOpen',
    'onMonthChange',
    'onYearChange',
    'onReady',
    'onValueUpdate',
    'onDayCreate',
    'onBlur',
    'onChange',
];

const defaultOptions = {
    enableTime: true,
    format: 'M d Y h:iK',
};

@observer
export default class DateTimePicker extends React.PureComponent {

    static propTypes = {
        defaultValue: PropTypes.string,
        options: PropTypes.object,
        onChange: PropTypes.func,
        onOpen: PropTypes.func,
        onClose: PropTypes.func,
        onMonthChange: PropTypes.func,
        onYearChange: PropTypes.func,
        onReady: PropTypes.func,
        onValueUpdate: PropTypes.func,
        onDayCreate: PropTypes.func,
        value: PropTypes.oneOfType([
            PropTypes.string,
            PropTypes.array,
            PropTypes.object,
            PropTypes.number,
        ]),
        children: PropTypes.node,
    }

    static defaultProps = {
        options: {},
    }

    @observable node;

    componentWillReceiveProps(props) {
        const options = this.getOptions(props);

        if (has(props, 'value')) {
            this.flatpickr.setDate(props.value, false);
        }

        const optionsKeys = Object.getOwnPropertyNames(options);

        for (let index = optionsKeys.length - 1; index >= 0; index--) {
            const key = optionsKeys[index];
            let value = options[key];

            // Hook handlers must be set as an array
            if (hooks.indexOf(key) !== -1 && !Array.isArray(value)) {
                value = [value];
            }
            this.flatpickr.set(key, value);
        }
    }

    componentDidMount() {
        const options = this.getOptions(this.props);
        this.flatpickr = new Flatpickr(this.node, options);

        if (has(this.props, 'value')) {
            this.flatpickr.setDate(this.props.value, false);
        }
    }

    componentWillUnmount() {
        this.flatpickr.destroy();
    }


    @autobind onClose() {
        if (this.node.blur) { this.node.blur(); }
    }

    @autobind onChange(dates) {
        if ('range' === this.props.options.mode) {
            if (2 === dates.length) {
                this.props.onChange({ target: { value: dates } });
            }
        } else {
            this.props.onChange({ target: { value: dates[0] } });
        }
    }

    getOptions(props) {
        const options = defaults({
            ...this.props.options,
            onClose: this.onClose,
            onChange: this.onChange,
            dateFormat: props.format,
        }, defaultOptions);
        // Add prop hooks to options
        hooks.forEach((hook) => {
            if (this[hook]) {
                options[hook] = this[hook];
            } else if (this.props[hook]) {
                options[hook] = this.props[hook];
            }
        });
        return options;
    }

    @action.bound
    setNode(node) {
        this.node = node;
    }

    render() {
        // eslint-disable-next-line no-unused-vars
        const {
            options: _, defaultValue, value: __, children: ___, ...props
        } = omit(this.props, hooks);

        return (
            <input
                {...props}
                defaultValue={defaultValue}
                ref={this.setNode}
            />
        );
    }

}
