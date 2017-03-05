import <%= class_name %> from '<%= identifier %>/models/<%= file_name %>';

describe('Model <%= class_name %>', () => {

    it('can be instantiated', () => {
        const model = new <%= class_name %>();
        expect(model).toBeInstanceOf(<%= class_name %>);
    });

});
