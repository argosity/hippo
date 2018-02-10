import Quill from 'quill';

const BlockEmbed = Quill.import('blots/block/embed');

const ATTRIBUTES = [
    'alt', 'height', 'width',
];

const STYLE = [
    'display', 'float', 'marginTop', 'marginRight', 'marginBottom', 'marginLeft',
];

class ImageBlot extends BlockEmbed {

    static create({ id, src }) {
        const node = super.create();
        node.setAttribute('data-asset-id', id);
        node.setAttribute('src', src);
        return node;
    }

    static formats(node) {
        const formats = ATTRIBUTES.reduce((f, attribute) => {
            if (node.hasAttribute(attribute)) { f[attribute] = node.getAttribute(attribute); }
            return f;
        }, {});
        return STYLE.reduce((f, attribute) => {
            if (node.style[attribute]) { f[attribute] = node.style[attribute]; }
            return f;
        }, formats);
    }

    static match(url) {
        return /\.(jpe?g|gif|png)$/.test(url) || /^data:image\/.+;base64/.test(url);
    }

    static value(node) {
        return {
            id: node.getAttribute('data-asset-id'),
            src: node.getAttribute('src'),
        };
    }

    format(name, value) {
        if (ATTRIBUTES.indexOf(name) > -1) {
            if (value) {
                this.domNode.setAttribute(name, value);
            } else {
                this.domNode.removeAttribute(name);
            }
        } else if (STYLE.indexOf(name) > -1) {
            if (value) {
                this.domNode.style[name] = value;
            } else {
                this.domNode.style[name] = '';
            }
        } else {
            super.format(name, value);
        }
    }

}

ImageBlot.blotName = 'image';
ImageBlot.tagName = 'img';

Quill.register(ImageBlot, 'image', true);
