require_relative '../spec_helper'

class ExportScopeTest < Lanes::TestCase

    def teardown
        User.send( :remove_method, :big_query ) if User.respond_to?( :account_name )
    end

    def test_scope_method_creation
        refute User.respond_to?(:big_query)
        User.send( :export_scope, :big_query, ->{} )
        assert User.respond_to?(:big_query)
    end

end
