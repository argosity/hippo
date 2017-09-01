import React from 'react';
import PropTypes from 'prop-types';
import Select from 'grommet/components/Select';
import { observer } from 'mobx-react';
import { action, computed, observable } from 'mobx';
import { filter } from 'lodash';
import moment from 'moment-timezone';


@observer
export default class TimeZoneSelect extends React.PureComponent {

    static propTypes = {
        value: PropTypes.string,
        onChange: PropTypes.func.isRequired,
    }

    static defaultProps = {
        value: '',
    }

    @observable currentSearch;

    choices = moment.tz.names();

    get value() {
        return this.props.value || moment.tz.guess();
    }

    @action.bound filterFn(tz) {
        return this.currentSearch.test(tz);
    }

    @computed get names() {
        if (this.currentSearch) {
            return filter(moment.tz.names(), this.filterFn);
        }
        return this.choices;
    }

    @action.bound onSearch({ target: { value } }) {
        this.currentSearch = new RegExp(`^${value}|/${value}`, 'i');
    }

    @action.bound
    onChange({ value }) {
        this.props.onChange({ value, target: { value } });
    }

    render() {
        return (
            <Select
                placeHolder='None'
                options={this.names}
                onSearch={this.onSearch}
                value={this.value}
                onChange={this.onChange}
            />
        );
    }
}
