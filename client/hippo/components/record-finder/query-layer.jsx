import React from 'react';
import PropTypes from 'prop-types';
import { observer }   from 'mobx-react';
import { action } from 'mobx';
import { Heading, Layer, Box, Button } from 'grommet';
import { Close } from 'grommet-icons';
import DataTable from '../data-table';
import QueryBuilder from '../query-builder';

@observer
export default class QueryLayer extends React.Component {

    static propTypes = {
        title: PropTypes.string.isRequired,
        onClose: PropTypes.func.isRequired,
        onRecordSelect: PropTypes.func.isRequired,
    }

    onSearchClose() {

    }

    @action.bound
    onRecordSelect({ model }) {
        this.props.onRecordSelect(model);
    }

    render() {
        const {
            visible, query, onClose, title,
        } = this.props;
        if (!visible) { return null; }

        return (
            <Layer
                onEsc={onClose}
            >
                <Box
                    pad="small"
                    padding={{ bottom: 'small' }}
                    direction='column'
                    margin={{ bottom: 'small' }}
                >
                    <Box
                        direction='row'
                        justify='start'
                        align='center'
                    >
                        <Box flex="grow">
                            <Heading level={3} margin="none">{title}</Heading>
                        </Box>
                        <Button plain icon={<Close />} onClick={onClose} />
                    </Box>
                    <QueryBuilder query={query} autoFetch />
                    <DataTable
                        onRowClick={this.onRecordSelect}
                        query={query} autoFetch
                        style={{ minHeight: 400 }}
                    />
                </Box>
            </Layer>
        );
    }

}
