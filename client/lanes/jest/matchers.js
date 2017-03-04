module.exports = {

    toHaveRendered(wrapper, selector) {
        const matchCount = wrapper.find(selector).length;
        const result = { pass: 1 === matchCount };
        if (result.pass) {
            result.message = `${selector} was found`;
        } else {
            result.message = `Expected wrapper to contain '${selector}' only once, but it was found ${matchCount} times`;
        }
        return result;
    },

};
