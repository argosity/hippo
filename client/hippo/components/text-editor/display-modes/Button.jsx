import React from 'react'; // eslint-disable-line no-unused-vars
import Button from 'grommet/components/Button';
import cn from 'classnames';

const DisplayModeButton = ({
    className, label, icon, onClick, active, disabled,
}) => (
    <span className={cn(className, { active })}>
        <Button
            plain
            secondary={active}
            onClick={onClick}
            label={label}
            disabled={disabled}
            icon={icon}
        />
    </span>
);

export default DisplayModeButton;
