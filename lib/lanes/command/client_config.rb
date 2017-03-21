module Lanes
    module Command

        class ClientConfig < Thor::Group
            include Thor::Actions

            attr_reader :directory

            attr_reader :controlling_extension
            attr_reader :lanes_root_path
            attr_reader :extension_path

            attr_reader :module_paths

            ROOT = Pathname.new(__FILE__).dirname.join("..", "..", "..")
            def self.source_root
                ext = Lanes::Extensions.controlling
                ext.root_path.join('config')
            end

            def apply_lanes_config
                Lanes::Configuration.apply
                Lanes::Extensions.load_controlling_config
            end

            def set_vars
                @lanes_root_path = ROOT
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
                template('index.html',
                         directory.join('index.html'), opts)
                template('webpack.config.js',
                         directory.join('webpack.config.js'), opts)
                template('jest.config.json',
                         directory.join('jest.config.json'), opts)
                template(ROOT.join('templates','js', 'screens.js'),
                         directory.join('lanes/screen-definitions.js'), opts)
                # set the mtime to the past, otherwise Webpack will build repeatedly as it starts up
                FileUtils.touch directory.join('index.html').to_s, mtime: Time.now - 10.minute
            end
        end
    end
end
