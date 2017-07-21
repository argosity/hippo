import React from 'react';
import PropTypes from 'prop-types';
import cn from 'classnames';
import { inRange, get, isString } from 'lodash';
import { action, observable } from 'mobx';
import { observer } from 'mobx-react';
import InputSlider from 'react-input-slider';
import CheckBox from 'grommet/components/CheckBox';
import Box from 'grommet/components/Box';

const NON_DIGIT = /\D/;

function getDigits(ev) {
    const val = get(ev, 'target.value', ev.x);
    if (isString(val) && (!val || NON_DIGIT.test(val))) { return null; }
    return parseInt(val, 10);
}

@observer
export default class TimeSelector extends React.PureComponent {

    static propTypes = {
        moment: PropTypes.object.isRequired,
        onChange: PropTypes.func.isRequired,
        minuteStep: PropTypes.number,
    }

    @observable isPM;
    @observable hour;
    @observable minutes;

    componentWillMount() {
        this.set(this.props);
    }

    componentWillReceiveProps(nextProps) {
        this.set(nextProps);
    }

    set(props) {
        this.isPM = !!(12 <= props.moment.hour());
        this.hour = (12 <= props.moment.hour()) ? props.moment.hour() - 12 : props.moment.hour();
        this.minutes = props.moment.minute();
    }

    @action.bound
    onHourChange(ev) {
        const d = getDigits(ev);
        const m = this.props.moment;
        if (inRange(d, 1, 13)) {
            m.hours(this.isPM ? d + 12 : d);
            this.hour = d;
        } else {
            this.hour = 0;
            m.hours(0);
        }
        this.props.onChange(m);
    }

    @action.bound
    onMinuteChange(ev) {
        const d = getDigits(ev);
        if (inRange(d, 0, 60)) {
            const m = this.props.moment;
            m.minutes(d);
            this.props.onChange(m);
            this.minutes = d;
        } else {
            this.minutes = 0;
        }
    }

    @action.bound
    toggleAMPM(ev) {
        this.isPM = ev.target.checked;
        this.props.moment.hours(this.isPM ? this.hour + 12 : this.hour);
        this.props.onChange(this.props.moment);
    }

    render() {
        const { hour, minutes } = this;

        return (
            <div className={cn('time-picker', this.props.className)}>
                <Box direction='row' className="showtime" justify="center" align="center">
                    <input className="hour" value={hour} onChange={this.onHourChange} />
                    <span className="separater">:</span>
                    <input className="minutes" value={minutes} onChange={this.onMinuteChange} />
                    <CheckBox
                        toggle
                        className="am-pm"
                        label='AM / PM'
                        checked={this.isPM}
                        onChange={this.toggleAMPM}
                    />
                </Box>

                <div className="sliders">
                    <div className="time-text">Hours:</div>
                    <InputSlider
                        className="u-slider-time"
                        xmin={1}
                        xmax={12}
                        step={this.props.minuteStep}
                        x={hour}
                        onChange={this.onHourChange}
                    />
                    <div className="time-text">Minutes:</div>
                    <InputSlider
                        className="u-slider-time"
                        xmin={0}
                        xmax={59}
                        x={minutes || 0}
                        onChange={this.onMinuteChange}
                    />
                </div>
            </div>
        );
    }
}
