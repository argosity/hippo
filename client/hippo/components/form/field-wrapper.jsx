import React from 'react'; // eslint-disable-line no-unused-vars

export default function FieldWrapper({ children }) {
    return (
        <div className="form-field">
            {children}
        </div>
    );
}
