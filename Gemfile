source 'https://rubygems.org'

gemspec

gem "activerecord-multi-tenant", git: 'https://github.com/citusdata/activerecord-multi-tenant.git', branch: 'release-0.5.1'

# gem "activerecord-multi-tenant", git: "https://github.com/nathanstitt/activerecord-multi-tenant", branch: 'query_rewriter'

# gem "webpack_driver", git: "https://github.com/nathanstitt/webpack_driver", branch: 'master'

group :development, :test do
    gem "yard-activerecord",
        git: 'https://github.com/nathanstitt/yard-activerecord',
        branch: 'develop'

    gem "temping", '~> 3.9.0'

    gem 'puma'
    gem 'pry-byebug'
#    gem "guard-jest", git: "https://github.com/nathanstitt/guard-jest", branch: 'master'
    gem "bump"
end
