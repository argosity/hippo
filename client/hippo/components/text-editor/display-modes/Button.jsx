import React from 'react'; // eslint-disable-line no-unused-vars
import Button from 'grommet/components/Button';

const DisplayModeButton = ({ label, icon, onClick, active, disabled }) => (
    <span className={active ? 'active' : ''}>
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
