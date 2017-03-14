import React from 'react';

import QueryBuilder from 'lanes/components/query-builder';

import { Box } from '../test-models';
import { Snapshot } from 'lanes/testing/screens';
import Query from 'lanes/models/query';

jest.useFakeTimers();

describe("Query Builder Component", () => {

    let query;

    beforeEach(() => {
        query = new Query({
            src: Box,
            fields: [
                { id: 'id', visible: false, queryable: false },
                { id: 'computed', title: 'IsAdmin?', loadable: false },
                { id: 'label' },
                { id: 'width' },
                { id: 'height' },
                { id: 'depth', visible: false },
            ],
        });
    });

    it('renders and matches snapshot', () => {
        expect(Snapshot(<QueryBuilder query={query} />)).toMatchSnapshot();
    });

    it('autoloads query when changed', () => {
        query.fetch = jest.fn();
        expect(query.autoFetch).toBe(false);
        const builder = mount(<QueryBuilder query={query} autoFetch />);
        expect(query.autoFetch).toBe(true);
        expect(query.fetch).toHaveBeenCalled();
        query.clauses[0].value = 'test';
        jest.runAllTimers();
        expect(query.fetch).toHaveBeenCalledTimes(2);
        builder.unmount();
        expect(query.autoFetch).toBe(false);
    });
});
