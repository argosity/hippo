require 'activerecord-multi-tenant'

module Hippo
    # Tenant
    class Tenant < Hippo::Model

        PUBLIC_ATTRS = %w{slug name identifier}

        validates :slug, uniqueness: true
        validates :name, :presence => { message: 'for company' }
        validates :email, :presence => true

        has_random_identifier
        has_many :users, class_name: 'Hippo::User', autosave: true

        belongs_to :system_settings, class_name: 'Hippo::SystemSettings',
                   foreign_key: :id, primary_key: :tenant_id

        before_validation :auto_assign_slug, on: :create

        before_save :downcase_slug

        def domain
            self.slug + '.' + Hippo.config.website_domain
        end

        def perform
            MultiTenant.with(self) do
                yield
            end
        end

        def bootstrap_data
            as_json(
                only: PUBLIC_ATTRS,
            ).merge(
                bootstrap: system_settings.public_json.merge(
                    Hippo::Extensions.tenant_bootstrap_data(self)
                )
            )
        end

        def self.current
            MultiTenant.current_tenant || system
        end

        def self.system
            find_by(slug: 'system') || create!(
                slug: 'system', name: 'system',
                email: 'contact@argosity.com', subscription: :admin
            )
        end

        def self.switch(condition)
            MultiTenant.current_tenant = self.find_by(condition)
        end

      protected

        def auto_assign_slug
            5.times do |i|
                if slug.blank?
                    newslug = Hippo::Strings.code_identifier(self.name, length: i + 5).downcase
                    self.slug = newslug if Tenant.where(slug: newslug).none?
                end
                break if slug.present?
            end
        end

        def downcase_slug
            self.slug = self.slug.downcase.gsub(/\W/, '')
        end

    end
end
