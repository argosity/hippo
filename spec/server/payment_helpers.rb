module PaymentHelpers
    def with_payment_proccessor
        RSpec::Mocks.with_temporary_scope do
            with_bt_payment_proccessor do
                yield
            end
        end
    end
end
