import React from 'react';
import { observer } from 'mobx-react';
import { action, observable } from 'mobx';
import { get } from 'lodash';

import { setFieldValue } from 'lanes/lib/forms';

import Button from 'grommet/components/Button';
import SearchIcon from 'grommet/components/icons/base/Search';

import { Col } from 'react-flexbox-grid';

import { titleize } from '../lib/util';
import Query from '../models/query';

import FormField from './form-field';

import './record-finder/record-finder.scss';
import QueryLayer from './record-finder/query-layer';

@observer
export default class RecordFinder extends React.PureComponent {
    static propTypes = {
        query: React.PropTypes.instanceOf(Query).isRequired,
        name:  React.PropTypes.string.isRequired,
        label: React.PropTypes.string,
        recordsTitle: React.PropTypes.string.isRequired,
        onRecordFound: React.PropTypes.func.isRequired,
        fields: React.PropTypes.object.isRequired,
    }

    @observable showingSearch = false;

    @action.bound
    onSearchClick() {
        this.showingSearch = true;
    }

    @action.bound
    onSearchClose() {
        this.showingSearch = false;
    }

    @action.bound
    onRecordSelect(model) {
        this.showingSearch = false;
        setFieldValue(this.field, model[this.props.name]);
        this.props.onRecordFound(model);
    }

    @action.bound
    onKeyPress(ev) {
        if ('Enter' === ev.key) { this.loadCurrentSelection(); }
    }


    get field() {
        return this.props.fields[this.props.name];
    }

    loadCurrentSelection() {
        this.props.query.fetchSingle(
            { [`${this.props.name}`]: this.field.value },
        ).then(this.onRecordSelect);
    }

    render() {
        const {
            query,
            onRecordFound: _,
            recordsTitle,
            ...otherProps
        } = this.props;

        return (
            <FormField
                className='record-finder'
                onKeyPress={this.onKeyPress}
                {...otherProps}
            >
                <QueryLayer
                    query={query}
                    title={recordsTitle}
                    visible={this.showingSearch}
                    onRecordSelect={this.onRecordSelect}
                    onClose={this.onSearchClose}
                />
                <Button
                    className="grommetux-control-icon-search"
                    icon={<SearchIcon />}
                    onClick={this.onSearchClick}
                />
            </FormField>
        );
    }
}
