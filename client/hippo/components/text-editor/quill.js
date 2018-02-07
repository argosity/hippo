import Quill from 'quill';
import 'quill/dist/quill.snow.css';
import ImageResize from './image-resize';

Quill.register('modules/imageResize', ImageResize);

const defaultModules = {
    imageResize: {},

    toolbar: [
        ['bold', 'italic', 'underline', 'strike'], // toggled buttons
        ['blockquote', 'code-block'],

        [{ list: 'ordered' }, { list: 'bullet' }],
        [{ script: 'sub' }, { script: 'super' }],
        [{ indent: '-1' }, { indent: '+1' }],
        [{ direction: 'rtl' }],

        [{ size: ['small', false, 'large', 'huge'] }],
        [{ header: [1, 2, 3, 4, 5, 6, false] }],

        [{ color: [] }, { background: [] }],
        [{ font: [] }],
        [{ align: [] }],

        ['link', 'image', 'clean'],
    ],

};

export { Quill, defaultModules };
