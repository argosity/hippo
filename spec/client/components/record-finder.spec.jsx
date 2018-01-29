import React from 'react'; // eslint-disable-line no-unused-vars
import { range } from 'lodash';

import Query     from 'hippo/models/query';

import { Snapshot } from 'hippo/testing/screens';
import RecordFinder from 'hippo/components/record-finder';
import { FormState } from 'hippo/components/form';
import { Container } from '../test-models';

jest.mock('hippo/models/sync');

describe('RecordFinder Component', () => {
    let query;
    let props;
    let formState;

    beforeEach(() => {
        formState = new FormState();
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
            recordsTitle: 'Foos',
            formState,
            query,
        };
        range(0, 5).forEach(
            i => query.results.rows.push([i, `name ${i}`, `location ${i}`]),
        );
    });

    it('renders', () => {
        expect(Snapshot(<RecordFinder {...props} />)).toMatchSnapshot();
    });
});
