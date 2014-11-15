
# Any promise errors that are uncaught due to missing ".catch" blocks
# will end up here eventually
Lanes.Vendor.RSVP.on('error', (reason)-> Lanes.warn(reason) )
