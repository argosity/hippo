import spacer from 'ory-editor-plugins-spacer';
import slate from 'ory-editor-plugins-slate';
import video from 'ory-editor-plugins-video';
import parallax from 'ory-editor-plugins-parallax-background';
import 'ory-editor-plugins-parallax-background/lib/index.css';
import divider from 'ory-editor-plugins-divider';

import 'ory-editor-plugins-image/lib/index.css';
import 'ory-editor-plugins-spacer/lib/index.css';
import 'ory-editor-plugins-video/lib/index.css';
import 'ory-editor-plugins-slate/lib/index.css';

import image from './image-plugin';

const defaultPlugin = slate();

const plugins = {
    content: [slate(), spacer, divider, image, video], // Define plugins for content cells
    layout: [parallax({ defaultPlugin })],
};

export { defaultPlugin, plugins };
