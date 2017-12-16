/* global jest */
import Tenant from 'hippo/models/tenant';
import Config from 'hippo/config';
import Subscription from 'hippo/models/subscription';

export React from 'react';

export { getScreenInstance, Snapshot } from './screens';

Config.subscription_plans = [new Subscription({ id: 1, price: '42.42' })];
Tenant.current.subscription_id = Subscription.all[0].id;

jest.mock('hippo/config');
jest.mock('hippo/models/sync');
