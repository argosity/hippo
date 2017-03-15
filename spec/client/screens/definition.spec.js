import { Box, TestExtension, getTestScreen } from '../test-models';

jest.mock('lanes/lib/request-assets');

jest.useFakeTimers();

describe('Screen Definition', () => {
    let screen;

    beforeEach(() => {
        screen = getTestScreen();
    });

    it('computes the title', () => { expect(screen.title).toBe('title'); });

    it('gets model', () => {
        expect(screen.model).toEqual('test/box');
        expect(screen.model_type).toBe(Box);
    });

    it('gets extension_definition', () => {
        expect(screen.extension).toBeInstanceOf(TestExtension);
    });
});
