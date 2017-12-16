import React from 'react'; // eslint-disable-line no-unused-vars
import Spinning from 'grommet/components/icons/Spinning';
import FormRefreshIcon from 'grommet/components/icons/base/FormRefresh';
import AlertIcon from 'grommet/components/icons/base/Alert';
import Button from 'grommet/components/Button';
import { asyncComponent } from 'react-async-component';
import { observer } from 'mobx-react';
import cn from 'classnames';

const ErrorComponent = observer(({ screen, retry }) => (
    <div
        data-screen-id={screen.definition.id}
        className={cn('hippo-screen', 'async-loading', 'error', { 'is-active': screen.isActive })}
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
));


const LoadingComponent = observer(({ screen }) => (
    <div
        data-screen-id={screen.definition.id}
        className={cn('hippo-screen', 'async-loading', 'is-loading', { 'is-active': screen.isActive })}
    >
        <div className="content">
            <h4><Spinning /> Loading {screen.definition.title}…</h4>
        </div>
    </div>
));


export default function asyncLoading({ screen, resolve }) {
    return asyncComponent({
        ErrorComponent,
        LoadingComponent,
        resolve,
        screen,
    });
}
