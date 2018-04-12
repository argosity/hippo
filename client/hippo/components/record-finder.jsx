import React from 'react';
import PropTypes from 'prop-types';
import { inject, observer } from 'mobx-react';
import { action, observable } from 'mobx';
import { get } from 'lodash';
import { Button } from 'grommet';
import { Search } from 'grommet-icons';
import { Field } from './form';
import { BaseModel } from '../models/base';
import Query from '../models/query';
import QueryLayer from './record-finder/query-layer';
import './record-finder/record-finder.scss';

@inject('formState')
@observer
export default class RecordFinder extends React.Component {

    static propTypes = {
        query: PropTypes.instanceOf(Query).isRequired,
        model: PropTypes.instanceOf(BaseModel),
        name:  PropTypes.string.isRequired,
        label: PropTypes.string,
        recordsTitle: PropTypes.string.isRequired,
        onRecordFound: PropTypes.func.isRequired,
    }

    static defaultProps = {
        cellWidth: 2,
    }

    @observable showingSearch = false;

    @action.bound
    onSearchClick() {
        this.props.query.reset();
        this.showingSearch = true;
    }

    @action.bound
    onSearchClose() {
        this.showingSearch = false;
    }

    @action.bound
    onRecordSelect(model) {
        this.showingSearch = false;
        const value = get(model, this.props.name);
        this.props.formState.get(this.props.name).value = value;
        this.props.onRecordFound(model);
    }

    @action.bound
    onKeyPress(ev) {
        if ('Enter' === ev.key) { this.loadCurrentSelection(); }
    }


    get field() {
        return this.props.formState.fields.get(this.props.name);
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
            model,
            ...otherProps
        } = this.props;

        return (
            <Field
                className='record-finder'
                onKeyPress={this.onKeyPress}
                readOnly={Boolean(model && !model.isNew)}
                {...otherProps}
                control={<Button icon={<Search />} onClick={this.onSearchClick} />}
            >
                <QueryLayer
                    query={query}
                    title={recordsTitle}
                    visible={this.showingSearch}
                    onRecordSelect={this.onRecordSelect}
                    onClose={this.onSearchClose}
                />

            </Field>
        );
    }

}
