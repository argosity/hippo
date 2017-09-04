import React from 'react';
import PropTypes from 'prop-types';
import { partial } from 'lodash';
import { observable, action } from 'mobx';
import { observer } from 'mobx-react';
import { autobind } from 'core-decorators';
import cn from 'classnames';
import Box from 'grommet/components/Box';

import {
    List, AutoSizer, InfiniteLoader,
} from 'react-virtualized';
import 'react-virtualized/styles.css';

import Query from '../models/query';
import './data-list/data-list.scss';

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
    }

    componentWillMount() { this.query.open(); }
    componentWillUnmount() { this.query.close(); }

    @autobind
    rowRenderer(props) {
        const { rowComponent: Row, onRowClick } = this.props;
        const row = this.query.results.rows[props.index];
        return (
            <Row {...props} row={row} onClick={partial(onRowClick, props.index, row)} />
        );
    }

    @autobind
    isRowLoaded({ index }) {
        return (
            (this.query.results.rows.length > index) &&
                (this.query.results.isRowLoading(index) || this.query.results.rows[index])
        );
    }

    @action.bound
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
            <Box
                className={cn('data-list', { selectable: this.props.onRowClick })}
                align='stretch' flex
            >

                {this.props.header}

                <Box className="body" align="stretch" flex>
                    <InfiniteLoader
                        keyChange={query.results.updateKey}
                        minimumBatchSize={query.pageSize}
                        isRowLoaded={this.isRowLoaded}
                        loadMoreRows={this.loadMoreRows}
                        rowCount={query.results.totalCount}
                        keyChange={query.results.fingerprint}
                    >
                        {({ onRowsRendered, registerChild }) =>
                            <AutoSizer
                                keyChange={query.results.fingerprint}
                                updateKey={query.results.updateKey}
                            >
                                {({ height, width }) =>
                                    <List
                                        {...listProps}
                                        height={height}
                                        width={width}
                                        ref={(list) => {
                                            registerChild(list);
                                            this.listRef = list;
                                        }}
                                        rowHeight={rowHeight}
                                        headerHeight={50}
                                        onRowsRendered={onRowsRendered}
                                        rowRenderer={rowRenderer || this.rowRenderer}
                                        rowCount={query.results.rows.length}
                                        keyChange={query.results.fingerprint}
                                    />}
                            </AutoSizer>}
                    </InfiniteLoader>
                </Box>
            </Box>
        );
    }
}
