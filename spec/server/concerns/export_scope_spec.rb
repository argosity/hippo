require_relative "../spec_helper"

class ExportScopeTest < Lanes::TestCase
    include TestingModels

    def test_scope_method_creation
        refute TestModel.respond_to?(:big_query)
        TestModel.send( :scope, :big_query, ->{},  {export: true}  )
        assert TestModel.respond_to?(:big_query)
        assert TestModel.has_exported_scope?(:big_query,DummyUser.new)
    end


end
