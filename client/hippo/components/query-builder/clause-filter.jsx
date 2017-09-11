import React from 'react';
import PropTypes from 'prop-types';
import { observer } from 'mobx-react';
import { action } from 'mobx';
import RadioButton   from 'grommet/components/RadioButton';
import DownIcon      from 'grommet/components/icons/base/Down';
import { BaseModel } from '../../models/base';
import ClauseModel   from '../../models/query/clause';


@observer
export class Radio extends React.PureComponent {
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
        return (
            <RadioButton
                id={model.id}
                name={model.id}
                label={model.label}
                onChange={this.onChange}
                checked={(this.props.clause[this.props.name] === model)}
            />
        );
    }
}

@observer
export class ClauseFilter extends React.PureComponent {
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
