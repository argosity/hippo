// @flow
import React from 'react';
import { inject, observer } from 'mobx-react';
import { action } from 'mobx';
import { BottomToolbar } from 'ory-editor-ui';
import left    from 'material-ui/svg-icons/editor/format-align-left';
import center  from 'material-ui/svg-icons/editor/format-align-center';
import right   from 'material-ui/svg-icons/editor/format-align-right';
import fill    from 'material-ui/svg-icons/editor/format-align-justify';
import Button from 'grommet/components/Button';
import Display from '../Display';

const Icons = {
    left, center, right, fill,
};

const Btn = ({ align, onChange }) => {
    const onClick = () => onChange({ align });
    const Icon = Icons[align];
    return (
        <Button
            icon={<Icon />}
            onClick={onClick}
        />
    );
};

@inject('assets')
@observer
export default class Form extends React.PureComponent {

    get assets() {
        return this.props.model[this.props.images_attribute];
    }

    @action.bound
    onFileDrop(files) {
        this.assets.push({});
        const asset = this.assets.at(this.assets.length - 1);
        asset.setFile(files[0]);
    }

    render() {
        const { props, props: { onChange } } = this;
        const btnProps = {
            onChange,
        };
        return (
            <div className="image-properties-toolbar">
                <Display {...props} />
                <BottomToolbar open={props.focused}>
                    <Btn align="left"   {...btnProps} />
                    <Btn align="center" {...btnProps} />
                    <Btn align="right"  {...btnProps} />
                    <Btn align="fill"   {...btnProps} />
                </BottomToolbar>
            </div>
        );
    }

}
