// @flow
import React from 'react'; // eslint-disable-line no-unused-vars
import Panorama from 'material-ui/svg-icons/image/panorama';
import './index.scss';
import Asset from '../../../models/asset';
import Component from './Component';

export default {
    Component,
    name: 'ory/editor/core/content/image',
    version: '0.0.1',
    IconComponent: <Panorama />,
    text: 'Image',
    isInlineable: true,
    description: 'Loads an image from an url.',

    handleRemoveHotKey(ev, node) {
        if (node.content.state.assetId) {
            const asset = new Asset({ id: node.content.state.assetId });
            return asset.destroy();
        }
        return Promise.resolve(node);
    },

    // We need this because otherwise we lose hotkey focus on elements like spoilers.
    // This could probably be solved in an easier way by listening to window.document?

    handleFocus: (props: any, source: any, ref: HTMLElement) => {
        if (!ref) { return; }
        setTimeout(() => ref.focus());
    },
};
