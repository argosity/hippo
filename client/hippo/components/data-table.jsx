import React from 'react';
import PropTypes from 'prop-types';
import { pick, extend, defaults, map, bindAll, partial, toInteger, isNumber } from 'lodash';
import { defaultTableRowRenderer, Table, InfiniteLoader, AutoSizer, Column } from 'react-virtualized';
import { action, computed, observable, autorun } from 'mobx';
import { observer } from 'mobx-react';
import cn from 'classnames';

import NextIcon from 'grommet/components/icons/base/CaretNext';
import Button   from 'grommet/components/Button';

import 'react-virtualized/styles.css';
import './data-table/table-styles.scss';

import Query from '../models/query';
import HeaderCell from './data-table/header-cell';

function renderEditTriangle({ rowIndex, columnData: { onEdit } }) {
    return (
        <Button
            plain icon={<NextIcon />}
            onClick={partial(onEdit, rowIndex)}
        />
    );
}

@observer
export default class DataTable extends React.Component {

    static defaultProps = {
        canCreate: false,
        editRowIndex: null,
        style: {},
    }

    static propTypes = {
        style:     PropTypes.object,
        query:     PropTypes.instanceOf(Query).isRequired,
        canCreate: PropTypes.bool,
        editor:    PropTypes.func,
        onEdit:    PropTypes.func,
        editRowIndex: PropTypes.number,
    }

    @observable editIndex;
    @observable query;

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

    componentWillMount() { this.query.open(); }
    componentWillUnmount() { this.query.close(); }

    get rowProps() {
        const props = {};
        if (this.props.onRowClick) { props.onRowClick = this.onRowClick; }
        return props;
    }

    @action.bound
    onRowClick({ index }) {
        this.query.results.fetchModelForRow(index).then((model) => {
            this.props.onRowClick({ index, model });
        });
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
    getRowClassName({ index }) {
        if (index < 0) {
            return 'header';
        }
        return 0 === index % 2 ? 'e' : 'o';
    }

    @action.bound
    setSortField(index, ascending) {
        this.query.setSort({ index, ascending });
    }

    @computed get gridRenderKey() {
        return `${this.query.results.fingerprint}-${this.editIndex}`;
    }

    @computed get columnDefinitions() {
        const definitions = map(this.query.info.visibleFields, f =>
            extend({
                key: f.id,
                columnData: f,
                dataKey: f.dataIndex || f.id,
                headerRenderer: this.headerRenderer,
            }, pick(f, 'width', 'label', 'flexGrow', 'flexShrink',
                'cellRenderer', 'className', 'headerClassName'),
            ),
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

    get wrapperStyles() {
        return defaults({
            minWidth:  this.query.info.minWidth,
            minHeight: 400,
        }, this.props.styles);
    }

    rowAtIndex({ index }) {
        return this.props.query.results.rows[index];
    }

    calculateRowHeight({ index }) {
        return (this.editIndex === index) ? this.props.editor.desiredHeight || 40 : 40;
    }

    rowRenderer(props) {
        const { index, className, key, style } = props;
        extend(props, this.rowProps);
        if (this.editIndex === index) {
            const { editor: Editor } = this.props;
            return (
                <div
                    key={key}
                    style={style}
                    className={cn(className, 'editing')}
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
            (this.query.results.rows.length > index) &&
                (this.query.results.isRowLoading(index) || this.query.results.rows[index])
        );
    }

    loadMoreRows({ startIndex: start, stopIndex }) {
        const limit = (stopIndex + 1) - start;
        return this.query.results.fetch({ start, limit });
    }

    render() {
        const { query } = this;
        return (
            <div
                className={cn('data-table', { selectable: this.props.onRowClick })}
                style={this.wrapperStyles}
            >
                <InfiniteLoader
                    keyChange={this.gridRenderKey}
                    minimumBatchSize={this.query.pageSize}
                    isRowLoaded={this.isRowLoaded}
                    loadMoreRows={this.loadMoreRows}
                    rowCount={query.results.totalCount}
                >
                    {({ onRowsRendered, registerChild }) =>
                        <AutoSizer
                            updateKey={this.gridRenderKey}
                        >
                            {({ height, width }) =>
                                <Table
                                    height={height}
                                    width={width}
                                    ref={(table) => {
                                        registerChild(table); this.tableRef = table;
                                    }}
                                    rowHeight={this.calculateRowHeight}
                                    rowGetter={this.rowAtIndex}
                                    estimatedRowSize={40}
                                    headerHeight={50}
                                    rowClassName={this.getRowClassName}
                                    onRowsRendered={onRowsRendered}
                                    rowRenderer={this.rowRenderer}
                                    rowCount={query.results.rows.length}
                                    keyChange={this.gridRenderKey}
                                >
                                    {map(this.columnDefinitions, props => <Column {...props} />)}
                                </Table>}
                        </AutoSizer>}
                </InfiniteLoader>
            </div>
        );
    }

}
