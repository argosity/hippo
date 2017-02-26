import UiState  from 'lanes/workspace/uistate';
import Viewport from 'lanes/react/viewport';


describe('Workspace UIState', () => {

    let viewport;
    let uistate;

    beforeEach(() => {
        const container = document.createElement('div');
        viewport = new Viewport({ container, useHistory: false });
        uistate = new UiState({ viewport });
    });

    it('calculates menu size', () => {
        expect(uistate.screenMenuSize).toEqual('menu-hidden');
        expect(uistate.menuWidth).toEqual(0);
        viewport.width = 1200;
        expect(uistate.screenMenuSize).toEqual('menu-narrow');
        expect(uistate.menuWidth).toEqual(60);
        viewport.width = 1600;
        expect(uistate.screenMenuSize).toEqual('menu-wide');
        expect(uistate.menuWidth).toEqual(240);
    });

    it('calculates layout size', () => {
        expect(uistate.layoutSize).toEqual('xs');
        viewport.width = 800;
        expect(uistate.layoutSize).toEqual('sm');
        viewport.width = 1000;
        expect(uistate.layoutSize).toEqual('md');
        viewport.width = 1300;
        expect(uistate.layoutSize).toEqual('lg');
    });

    it('toggles sidebar state', () => {
        expect(uistate.screenMenuPreference).toEqual('');
        uistate.nextSidebarState();
        expect(uistate.screenMenuPreference).toEqual('menu-wide');
        uistate.nextSidebarState();
        expect(uistate.screenMenuPreference).toEqual('menu-narrow');
        uistate.nextSidebarState();
        expect(uistate.screenMenuPreference).toEqual('menu-hidden');
        uistate.nextSidebarState();
        expect(uistate.screenMenuPreference).toEqual('menu-wide');
    });
});
