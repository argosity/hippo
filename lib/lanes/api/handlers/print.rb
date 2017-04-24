module Lanes::API::Handlers

    class Print
        def self.getter
            lambda do
                template_klass = Lanes::Templates::Latex.for_identifier(params['template_id'])
                form = template_klass.new(params['model_id'])
                content_type 'application/pdf'
                form.as_pdf
            end
        end
    end
end
