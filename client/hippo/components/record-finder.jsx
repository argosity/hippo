import React from 'react';
import PropTypes from 'prop-types';
import { inject, observer } from 'mobx-react';
import { action, observable } from 'mobx';
import { get } from 'lodash';

import { Field, FormFieldPropType } from 'hippo/components/form';

import Button from 'grommet/components/Button';
import SearchIcon from 'grommet/components/icons/base/Search';

import { Col } from 'react-flexbox-grid';

import { titleize } from '../lib/util';
import Query from '../models/query';

import './record-finder/record-finder.scss';
import QueryLayer from './record-finder/query-layer';

@inject('formFields') @observer
export default class RecordFinder extends React.PureComponent {
    static propTypes = {
        query: PropTypes.instanceOf(Query).isRequired,
        name:  PropTypes.string.isRequired,
        label: PropTypes.string,
        recordsTitle: PropTypes.string.isRequired,
        onRecordFound: PropTypes.func.isRequired,
        formFields: FormFieldPropType,
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
        this.props.formFields.get(this.props.name).value = model[this.props.name]
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
            <Field
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
            </Field>
        );
    }
}
