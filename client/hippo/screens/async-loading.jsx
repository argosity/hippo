import React from 'react'; // eslint-disable-line no-unused-vars
import Spinning from 'grommet/components/icons/Spinning';
import FormRefreshIcon from 'grommet/components/icons/base/FormRefresh';
import AlertIcon from 'grommet/components/icons/base/Alert';
import Button from 'grommet/components/Button';
import { asyncComponent } from 'react-async-component';
import cn from 'classnames';

const ErrorComponent = ({ screen, retry }) => (
    <div
        data-screen-id={screen.definition.id}
        className={cn('async-loading', 'error', { 'is-active': screen.isActive })}
    >
        <div className="content">
            <h4><AlertIcon /> Failed to load {screen.definition.title}…</h4>
            <Button
                icon={<FormRefreshIcon />}
                onClick={retry}
                label="Retry"
            />
        </div>
    </div>
);


const LoadingComponent = ({ screen }) => (
    <div
        data-screen-id={screen.definition.id}
        className={cn('async-loading', 'is-loading', { 'is-active': screen.isActive })}
    >
        <div className="content">
            <h4><Spinning /> Loading {screen.definition.title}…</h4>
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
