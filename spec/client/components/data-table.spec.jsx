import React from 'react'; // eslint-disable-line no-unused-vars
import { range } from 'lodash';
import { autorun } from 'mobx';
import Query     from 'hippo/models/query';
import DataTable from 'hippo/components/data-table';

import { Container } from '../test-models';

jest.mock('hippo/models/sync');

describe('DataTable Component', () => {
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
        expect(table).toHaveRendered('Grid');
        // console.log(table.debug())
        // table.find('CaretNext').at(3).simulate('click');
        // expect(onEditSpy).toHaveBeenCalledWith(3);
        // table.setProps({ editRowIndex: 1 });
        // expect(table).toHaveRendered('h3[data-id="test"]');
    });

    xit('can sort', () => {
        const table = mount(<DataTable query={query} editable />);
        const spy = jest.fn();
        autorun(() => spy(query.sortField));
        table.find('SortingHeaderCell').first().simulate('click');
        expect(spy).toHaveBeenLastCalledWith(query.info.visibleFields[0]);
    });
});
