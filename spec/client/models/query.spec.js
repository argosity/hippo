import Sync from 'hippo/models/sync';
import { map, find, range, shuffle } from 'lodash';
import Query  from 'hippo/models/query';
import { Box } from '../test-models';

jest.mock('hippo/models/sync');
jest.useFakeTimers();
describe('Model Queries', () => {
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

    it('autoloads query when changed', () => {
        query.fetch = jest.fn();
        query.autoFetch = true;
        expect(query.fetch).toHaveBeenCalled();
        query.clauses[0].value = 'test value';
        jest.runAllTimers();
        expect(query.fetch).toHaveBeenCalledTimes(2);
        query.clauses[0].value = 'test two value';
        jest.runAllTimers();
        expect(query.fetch).toHaveBeenCalledTimes(3);

        query.autoFetch = false;
        query.clauses[0].value = 'yet another value';
        jest.runAllTimers();
        expect(query.fetch).toHaveBeenCalledTimes(3);
    });

    it('calculates fields', () => {
        expect(query.clauses).toHaveLength(1);
        expect(query.clauses[0].field).toBe(query.fields[1]);
        expect(query.clauses[0].operator.id).toBe('like');
    });

    it('calculates min width', () => {
        expect(query.info.minWidth).toEqual(400);
    });

    it('has operators that can calculate valid types', () => {
        let op = find(query.operators, { id: 'like' });
        expect(op.isValidForField(query.fields[0])).toBe(false);
        expect(op.isValidForField(query.fields[1])).toBe(true);
        expect(op.isValidForField(query.fields[2])).toBe(true);

        op = find(query.operators, { id: 'eq' });
        query.fields.forEach((f) => {
            expect(op.isValidForField(f)).toBe(true);
        });

        op = find(query.operators, { id: 'lt' });
        expect(op.isValidForField(query.fields[0])).toBe(true);
        expect(op.isValidForField(query.fields[1])).toBe(false);
        expect(op.isValidForField(query.fields[2])).toBe(false);
    });

    it('filters available fields and clauses', () => {
        expect(map(query.info.queryableFields, 'id')).toEqual(
            ['computed', 'label', 'width', 'height', 'depth'],
        );
        const clause = query.clauses[0];
        expect(clause.field.id).toEqual('computed');
        expect(clause.operator.id).toEqual('like');
        expect(map(clause.validOperators, 'id')).toEqual(['like', 'eq', 'contains']);
        clause.field = query.fields[3];
        expect(clause.operator.id).toEqual('eq');
        expect(map(clause.validOperators, 'id')).toEqual(['eq', 'lt', 'gt']);
    });

    it('can read identifier field', () => {
        expect(query.info.identifierField.id).toEqual('id');
    });

    it('converts a row to object', () => {
        const i = 1;
        query.results.rows.push([i, `${i} l`, 10 + i, 10 + i, 10 + i]);
        expect(query.results.rowAsObject(0)).toEqual({
            id: 1,
            label: '1 l',
            depth: 11,
            height: 11,
            width: 11,
        });
    });

    it('converts a row to model', () => {
        const i = 1;
        query.results.rows.push([i, `${i} l`, 10 + i, 10 + i, 10 + i]);
        const box = query.results.modelForRow(0);
        expect(box).toBeInstanceOf(Box);
        expect(box.label).toEqual('1 l'); // 'label' isn't serialized; it's a session property
        expect(box.serialize()).toEqual({
            id: 1,
            depth: 11,
            height: 11,
            width: 11,
        });
    });

    it('calculates dataIndex', () => {
        expect(query.fields[0].queryable).toBe(false);
        expect(query.fields[1].queryable).toBe(true);
        expect(query.fields[0].dataIndex).toEqual(0);
        expect(query.fields[1].dataIndex).toEqual(null);
        expect(query.fields[2].dataIndex).toEqual(1);
        expect(query.fields[3].dataIndex).toEqual(2);
        expect(query.fields[4].dataIndex).toEqual(3);
    });

    describe('loading', () => {
        beforeEach(() => {
            Sync.perform.mockReturnValue(Promise.resolve({
                total: 200,
                data: map(range(0, 20), i => [i, `label ${i}`, 10 + i, 10 + i, 10 + i]),
            }));
        });
        it('sends query', () => {
            expect(map(query.info.loadableFields, 'id')).toEqual(
                ['id', 'label', 'width', 'height', 'depth'],
            );
            query.clauses[0].value = 'test value';
            query.results.fetch();
            expect(Sync.perform).toHaveBeenLastCalledWith(
                '/api/test/box', {
                    total_count: 't',
                    fields: ['id', 'label', 'width', 'height', 'depth'],
                    query:  { computed: { op: 'like', value: 'test value%' } },
                    format: 'array',
                    limit:  20,
                    start:  0,
                },
            );
        });

        it('loads sequentially without arguments', () => {
            query.clauses[0].value = 'test value';
            return query.results.fetch().then(() => {
                expect(query.results.totalCount).toEqual(200);
                expect(query.results.rows).toHaveLength(20);
                expect(query.results.rows[0]).toEqual([0, 'label 0', 10, 10, 10]);
                expect(query.results.rows[1]).toEqual([1, 'label 1', 11, 11, 11]);
                expect(query.results.rows[18]).toEqual([18, 'label 18', 28, 28, 28]);

                expect(query.results.rows.map(r => r[0])).toEqual(range(0, 20));
                return query.results;
            }).then((results) => {
                Sync.perform.mockReturnValueOnce(Promise.resolve({
                    total: 200,
                    data: map(range(20, 40), i => [i, `label ${i}`, 10 + i, 10 + i, 10 + i]),
                }));
                return results.fetch().then(() => {
                    expect(results.rows).toHaveLength(40);
                    expect(query.results.rows[38]).toEqual([38, 'label 38', 48, 48, 48]);
                });
            });
        });
        it('can load past previous end', () => {
            expect(query.results.rows).toHaveLength(0);
            const promise = query.results.fetch({ start: 10, limit: 20 }).then(() => {
                expect(query.results.rows).toHaveLength(30);
                expect(query.results.rows[0]).toEqual([]);
                expect(query.results.rows[11]).toEqual([1, 'label 1', 11, 11, 11]);
                expect(query.results.isRowLoading(11)).toBe(false);
            });
            expect(query.results.isRowLoading(1)).toBe(false);
            expect(query.results.isRowLoading(11)).toBe(true);
            expect(query.results.isRowLoading(20)).toBe(true);
            expect(query.results.isRowLoading(40)).toBe(false);
            return promise;
        });
        it('replaces previous records', () => {
            range(0, 50).forEach(i => query.results.rows.push(['blank', i]));
            expect(query.results.rows).toHaveLength(50);
            const promise = query.results.fetch({ start: 10, limit: 20 }).then(() => {
                expect(query.results.rows).toHaveLength(50);
                expect(query.results.rows[0][0]).toEqual('blank');
                expect(query.results.rows[11]).toEqual([1, 'label 1', 11, 11, 11]);
                expect(query.results.rows[15]).toEqual([5, 'label 5', 15, 15, 15]);
                expect(query.results.rows[29]).toEqual([19, 'label 19', 29, 29, 29]);
                expect(query.results.isRowLoading(29)).toBe(false);
                expect(query.results.rows[30]).toEqual(['blank', 30]);
                expect(query.results.isRowLoading(30)).toBe(false);
            });
            expect(query.results.isRowLoading(1)).toBe(false);
            expect(query.results.isRowLoading(11)).toBe(true);
            expect(query.results.isRowLoading(30)).toBe(false);
            return promise;
        });
    });

    describe('sorting', () => {
        beforeEach(() => {
            query.results.reset();
            shuffle(range(0, 5)).forEach(
                i => query.results.rows.push([i, `${i} l`, 10 + i, 10 + i, 10 + i]),
            );
        });

        it('sorts in place when fully loaded', () => {
            query.results.totalCount = 5;
            expect(query.results.fullyLoaded).toEqual(true);
            query.setSort({ field: query.fields[0], ascending: true });
            expect(map(query.results.rows, '0')).toEqual([0, 1, 2, 3, 4]);
            query.setSort({ field: query.fields[1], ascending: false });
            expect(map(query.results.rows, '0')).toEqual([0, 1, 2, 3, 4]);
        });

        it('loads sorted', () => {
            query.results.totalCount = 15;
            expect(query.results.fullyLoaded).toEqual(false);
            query.setSort({ field: query.fields[2], ascending: true });
            expect(Sync.perform).toHaveBeenLastCalledWith(
                '/api/test/box', {
                    total_count: 't',
                    fields: ['id', 'label', 'width', 'height', 'depth'],
                    order:  { label: 'asc' },
                    format: 'array',
                    limit:  20,
                    start:  0, // will request from start, ignoring the 5 existing records
                },
            );
        });
    });

    it('sets valued queries', () => {
        const fingerprint = query.fingerprint;
        query.clauses.replace([
            { field: query.fields[0], value: 123 },
            { field: query.fields[1] },
        ]);
        expect(query.info.valuedClauses).toHaveLength(1);
        expect(query.info.valuedClauses[0].value).toEqual(123);
        expect(query.info.valuedClauses[0].field).toEqual(query.fields[0]);
        expect(query.fingerprint).not.toEqual(fingerprint);
    });

});
