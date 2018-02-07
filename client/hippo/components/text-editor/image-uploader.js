import Quill from 'quill';

const Delta = Quill.imports.delta;

class SavingMask {

    constructor(container) {
        const editor = container;
        this.div = document.createElement('div');
        this.div.classList.add('saving-image');
        editor.appendChild(this.div);
    }

    hide() {
        this.div.parentNode.removeChild(this.div);
    }

}

class FileInput {

    constructor(quill, container) {
        const fileInput = document.createElement('input');
        fileInput.setAttribute('type', 'file');
        fileInput.setAttribute('accept', 'image/png, image/gif, image/jpeg, image/bmp, image/x-icon');
        fileInput.classList.add('ql-image');
        fileInput.addEventListener('change', this.onImageSelect);
        container.appendChild(fileInput);

        this.quill = quill;
        this.fileInput = fileInput;
    }

    onImageSelect = () => {
        const { files } = this.fileInput;
        if (!files || !files.length) { return; }

        const saving = new SavingMask(this.quill.container);
        const { assets } = this.quill.options;
        const len = assets.push({});
        const asset = assets[len - 1];
        [asset.file] = files;
        asset.save().then(() => {
            const range = this.quill.getSelection(true);
            const delta = new Delta();
            delta.retain(range.index)
                .delete(range.length)
                .insert({ image: asset.urlFor() });
            this.quill.updateContents(delta, Quill.sources.USER);
            saving.hide();
            this.fileInput.value = '';
        });
    }

    click() {
        this.fileInput.click();
    }

}

export default function imageUploader() {
    let fileInput = this.container.querySelector('input.ql-image[type=file]');
    if (!fileInput) {
        fileInput = new FileInput(this.quill, this.container);
    }
    fileInput.click();
}
