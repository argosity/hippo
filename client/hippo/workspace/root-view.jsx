import React from 'react';

export default function RootView() {
    return (
        <div className="fancy-header">
            <h1>Welcome to the Hippo Framework</h1>
            <p>This is the default root view.  You can change it by returning a different one from the rootView() method in the the extension.js file.</p>
        </div>
    );
}
