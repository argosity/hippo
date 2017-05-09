require_relative './webpack_view';

module Hippo
    module Command

        class ClientConfig < Thor::Group
            include Thor::Actions

            attr_reader :directory

            attr_reader :controlling_extension
            attr_reader :hippo_root_path
            attr_reader :extension_path

            attr_reader :module_paths

            ROOT = Pathname.new(__FILE__).dirname.join("..", "..", "..")
            def self.source_root
                ext = Hippo::Extensions.controlling
                ext.root_path
            end

            def apply_hippo_config
                Command.load_current_extension
                Hippo::Configuration.apply
                Hippo::Extensions.load_controlling_config
            end

            def set_vars
                @hippo_root_path = ROOT
                @controlling_extension = Command.load_current_extension(raise_on_fail: true)
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

                Hippo::Extensions.controlling.view_templates.each do |tmpl|
                    tmpl = WebpackView.new(tmpl)
                    tmpl.write
                    # set the mtime to the past, otherwise Webpack will build repeatedly as it starts up
                    FileUtils.touch tmpl.destination.to_s, mtime: Time.now - 10.minute
                end

                template('config/webpack.config.js',
                         directory.join('webpack.config.js'), opts)
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