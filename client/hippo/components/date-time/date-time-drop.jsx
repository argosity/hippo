import React from 'react';
import PropTypes from 'prop-types';
import { action, observable } from 'mobx';
import { observer } from 'mobx-react';
import CSSClassnames from 'grommet/utils/CSSClassnames';
import CalendarIcon from 'grommet/components/icons/base/Calendar';
import ClockIcon from 'grommet/components/icons/base/Clock';
import Box from 'grommet/components/Box';
import cn from 'classnames';

import Calendar from './calendar';
import Time from './time';

const FORM_FIELD = CSSClassnames.FORM_FIELD;
const CLASS_ROOT = 'date-time';

@observer
export default class DateTimeDrop extends React.Component {

    static propTypes = {
        value: PropTypes.object.isRequired,
        onChange: PropTypes.func.isRequired,
        minuteStep: PropTypes.number,
    }

    static className = 'date-time-drop';

    @observable isShowingTime = false;

    @action.bound
    toggleTabs() {
        this.isShowingTime = !this.isShowingTime;
    }

    render() {
        return (
            <Box
                className={`${this.constructor.className} component date-time-drop`}
            >
                <Box
                    direction='row'
                    className="tabs"
                >
                    <Box
                        onClick={this.isShowingTime ? this.toggleTabs : null}
                        colorIndex={this.isShowingTime ? '' : 'neutral-1'}
                        align="center" justify="center" flex direction='row' className="calendar"
                    >
                        <CalendarIcon />
                        Day
                    </Box>
                    <Box
                        onClick={this.isShowingTime ? null : this.toggleTabs}
                        colorIndex={this.isShowingTime ? 'neutral-1' : ''}
                        align="center" justify="center" flex direction='row' className="time"
                    >
                        <ClockIcon />
                        Time
                    </Box>
                </Box>
                <div className={cn('tab', { active: !this.isShowingTime })}>
                    <Calendar
                        moment={this.props.value}
                        onChange={this.props.onChange}
                    />
                </div>
                <div className={cn('tab', { active: this.isShowingTime })}>
                    <Time
                        moment={this.props.value}
                        onChange={this.props.onChange}
                    />
                </div>
            </Box>
        );
    }

}
