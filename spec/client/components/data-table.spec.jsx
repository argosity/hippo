import React from 'react';
import { first, map, find, range } from 'lodash';
import { autorun } from 'mobx';
import Sync from 'lanes/models/sync';
import Query     from 'lanes/models/query';

import DataTable from 'lanes/components/data-table';

import { Container } from '../test-models';

jest.mock('lanes/models/sync');

describe("DataTable Component", () => {
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

    it('can be edited', () => {
        const Editor = () => <h3 data-id="test">Hello - I am Editor</h3>;
        Element.prototype.getBoundingClientRect = jest.fn(() => ({
            width: 800, height: 1024,
        }));
        const onEditSpy = jest.fn();
        const table = mount(
            <DataTable onEdit={onEditSpy} query={query} editor={Editor} />,
        );
        table.find('CaretNext').at(3).simulate('click');
        expect(onEditSpy).toHaveBeenCalledWith(3);
        table.setProps({ editRowIndex: 1 });
        expect(table).toHaveRendered('h3[data-id="test"]');
    });

    it('can sort', () => {
        const table = mount(<DataTable query={query} editable />);
        const spy = jest.fn();
        autorun(() => spy(query.sortField));
        table.find('SortingHeaderCell').first().simulate('click');
        expect(spy).toHaveBeenLastCalledWith(query.info.visibleFields[0]);
    });
});
