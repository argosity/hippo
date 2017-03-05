import TestTest from 'appy-app/models/test_test';

describe('Model TestTest', () => {

    it('can be instantiated', () => {
        const model = new TestTest();
        expect(model).toBeInstanceOf(TestTest);
    });

});
