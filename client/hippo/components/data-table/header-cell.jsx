import React from 'react';
import PropTypes from 'prop-types';
import { last } from 'lodash';
import { action, computed } from 'mobx';
import { observer } from 'mobx-react';

import Box      from 'grommet/components/Box';
import Button   from 'grommet/components/Button';
import AscIcon  from 'grommet/components/icons/base/LinkDown';
import DescIcon from 'grommet/components/icons/base/LinkUp';
import AddIcon  from 'grommet/components/icons/base/AddCircle';

import Field from '../../models/query/field';

@observer
export default class SortingHeaderCell extends React.Component {

    static defaultProps = {
        onAdd: null,
    }

    static propTypes = {
        onAdd: PropTypes.func,
        field: PropTypes.instanceOf(Field).isRequired,
    }

    @action.bound
    onClick() {
        if (this.field.isSortingBy) {
            this.field.query.sortAscending = !this.field.query.sortAscending;
        } else {
            this.field.query.sortField = this.field;
        }
    }

    @computed get displayAdd() {
        return !!(this.props.onAdd && this.field === last(this.field.query.info.visibleFields));
    }

    @computed get hasButtons() {
        return this.displayAdd || this.field.isSortingBy;
    }

    @computed get field() {
        return this.props.field;
    }

    addButton() {
        if (!this.displayAdd) { return null; }
        return (
            <Button
                icon={<AddIcon />}
                onClick={this.props.onAdd}
                plain
            />
        );
    }

    sortIndicator() {
        if (!this.field.isSortingBy) { return null; }
        return this.field.query.sortAscending ? <AscIcon /> : <DescIcon />;
    }
    render() {
        let label = <span>{this.field.label}</span>;

        if (this.field.sortable) {
            label = (
                <Button
                    key="sort"
                    plain={true}
                    fill={true}
                    onClick={this.onClick}
                >
                    {label}
                </Button>
            );
        }
        if (this.hasButtons) {
            return (
                <Box
                    direction='row'
                    justify='between'
                    align='center'
                    pad={{ between: 'small' }}
                >
                    {label}
                    {this.sortIndicator()}
                    {this.addButton()}
                </Box>
            );
        }
        return label;
    }

}
