import React from 'react';
import { range } from 'lodash';

import Query     from 'lanes/models/query';

import DataList from 'lanes/components/data-list';

import { Container } from '../test-models';
import { Snapshot } from 'lanes/testing/screens';

jest.mock('lanes/models/sync');

describe("DataList Component", () => {
    let query;

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
        range(0, 5).forEach(
            i => query.results.rows.push([i, `name ${i}`, `location ${i}`]),
        );
    });

    it('renders', () => {
        const Row = ({ row }) => <div data-id={row[0]}>{row[1]}</div>;
        const list = mount(<DataList query={query} rowComponent={Row} />);
        expect(list).toHaveRendered('List');
    });
});