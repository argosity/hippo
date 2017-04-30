if (!window.Argosity) { window.Argosity = {}; }

const DEFAULT_DURATION = 750; // milliseconds

const EASE_IN_OUT = function(t) {
    if (t < .5) { return 4 * t * t * t; } else { return ((t - 1) * ((2 * t) - 2) * ((2 * t) - 2)) + 1; }
};

const POSITION = function(start, end, elapsed, duration) {
    if (elapsed > duration) {
        return end;
    } else {
        return start + ((end - start) * EASE_IN_OUT(elapsed / duration));
    }
};


export default class SmoothScroll {

    constructor(link, destination, options) {
        this.link = link;
        this.destination = destination;
        if (options == null) { options = {}; }
        this.options = options;
        if (!(this.destination instanceof Element)) {
            this.destination = document.querySelector(this.destination);
        }
        if (!(this.link instanceof Element)) {
            this.link = document.querySelector(this.link);
        }
        if (this.link && this.destination) {
            this.link.addEventListener('click', () => this.scrollToElement());
        } else {
            console.warn("failed to setup link", this.link, this.destination);
        }
    }

    scrollToElement() {
        return this.constructor.scroll(this.destination, this.options.duration || DEFAULT_DURATION);
    }

    static scroll(destination, duration) {
        if (duration == null) { duration = DEFAULT_DURATION; }
        if (!(destination instanceof Element)) {
            destination = document.querySelector(destination);
        }

        if (!destination) {
            console.warn("failed to scroll to", destination);
            return false;
        }

        const startPos  = window.pageYOffset;

        const endPos    =
            destination.getBoundingClientRect().top -
                document.body.getBoundingClientRect().top;

        const startTime = Date.now();

        var step = function() {
            const elapsed = Date.now() - startTime;
            window.scroll(0, POSITION(startPos, endPos, elapsed, duration) );
            if (elapsed < duration) { return window.requestAnimationFrame(step); }
        };
        return step();
    }
};
