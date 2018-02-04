import React from 'react'; // eslint-disable-line no-unused-vars
import { observer } from 'mobx-react';
import { get, isEmpty } from 'lodash';
import { Box } from 'grommet';
import Config from '../config';
import Asset from '../models/asset';

const Logo = observer(() => {
    if (!get(Config, 'logo.thumbnail')) {
        if (!isEmpty(Config.product_name)) {
            return <Box margin="none" className="product-name">{Config.product_name}</Box>;
        }
        return null;
    }
    return (
        <Box className="logo" margin="none">
            <img src={Asset.urlForSize(Config.logo, 'thumbnail')} />
        </Box>
    );
});

export default Logo;
