import React from 'react'; // eslint-disable-line no-unused-vars
import { observer } from 'mobx-react';
import { get, isEmpty } from 'lodash';
import { Box, Heading } from 'grommet';
import Tenant from '../models/tenant';
import Config from '../config';
import Asset from '../models/asset';

const Logo = observer(() => {
    if (!get(Config, 'logo.thumbnail')) {
        if (!isEmpty(Config.product_name)) {
            return (
                <Box margin="small">
                    <Heading level={3} margin="none" className="product-name">
                        {Tenant.current.name}
                    </Heading>
                </Box>
            );
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
