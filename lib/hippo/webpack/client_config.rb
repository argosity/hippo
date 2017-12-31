require 'thor'
require 'active_support'

module Hippo
    class Webpack
        class ClientConfig < Thor::Group
            include Thor::Actions

            attr_reader :directory

            attr_reader :controlling_extension
            attr_reader :hippo_root_path
            attr_reader :extension_path

            attr_reader :module_paths

            ROOT = Pathname.new(__FILE__).dirname.join('..', '..', '..')

            def self.source_root
                Hippo.config.apply
                Hippo::Extensions.load_controlling_config
                Hippo::Extensions.controlling.root_path
            end

            def set_vars
                @controlling_extension = Hippo::Extensions.controlling
                @hippo_root_path = ROOT
                @extension_path = controlling_extension.root_path
            end

            def make_temp_dir
                @directory = controlling_extension.root_path.join('tmp')
                @directory.mkdir unless @directory.exist?
            end

            def set_module_paths
                @module_paths = Extensions.map { |e| e.root_path.join('client').to_s }.reverse + [
                    controlling_extension.root_path.join('node_modules').to_s,
                    directory.to_s
                ]
            end

            def write_asset_files
                say "Generating config in #{directory}", :green
                opts = { verbose: false, force: true }
                template('config/jest.config.json',
                         directory.join('jest.config.json'), opts)
                template(ROOT.join('templates','js', 'config-data.js'),
                         directory.join('hippo/config-data.js'), opts)
                template(ROOT.join('templates','js', 'screen-definitions.js'),
                         directory.join('hippo/screen-definitions.js'), opts)
            end
        end
    end
end
