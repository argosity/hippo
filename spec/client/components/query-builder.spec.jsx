import React from 'react'; // eslint-disable-line no-unused-vars
import QueryBuilder from 'hippo/components/query-builder';
import { Snapshot } from 'hippo/testing/screens';
import T from 'hippo/testing/wrapper';
import Query from 'hippo/models/query';
import { Box } from '../test-models';

jest.mock('react-dom');
jest.useFakeTimers();

describe('Query Builder Component', () => {
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
        expect(Snapshot(<T><QueryBuilder query={query} /></T>)).toMatchSnapshot();
    });

    it('autoloads query when changed', () => {
        query.results.fetch = jest.fn();
        expect(query.autoFetch).toBe(false);
        const builder = mount(<T><QueryBuilder query={query} autoFetch /></T>);
        expect(query.autoFetch).toBe(true);
        expect(query.results.fetch).toHaveBeenCalled();
        query.clauses[0].value = 'test';
        jest.runAllTimers();
        expect(query.results.fetch).toHaveBeenCalledTimes(2);
        builder.unmount();
        expect(query.autoFetch).toBe(false);
    });
});
