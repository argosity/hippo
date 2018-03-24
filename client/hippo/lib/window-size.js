import { computed } from 'mobx';
import { fromResource } from 'mobx-utils';
import { debounce } from 'lodash';
import Dimensions from '../workspace/dimensions';

export default class WindowSize {

    constructor(windowImpl = window) {
        this.size = fromResource(
            (sink) => {
                sink(this.readSize(windowImpl));
                this.updater = debounce(() => sink(this.readSize(windowImpl)), 200);
                windowImpl.addEventListener('resize', this.updater);
            },
            () => {
                windowImpl.removeEventListener('resize', this.updater);
                this.updater = null;
            },
        );
    }

    @computed get current() {
        return this.size.current();
    }

    @computed get width() {
        const w = this.current.width;
        return (w > Dimensions.dockedWidthBreakpoint) ? (w - Dimensions.menuWidth) : w;
    }

    @computed get height() {
        return this.current.height;
    }

    readSize(windowImpl = window) {
        return {
            width: windowImpl.innerWidth,
            height: windowImpl.innerHeight,
        };
    }

}
