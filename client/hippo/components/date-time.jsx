import React from 'react';
import PropTypes from 'prop-types';
import { action, observable } from 'mobx';
import { observer }   from 'mobx-react';
import CalendarIcon from 'grommet/components/icons/base/Calendar';
import ClockIcon from 'grommet/components/icons/base/Clock';
import Button from 'grommet/components/Button';
import CSSClassnames from 'grommet/utils/CSSClassnames';
import { findAncestor, isDescendant } from 'grommet/utils/DOM';
import KeyboardAccelerators from 'grommet/utils/KeyboardAccelerators';
import Drop from 'grommet/utils/Drop';
import moment from 'moment';

import DateTimeDrop from './date-time/date-time-drop';
import './date-time/date-time.scss';

const INPUT = CSSClassnames.INPUT;
const FORM_FIELD = CSSClassnames.FORM_FIELD;
const CLASS_ROOT = CSSClassnames.DATE_TIME;

@observer
export default class DateTime extends React.Component {

    static propTypes = {
        value:    PropTypes.oneOfType([PropTypes.object, PropTypes.string]).isRequired,
        onChange: PropTypes.func.isRequired,
        format:   PropTypes.string,
    }

    static defaultProps = {
        format: 'M/D/YYYY h:mm a',
        onDropChange: () => {},
    }

    static contextTypes = {
        onDropChange: PropTypes.func,
    }

    @observable value;
    @observable drop;

    @action.bound
    onClose(ev) {
        const dropElement = document.querySelector(`.${DateTimeDrop.className}`);
        if (!isDescendant(this.containerRef, ev.target) &&
            (!dropElement || !isDescendant(dropElement, ev.target))) {
            this.setDropActivation(false);
        }
    }

    @action.bound
    setDropActivation(dropActive) {
        const { onDropChange } =  this.context;

        const listeners = {
            esc: this._onForceClose,
        };

        if (dropActive && !this.dropActive) {
            document.addEventListener('click', this.onClose);
            KeyboardAccelerators.startListeningToKeyboard(this, listeners);
            // If this is inside a FormField, place the drop in reference to it.
            const control = findAncestor(this.containerRef, `.${FORM_FIELD}`) || this.containerRef;
            this.drop = new Drop(control, this.renderDrop(), {
                align: { top: 'bottom', left: 'left' },
                focusControl: true,
                context: this.context,
            });
            this.dropActive = true;
            this.props.onDropChange();
        } else if (!dropActive && this.dropActive) {
            document.removeEventListener('click', this.onClose);
            KeyboardAccelerators.stopListeningToKeyboard(this, listeners);

            if (this.drop) {
                this.drop.remove();
                this.drop = undefined;
            }
            this.dropActive = false;
            this.props.onDropChange();
        }

        if (onDropChange) {
            onDropChange(dropActive);
        }
    }

    componentWillMount() {
        this.value = moment(this.props.value || new Date());
    }

    componentWillUnmount() {
        this.setDropActivation(false);
    }

    @action.bound
    onControlClick() {
        this.setDropActivation(!this.dropActive);
    }

    @action.bound
    onDateChange(date) {
        this.value = moment(date);
        this.props.onChange(this.value.date());
    }

    renderDrop() {
        return (
            <DateTimeDrop
                {...this.props}
                onChange={this.onDateChange}
                value={this.value}
            />
        );
    }

    render() {
        const { props: { format, dateOnly } } = this;
        const inputValue = this.value.format(format);
        const Icon = dateOnly ? CalendarIcon : ClockIcon;

        return (
            <div
                ref={r => (this.containerRef = r)}
                className={CLASS_ROOT}
            >
                <input
                    readOnly
                    type="text"
                    placeholder={format}
                    className={`${INPUT} ${CLASS_ROOT}__input`}
                    onClick={this.onControlClick}
                    value={inputValue || ''}
                />
                <Button
                    icon={<Icon />}
                    onClick={this.onControlClick}
                    className={`${CLASS_ROOT}__control`}
                />
            </div>
        );
    }

}
