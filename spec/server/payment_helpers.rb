module PaymentHelpers
    def with_payment_proccessor
        allow(Hippo::Payments).to receive(:gateway_config) {
            {
                'merchant_id' => 'dshtky2jcjpr96z3',
                'public_key'  => 'hm7n6vc84jbr962w',
                'private_key' => '413cb3c8af29b3c3ba340cfb715f4532',
                'sandbox'     => true
            }
        }
        yield
    end
end
