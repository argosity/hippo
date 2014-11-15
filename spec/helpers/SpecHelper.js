beforeEach(function(){
    jasmine.addMatchers({
        toBeDeactivated: function() {
            return {
                compare: function(account){
                    var accountStatusCode = account.get('status').statusCode;
                    var result = { pass: accountStatusCode === 5 };
                    if(result.pass) {
                        result.message =  "Expected account with status code '" + accountStatusCode + " NOT to be deactivated.";
                    } else {
                        result.message =  "Expected account with status code '" + accountStatusCode + "' to be deactivated.";
                    }
                    return result;
                }
            };
        }
    });
});
