import React from 'react';
import PropTypes from 'prop-types';
import { bindAll } from 'lodash';
import { observable } from 'mobx';
import { observer } from 'mobx-react';

import Box from 'grommet/components/Box';

import {
    List, AutoSizer, InfiniteLoader,
} from 'react-virtualized';
import 'react-virtualized/styles.css';

import Query from '../models/query';

@observer
export default class DataList extends React.Component {

    static defaultProps = {
        rowHeight: 40,
    }

    static propTypes = {
        query: PropTypes.instanceOf(Query).isRequired,
        rowComponent: PropTypes.func,
        rowHeight: PropTypes.oneOfType([
            PropTypes.number, PropTypes.func,
        ]),
    }

    @observable query;

    constructor(props) {
        super(props);
        this.query = props.query;
        bindAll(this,
                'rowRenderer',
                'isRowLoaded',
                'loadMoreRows',
        );
    }

    rowRenderer(props) {
        const { rowComponent: Row } = this.props;
        const row = this.query.results.rows[props.index];
        return (
            <Row {...props} row={row} />
        );
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

    recomputeRowHeights(editIndex) {
        this.listRef.recomputeRowHeights(editIndex);
    }

    render() {
        const { query } = this;
        const { rowHeight, rowRenderer, ...listProps } = this.props;
        return (
            <Box className="data-list" align='stretch' direction='row' flex>
                <InfiniteLoader
                    keyChange={query.results.updateKey}
                    minimumBatchSize={query.pageSize}
                    isRowLoaded={this.isRowLoaded}
                    loadMoreRows={this.loadMoreRows}
                    rowCount={query.results.totalCount}
                >
                    {({ onRowsRendered, registerChild }) =>
                        <AutoSizer
                            updateKey={query.results.updateKey}
                        >
                            {({ height, width }) =>
                                <List
                                    {...listProps}
                                    height={height}
                                    width={width}
                                    ref={(list) => { registerChild(list); this.listRef = list; }}
                                    rowHeight={rowHeight}
                                    headerHeight={50}
                                    onRowsRendered={onRowsRendered}
                                    rowRenderer={rowRenderer || this.rowRenderer}
                                    rowCount={query.results.rows.length}
                                    keyChange={query.results.updateKey}
                                />}
                        </AutoSizer>}
                </InfiniteLoader>
            </Box>
        );
    }
}
