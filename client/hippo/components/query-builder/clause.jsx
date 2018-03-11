import React from 'react';
import ReactDOM from 'react-dom';
import { defaults } from 'lodash';
import PropTypes from 'prop-types';
import { observer } from 'mobx-react';
import styled from 'styled-components';
import { action, observable } from 'mobx';
import { Button, Box, Drop, TextInput } from 'grommet';
import { Refresh } from 'grommet-icons';
import ClauseModel from '../../models/query/clause';
import { Radio, ClauseFilter } from './clause-filter';
import BooleanPicker from './boolean-picker';
import DatePicker from './date-picker';

const defaultHandlers = {
    boolean: BooleanPicker,
    date: DatePicker,
};

const ClauseWrapper = styled(Box)`
width: 100%;
.clause-select {
  text-align: left;

  flex-grow: inherit;
  padding-left: ${props => props.theme.global.edgeSize.small}
}
.query-value {
  > * {
    flex: 1;
    display: flex;
    > * { flex: 1; }
  }
}
> *:not(:first-child) {
  margin-left: ${props => props.theme.global.edgeSize.small}
};
`;


@observer
export default class Clause extends React.Component {

    static defaultProps = {
        typeHandlers: {},
    }

    static propTypes = {
        clause: PropTypes.instanceOf(ClauseModel).isRequired,
        typeHandlers: PropTypes.object,
    }

    @observable showFilter = false;

    @action.bound onSelect() {
        this.showFilter = false;
    }

    @action.bound onValueChange(ev) {
        this.props.clause.value = ev.target.value;
    }

    @action.bound setDropTargetRef(ref) {
        this.dropTarget = ReactDOM.findDOMNode(ref);
    }

    @action.bound onRefresh() {
        this.props.clause.query.fetch();
    }

    get handlers() {
        return defaults(this.props.typeHandlers, defaultHandlers);
    }

    @action.bound toggleFilter() {
        this.showFilter = !this.showFilter;
    }

    renderInputTag() {
        let input;
        const Tag = this.handlers[this.props.clause.field.queryType];
        if (Tag) {
            input = <Tag clause={this.props.clause} />;
        } else {
            input = (
                <TextInput
                    autoFocus
                    value={this.props.clause.value || ''}
                    onInput={this.onValueChange}
                />
            );
        }
        return <Box className="query-value" flex>{input}</Box>;
    }

    @action.bound setDropRef(drop) {
        this.drop = drop;
    }


    @observable dropTarget;
    @observable drop;

    renderDropFilter() {
        const { props: { clause } } = this;
        if (!this.showFilter) { return null; }

        return (
            <Drop
                ref={this.setDropRef}
                align={{ top: 'bottom', left: 'left' }}
                target={this.dropTarget}
            >
                <Box direction='row' pad="small">
                    <Box size="small" gap="small">
                        {clause.query.info.queryableFields.map(f =>
                            <Radio
                                key={f.id} model={f} clause={clause}
                                onSelect={this.onSelect} name='field' />)}
                    </Box>
                    <Box size="small" gap="small">
                        {clause.validOperators.map(o =>
                            <Radio
                                key={o.id} model={o} clause={clause}
                                onSelect={this.onSelect} name='operator'
                            />)}
                    </Box>
                </Box>
            </Drop>
        );
    }

    render() {
        const { props: { clause } } = this;

        return (
            <ClauseWrapper
                responsive={false}
                className="clause"
                direction='row'
                pad={{ between: 'small' }}
                align="center"
            >
                <Button
                    color="white"
                    className="clause-select"
                    ref={this.setDropTargetRef}
                    onClick={this.toggleFilter}
                    label={<ClauseFilter onClick={this.toggleFilter} clause={clause} />}
                />
                {this.renderDropFilter()}
                {this.renderInputTag()}
                <Button
                    icon={<Refresh />}
                    onClick={this.onRefresh}
                />
            </ClauseWrapper>
        );
    }

}
