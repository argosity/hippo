import React from 'react';
import PropTypes from 'prop-types';
import { isNil, toInteger } from 'lodash';
import { observable, action, computed } from 'mobx';
import { observer }   from 'mobx-react';
import { Heading } from '../components/form';
import Screen from '../components/screen';
import DataTable from '../components/data-table';
import { UserModel } from '../user';
import Query from '../models/query';
import Editor from './user-management/edit-form';

@observer
export default class UserManagement extends React.Component {

    @observable editingId;

    static contextTypes = {
        router: PropTypes.object,
    }

    @action.bound
    onRowEdit(index) {
        let id = '';
        if (!isNil(index)) {
            const row = this.query.results.rows[index];
            id = row[this.query.info.identifierField.dataIndex];
        }
        this.editingId = id;
    }

    @observable query = new Query({
        src: UserModel,
        autoFetch: true,
        fields: [
            { id: 'id', visible: false },
            { id: 'role_names', visible: false, defaultValue: [] },
            { id: 'login', width: 150, flexGrow: 0 },
            'name', 'email',
        ],
    })

    @computed get editingRowIndex() {
        if (isNil(this.editingId)) return undefined;
        const field = this.query.info.identifierField;
        const id = (field.isNumeric) ? toInteger(this.editingId) : this.editingId;
        return this.query.results.searchFieldValues(field, id).index;
    }

    render() {
        return (
            <Screen {...this.props}>
                <Heading>User Management</Heading>
                <DataTable
                    canCreate
                    query={this.query}
                    editRowIndex={this.editingRowIndex}
                    onEdit={this.onRowEdit}
                    editor={Editor}
                />
            </Screen>
        );
    }

}
