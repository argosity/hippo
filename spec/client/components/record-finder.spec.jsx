import React from 'react';
import { range } from 'lodash';


import Query     from 'lanes/models/query';

import { Snapshot } from 'lanes/testing/screens';
import RecordFinder from 'lanes/components/record-finder';

import { Container } from '../test-models';

jest.mock('lanes/models/sync');

describe("RecordFinder Component", () => {
    let query;
    let props;
    beforeEach(() => {
        query = new Query({
            src: Container,
            fields: [
                { id: 'id', visible: false, queryable: false },
                { id: 'computed', title: 'White?', loadable: false },
                { id: 'name' },
                { id: 'location' },
            ],
        });
        props = {
            onRecordFound: jest.fn(),
            name: 'name',
            fields: {
                name: {
                    value: 'ONE',
                    events: {}
                }
            },
            query
        }

        range(0, 5).forEach(
            i => query.results.rows.push([i, `name ${i}`, `location ${i}`]),
        );
    });

    it('renders', () => {
        const finder = mount(
            <RecordFinder {...props} />,
        );
        console.log(finder.debug())
        expect(finder).toHaveRendered('TextInput');
    });
});
