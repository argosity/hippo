FactoryBot.define do
    factory :page, class: Hippo::Page do
        contents { [{ 'insert' => Faker::Lorem.paragraph }] }
        html {
            <<-EOC
               <div>
                 <img align="right" src="#{Faker::LoremPixel.image}">
                 <p>#{Faker::Lorem.paragraph}</p>
                 <p>#{Faker::Lorem.paragraph}</p>
                 <p>#{Faker::Lorem.paragraph}</p>
               </div>
            EOC
        }
    end
end
