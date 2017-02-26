import React from 'react';
import { pick, extend, map, bindAll, partial, toInteger, isNumber } from 'lodash';
import { action, computed, observable, autorun } from 'mobx';
import { observer } from 'mobx-react';
import cn from 'classnames';
import EditIcon from 'grommet/components/icons/base/Edit';
import NextIcon from 'grommet/components/icons/base/CaretNext';

import { Column, Table, AutoSizer, InfiniteLoader, defaultTableRowRenderer } from 'react-virtualized';
import 'react-virtualized/styles.css';

import './data-table/table-styles.scss';

import Query from '../models/query';
import Row from './data-table/row';
import HeaderCell from './data-table/header-cell';


function renderEditTriangle({ rowIndex, columnData: { onEdit }}) {
    return <NextIcon onClick={partial(onEdit, rowIndex)} />;
}


@observer
export default class DataTable extends React.Component {

    static defaultProps = {
        canCreate: false,
        editRowIndex: null,
    }

    static propTypes = {
        query:     React.PropTypes.instanceOf(Query).isRequired,
        canCreate: React.PropTypes.bool,
        editor:    React.PropTypes.func,
        onEdit:    React.PropTypes.func,
        editRowIndex: React.PropTypes.number,
    }

    constructor(props) {
        super(props);
        this.query = props.query;
        bindAll(this,
                'rowRenderer',
                'rowAtIndex',
                'calculateRowHeight',
                'isRowLoaded',
                'loadMoreRows',
                'headerRenderer',
        );
        this.editIndex = props.editRowIndex;
        autorun(() => {
            if (isNumber(this.editIndex) && this.tableRef) {
                this.tableRef.recomputeRowHeights(this.editIndex);
            }
        });
    }

    componentWillReceiveProps(nextProps) {
        this.editIndex = nextProps.editRowIndex;
    }

    @action.bound
    onEditComplete() {
        const { editIndex } = this;
        if (!this.query.results.isIndexSaved(editIndex)) {
            this.query.results.removeRow(editIndex);
        }
        this.editIndex = null;
        this.tableRef.recomputeRowHeights(editIndex);
        this.props.onEdit(null);
    }

    @action.bound
    onRowEditClick(index) {
        this.props.onEdit(toInteger(index));
    }

    @action.bound
    onRowAdd() {
        this.query.results.insertRow();
        this.editIndex = 0;
    }

    @action.bound
    setSortField(index, ascending) {
        this.query.setSort({ index, ascending });
    }

    @computed get gridRenderKey() {
        return `${this.query.results.updateKey}-${this.editIndex}`;
    }

    @computed get columnDefinitions() {
        const definitions = map(this.query.info.visibleFields, f =>
            extend({
                key: f.id,
                dataKey: f.dataIndex,
                columnData: f,
                headerRenderer: this.headerRenderer,
            }, pick(f, 'width', 'label', 'flexGrow', 'flexShrink')),
        );
        if (this.props.editor) {
            definitions.unshift({
                key: 'edit-toggle',
                label: '',
                width: 40,
                dataKey: 'none',
                columnData: { onEdit: this.onRowEditClick, query: this.query },
                cellRenderer: renderEditTriangle,
            });
        }
        return definitions;
    }

    rowAtIndex({ index }) {
        return this.props.query.results.rows[index];
    }

    @observable editIndex;
    @observable query;

    calculateRowHeight({ index }) {
        return (this.editIndex === index) ? this.props.editor.desiredHeight || 40 : 40;
    }

    rowRenderer(props) {
        const { index, className, style } = props;
        if (this.editIndex === index) {
            const { editor: Editor } = this.props;
            return (
                <div
                    key={props.key}
                    style={props.style}
                    className={cn(props.className, 'editing')}
                >
                    <Editor
                        key={props.index}
                        query={this.query}
                        rowIndex={props.index}
                        onComplete={this.onEditComplete}
                    />
                </div>
            );
        }
        return defaultTableRowRenderer(props);
    }

    headerRenderer({ columnData: field }) {
        return <HeaderCell field={field} onAdd={this.props.canCreate ? this.onRowAdd : null} />;
    }

    isRowLoaded({ index }) {
        return (
            this.query.results.rows.length > index
            && !this.query.results.isRowLoading(index)
            && this.query.results.rows[index]
        );
    }

    loadMoreRows({ startIndex: start, stopIndex }) {
        const limit = (stopIndex + 1) - start;
        return this.query.results.fetch({ start, limit });
    }

    render() {
        const { query } = this;

        return (
            <div className="data-table">
                <InfiniteLoader
                    keyChange={this.gridRenderKey}
                    minimumBatchSize={this.query.pageSize}
                    isRowLoaded={this.isRowLoaded}
                    loadMoreRows={this.loadMoreRows}
                    rowCount={query.results.totalCount}
                >
                    {({ onRowsRendered, registerChild }) => (
                         <AutoSizer
                             updateKey={this.gridRenderKey}
                         >
                            {({ height, width }) => (
                                <Table
                                    height={height}
                                    width={width}
                                    ref={(table) => {
                                        registerChild(table);
                                        this.tableRef = table;
                                    }}
                                    rowHeight={this.calculateRowHeight}
                                    rowGetter={this.rowAtIndex}
                                    headerHeight={50}
                                    onRowsRendered={onRowsRendered}
                                    rowRenderer={this.rowRenderer}
                                    rowCount={query.results.rows.length}
                                    keyChange={this.gridRenderKey}
                                >
                                    {map(this.columnDefinitions, props => <Column {...props} />)}
                                </Table>
                             )}
                        </AutoSizer>
                     )}
                </InfiniteLoader>
            </div>
        );
    }
}
