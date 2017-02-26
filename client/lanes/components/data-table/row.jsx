import React from 'react';

import { observer } from 'mobx-react';

import Query from '../../models/query';
import TR from 'grommet/components/TableRow';

@observer
export default class DataTableRow extends React.PureComponent {
    static propTypes = {
        query: React.PropTypes.instanceOf(Query).isRequired,
        row:   React.PropTypes.array.isRequired, // eslint-disable-line react/forbid-prop-types
    }

    /* @action.bound
     * onEdit() {
     *     this.props.onEdit(this.props.row);
     * }*/

    render() {
        const { row: r, query, isEditing, onEdit, onEditComplete, ...props } = this.props;

        return (
            <TR {...props}>
                <td>{r[1]}</td>
                <td>{r[2]}</td>
                <td className="secondary">
                    {r[3]}
                </td>
            </TR>
        );
    }
}
