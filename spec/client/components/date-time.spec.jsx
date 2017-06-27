import React from 'react';
import DateTime from 'hippo/components/date-time/date-time-drop';
import moment from 'moment';

describe('DateTime Component', () => {
    let props;
    beforeEach(() => {
        props = {
            value: moment('2017-06-26T21:33:13Z'),
            onChange: jest.fn(),
        };
    });

    it('sets time', () => {
        const dt = mount(<DateTime {...props} />);
        dt.find('.minutes').simulate('change', { target: { value: '42' } });
        expect(props.onChange).toHaveBeenCalledWith(props.value);
        expect(props.value.minute()).toEqual(42);
    });
});
