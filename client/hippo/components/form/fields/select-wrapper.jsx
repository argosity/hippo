import React from 'react';
import styled from 'styled-components';
import { observer } from 'mobx-react';
import { action, computed } from 'mobx';
import { Box, Text, Select } from 'grommet';
import { get, find } from 'lodash';

const renderOption = (opt = { id: -1, label: 'None' }) => (
    <Box
        align='center'
        direction='row'
        pad='small'
    >
        <Text margin={{ horizontal: 'xsmall' }}>{opt.label}</Text>
    </Box>
);

const Wrapper = styled.div`
flex: 1;
display: flex;
> button { flex: 1; }
`;

@observer
export default class SelectFieldWrapper extends React.Component {

    @action.bound
    onSelectChange({ option: { id } }) {
        const ev = { target: { value: id } };
        this.props.onChange(ev);
        this.props.onBlur(ev);
    }

    @computed get value() {
        return this.props.value ? get(find(this.props.collection, { id: this.props.value }), 'label', '') : '';
    }

    render() {
        const { children, collection, ...otherProps } = this.props;

        return (
            <Wrapper>
                <Select
                    {...otherProps}
                    value={this.value}
                    options={collection}
                    onChange={this.onSelectChange}
                >
                    {children || renderOption}
                </Select>
            </Wrapper>
        );
    }

}
