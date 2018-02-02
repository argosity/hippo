require 'erubis'
require_relative './asset_helper';

module Hippo

    module Templates

        class View < Base

            INCLUDE = lambda do |file, vars = {}|
                view = SM::Templates::View.new(file)
                view.variables.merge!(vars)
                view.as_html
            end

            attr_reader :variables
            attr_reader :methods

            def initialize(vars = {})
                @variables = vars
                @methods = {
                    tenant: Tenant.current,
                    asset: AssetHelper.new,
                    include: INCLUDE
                }
            end

            def extension
                '.erb'
            end

            def as_html
                template.result(variables.merge(methods))
            rescue => e
                Hippo.logger.warn e
                raise
            end

            def template
                @template ||= Erubis::Eruby.new(source)
            end

        end

    end
end
