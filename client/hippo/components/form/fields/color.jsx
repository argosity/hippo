import React from 'react';
import { observer } from 'mobx-react';
import { action } from 'mobx';
import { Box } from 'grommet';
import ColorPicker from 'rc-color-picker';
import 'rc-color-picker/assets/index.css';
import styled from 'styled-components';


const colorWrapperStyles = () => `
flex-direction: row;
justify-content: flex-start;
align-items: center;
`;

export { colorWrapperStyles };

const ColorWrapper = styled(Box)`
.react-custom-trigger {
  cursor: pointer;
  border: 1px solid grey;
  width: 25px;
  height: 25px;
  margin-left: 0.5rem;
}
`;

@observer
export default class CheckBoxWrapper extends React.Component {

    @action.bound onChange({ color }) {
        this.props.onChange({ target: { value: color } });
    }

    render() {
        const { className, value, ...props } = this.props;

        return (
            <ColorWrapper
                className={className}
                pad={{ horizontal: 'small' }}
                direction="row"
            >
                {value}
                <ColorPicker
                    {...props}
                    color={value || '#fff'}
                    onChange={this.onChange}
                >
                    <div className="react-custom-trigger" />
                </ColorPicker>
            </ColorWrapper>
        );
    }

}
