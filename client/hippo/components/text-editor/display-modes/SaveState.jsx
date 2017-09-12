import React from 'react';
import SaveIcon from 'grommet/components/icons/base/Save';
import Button from './Button';

export default class SaveState extends React.PureComponent {

    render() {
        const { props: { onSave } } = this;

        return (
            <Button
                icon={<SaveIcon />}
                label="Save"
                onClick={onSave}
            />
        );
    }

}
