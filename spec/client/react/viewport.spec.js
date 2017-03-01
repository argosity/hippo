jest.mock('history/createBrowserHistory', () => {
    return jest.fn( () => {
        return {
            listen: jest.fn(),
            location: { pathname: '' },
            push: jest.fn(),
        }
    });
});

import Viewport from 'lanes/react/viewport';

describe('Viewport', () => {
    let container;

    beforeEach(() => {
        container = document.createElement('div');
    });

    it('can be created', () => {
        const vp = new Viewport({ container });
    });
});
