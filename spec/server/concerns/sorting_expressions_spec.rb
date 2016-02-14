require_relative "../spec_helper"

class SortingExpressionsTest < Lanes::TestCase

    include TestingModels

    def teardown
        TestModel.instance_variable_set(:@sorting_expressions, nil)
    end

    def test_assert_adds_sorting_expression
        refute TestModel.has_sorting_expression?('foo')
        TestModel.export_sort 'foo' do | query, dir |
            query
        end
        assert TestModel.has_sorting_expression?('foo')
    end

    def test_sorting_by_field
        query = TestModel.where(name: 'bar')
        query = TestModel.append_sort_to_query(query, 'name', :asc)
        assert_match 'ORDER BY name ASC', query.to_sql
    end

    def test_sorting_by_block
        query = TestModel.where(name: 'bar')
        TestModel.export_sort :test do | q, dir |
            q.order(:name => 'desc')
        end
        query = TestModel.append_sort_to_query(query, 'test', :asc)
        assert_match 'ORDER BY "test_models"."name" DESC', query.to_sql
    end

end
