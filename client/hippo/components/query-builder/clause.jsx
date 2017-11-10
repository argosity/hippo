import React from 'react';
import { defaults } from 'lodash';
import PropTypes from 'prop-types';
import { observer } from 'mobx-react';
import { action } from 'mobx';
import Button        from 'grommet/components/Button';
import Box           from 'grommet/components/Box';
import Menu          from 'grommet/components/Menu';
import TextInput     from 'grommet/components/TextInput';
import RefreshIcon   from 'grommet/components/icons/base/Refresh';
import ClauseModel   from '../../models/query/clause';
import { Radio, ClauseFilter } from './clause-filter';
import BooleanPicker from './boolean-picker';
import DatePicker from './date-picker';

const defaultHandlers = {
    boolean: BooleanPicker,
    date: DatePicker,
};

@observer
export default class Clause extends React.PureComponent {

    static defaultProps = {
        typeHandlers: {},
    }

    static propTypes = {
        clause: PropTypes.instanceOf(ClauseModel).isRequired,
        typeHandlers: PropTypes.object,
    }

    @action.bound onSelect() {
        this.menuRef._onClose();
    }

    @action.bound onValueChange(ev) {
        this.props.clause.value = ev.target.value;
    }

    @action.bound setMenuRef(ref) {
        this.menuRef = ref;
    }

    @action.bound onRefresh() {
        this.props.clause.query.fetch();
    }

    get handlers() {
        return defaults(this.props.typeHandlers, defaultHandlers);
    }

    renderInputTag() {
        const Tag = this.handlers[this.props.clause.field.dataType];
        if (Tag) {
            return <Tag clause={this.props.clause} />;
        }
        return (
            <TextInput
                autoFocus
                style={{ flex: 1 }}
                value={this.props.clause.value || ''}
                onDOMChange={this.onValueChange}
            />
        );
    }

    render() {
        const { props: { clause } } = this;

        return (
            <Box responsive={false} className="clause" direction='row' pad={{ between: 'small' }} align="center">
                <Menu
                    ref={this.setMenuRef}
                    size='large'
                    pad='small'
                    closeOnClick={false} icon={<ClauseFilter clause={clause} />}
                >
                    <Box direction='row' pad="small">
                        <Box size="small" pad={{ between: 'small' }}>
                            {clause.query.info.queryableFields.map(f =>
                                <Radio
                                    key={f.id} model={f} clause={clause}
                                    onSelect={this.onSelect} name='field' />)}
                        </Box>
                        <Box size="small" pad={{ between: 'small' }}>
                            {clause.validOperators.map(o =>
                                <Radio
                                    key={o.id} model={o} clause={clause}
                                    onSelect={this.onSelect} name='operator'
                                />)}
                        </Box>
                    </Box>
                </Menu>
                {this.renderInputTag()}
                <Button
                    icon={<RefreshIcon />}
                    onClick={this.onRefresh}
                />
            </Box>
        );
    }

}
