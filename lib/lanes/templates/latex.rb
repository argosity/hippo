require 'erb_latex'

module Lanes

    module Templates

        class Latex < Base

            ALL = []

            def self.for_identifier(id)
                ALL.find{|tmpl| tmpl.identifier == id}
            end

            class Context < ErbLatex::Context

                def pluralize(count, word)
                    count == 1 ? word : word.pluralize
                end

            end

            attr_accessor_with_default :model
            attr_accessor_with_default :identifier

            def self.inherited(klass)
                ALL << klass
            end

            attr_reader :id

            def initialize(id)
                @id = id
            end

            def as_pdf
                engine.to_stringio
            rescue ErbLatex::LatexError => e
                Lanes.logger.warn e.log
                raise
            rescue => e
                Lanes.logger.warn e
                raise
            end

            def as_latex
                engine.compile_latex
            end

            def root_path
                super.join('latex')
            end

            def variables
                { 'root_path' => root_path, class_as_name => record }
            end

            def record
                @record ||= model.find(id)
            end

            def extension
                '.tex.erb'
            end

            def render
                engine.to_stringio
            rescue ErbLatex::LatexError => e
                Lanes.logger.warn e.log
                raise
            rescue => e
                Lanes.logger.warn e
                raise
            end

            def context
                Context
            end

            def engine_options
                options = {
                    data: variables,
                    context: context,
                    partials_path: root_path.join('partials'),
                    packages_path: root_path.join('packages')

                }
                options[:layout] = layout unless layout.blank?
                options
            end

            def layout
                root_path.join('layout.tex.erb')
            end

            def engine
                ErbLatex::Template.new(pathname, engine_options)
            end
        end
    end
end
