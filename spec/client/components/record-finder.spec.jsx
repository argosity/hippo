import React from 'react';
import { range } from 'lodash';

import Query     from 'hippo/models/query';

import { Snapshot } from 'hippo/testing/screens';
import RecordFinder from 'hippo/components/record-finder';

import { Container } from '../test-models';

jest.mock('hippo/models/sync');
import { FieldDefinitions, stringValue } from 'hippo/components/form';

describe("RecordFinder Component", () => {
    let query;
    let props;
    let formFields;

    beforeEach(() => {
        formFields = new FieldDefinitions({
            name: stringValue,
        });
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
            formFields,
            query,
        };
        range(0, 5).forEach(
            i => query.results.rows.push([i, `name ${i}`, `location ${i}`]),
        );
    });

    it('renders', () => {
        const finder = mount(
            <RecordFinder {...props} />,
        );
        expect(finder).toHaveRendered('TextInput');
    });
});
