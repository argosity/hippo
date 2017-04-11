import React from 'react';

import PropTypes from 'prop-types';

import { observer } from 'mobx-react';
import { action }   from 'mobx';
import Box          from 'grommet/components/Box';
import Menu         from 'grommet/components/Menu';
import RadioButton  from 'grommet/components/RadioButton';
import TextInput    from 'grommet/components/TextInput';
import DownIcon     from 'grommet/components/icons/base/Down';

import BaseModel from '../models/base';
import Query         from '../models/query';
import ClauseModel   from '../models/query/clause';
import FieldModel    from '../models/query/field';
import OperatorModel from '../models/query/operator';

@observer
class Radio extends React.PureComponent {

    static propTypes = {
        name: PropTypes.string.isRequired,
        onSelect: PropTypes.func.isRequired,
        model: PropTypes.instanceOf(BaseModel).isRequired,
        clause: PropTypes.instanceOf(ClauseModel).isRequired,
    }

    @action.bound
    onChange() {
        this.props.clause[this.props.name] = this.props.model;
        this.props.onSelect();
    }

    render() {
        const { model } = this.props;
        const checked = (this.props.clause[this.props.name] === model);
        return (
            <RadioButton
                name={model.id}
                label={model.label}
                onChange={this.onChange}
                checked={checked}
            />
        );
    }
}

@observer
class ClauseFilter extends React.PureComponent {

    static propTypes = {
        clause: PropTypes.instanceOf(ClauseModel).isRequired,
    }

    render() {
        const { clause } = this.props;
        return (
            <span>
                <DownIcon /> {clause.field.label} {clause.operator.label}
            </span>
        );
    }
}

@observer
class Clause extends React.PureComponent {

    static propTypes = {
        clause: PropTypes.instanceOf(ClauseModel).isRequired,
    }

    @action.bound
    onSelect() {
        this.menuRef._onClose();
    }

    @action.bound
    onValueChange(ev) {
        this.props.clause.value = ev.target.value;
    }

    render() {
        const { clause } = this.props;
        return (
            <Box direction='row' pad={{ between: 'small' }}>
                <Menu
                    ref={ref => (this.menuRef = ref)}
                    size='large'
                    pad='small'
                    closeOnClick={false} icon={<ClauseFilter clause={clause} />}
                >
                    <Box direction='row' pad="small">
                        <Box size="small" pad={{ between: 'small' }}>
                            {clause.query.info.queryableFields.map(f =>
                                <Radio
                                    key={f.id} model={f} clause={clause}
                                    onSelect={this.onSelect} name='field' />,
                             )}
                        </Box>
                        <Box size="small" pad={{ between: 'small' }}>
                            {clause.validOperators.map(o =>
                                <Radio
                                    key={o.id} model={o} clause={clause}
                                    onSelect={this.onSelect} name='operator'
                                />,
                             )}
                        </Box>
                    </Box>
                </Menu>
                <TextInput
                    autoFocus
                    style={{ flex: 1 }}
                    value={clause.value || ''}
                    onDOMChange={this.onValueChange}
                />
            </Box>
        );
    }
}

@observer
export default class QueryBuilder extends React.PureComponent {

    static defaultProps = {
        autoFetch: false,
    }

    static propTypes = {
        autoFetch: PropTypes.bool,
        query: PropTypes.instanceOf(Query).isRequired,
    }

    constructor(props) {
        super(props);
        this.previousQueryAutoFetch = this.props.query.autoFetch;
        this.props.query.autoFetch = props.autoFetch;
    }

    componentWillReceiveProps(nextProps) {
        this.props.query.autoFetch = nextProps.autoFetch;
    }

    componentWillUnmount() {
        this.props.query.autoFetch = this.previousQueryAutoFetch;
    }

    render() {
        const { query } = this.props;
        return (
            <div className="query-builder">
                {query.clauses.map(c => <Clause key={c.id} clause={c} />)}
            </div>
        );
    }

}
