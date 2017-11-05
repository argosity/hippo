import React from 'react'; // eslint-disable-line no-unused-vars
import Spinning from 'grommet/components/icons/Spinning';
import AlertIcon from 'grommet/components/icons/base/Alert';
import { asyncComponent } from 'react-async-component';
import cn from 'classnames';

const ErrorComponent = ({ screen }) => (
    <div
        data-screen-id={screen.definition.id}
        className={cn('async-loading', 'error', { 'is-active': screen.isActive })}
    >
        <div className="content">
            <AlertIcon /> Failed to load {screen.definition.title}…
        </div>
    </div>
);

const LoadingComponent = ({ screen }) => (
    <div
        data-screen-id={screen.definition.id}
        className={cn('async-loading', 'loading', { 'is-active': screen.isActive })}
    >
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
