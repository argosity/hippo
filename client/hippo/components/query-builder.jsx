import React from 'react';
import PropTypes from 'prop-types';
import { find } from 'lodash';
import { observer } from 'mobx-react';
import Query from '../models/query';
import Clause from './query-builder/clause';

@observer
export default class QueryBuilder extends React.Component {

    static defaultProps = {
        autoFetch: false,
    }

    static propTypes = {
        autoFetch: PropTypes.bool,
        query: PropTypes.instanceOf(Query).isRequired,
        typeHandlers: PropTypes.object,
    }

    constructor(props) {
        super(props);
        this.previousQueryAutoFetch = this.props.query.autoFetch;
        if (0 === this.props.query.info.visibleClauses.length) {
            const field = find(this.props.query.fields, { visible: true });
            this.props.query.clauses.push({ field, operator: field.preferredOperator });
        }
    }

    componentWillMount() {
        this.props.query.autoFetch = this.props.autoFetch;
    }

    componentWillReceiveProps(nextProps) {
        this.props.query.autoFetch = nextProps.autoFetch;
    }

    componentWillUnmount() {
        this.props.query.autoFetch = this.previousQueryAutoFetch;
    }

    render() {
        const { query, typeHandlers } = this.props;
        return (
            <div className="query-builder">
                {query.info.visibleClauses.map(c => <Clause
                    key={c.id}
                    clause={c}
                    typeHandlers={typeHandlers} />)}
            </div>
        );
    }

}
