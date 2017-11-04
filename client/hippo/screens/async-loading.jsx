import React from 'react'; // eslint-disable-line no-unused-vars
import Spinning from 'grommet/components/icons/Spinning';
import AlertIcon from 'grommet/components/icons/base/Alert';
import { asyncComponent } from 'react-async-component';

const ErrorComponent = ({ screen }) => (
    <div className="async-loading error">
        <div className="content">
            <AlertIcon /> Failed to load {screen.definition.title}…
        </div>
    </div>
);

const LoadingComponent = ({ screen }) => (
    <div className="async-loading">
        <div className="content">
            <Spinning /> Loading {screen.definition.title}…
        </div>
    </div>
);


export default function asyncLoading({ screen, resolve }) {
    return asyncComponent({
        ErrorComponent,
        LoadingComponent,
        resolve,
        screen,
    });
}
