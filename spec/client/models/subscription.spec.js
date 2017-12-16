import Subscription from 'hippo/models/subscription';

describe('Model Subscription', () => {
    it('can be instantiated', () => {
        const model = new Subscription();
        expect(model).toBeInstanceOf(Subscription);
    });
});
