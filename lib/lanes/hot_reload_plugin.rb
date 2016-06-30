require 'guard/compat/plugin'
module ::Guard

    class HotReload < Plugin

        def initialize(options = {})
            super
            @uri = URI.parse(
                "http://localhost:#{options[:port]}/file-change.json"
            )
        end

        def run_all
        end

        def asset_to_json(file)
            file.gsub!(/client\//,'')
            if file.match(/\.(js|coffee|cjsx)$/)
                file.gsub!(/(.*)\.(js|coffee|cjsx)$/, '\1.js')
                comp = file.split('/')#[1..-1]
                comp[comp.length-1] = comp.last.gsub(/\.\w+$/,'')
                { "type" => "js", "path" => file, "components" => comp }
            else
                path = if file.match(%r{/screens/.*/\w+\.scss})
                           file.gsub(%r{/\w+.\w*css},'.css')
                       else
                           file
                       end
                { "type" => "css", "path" => path, "trigger" => file }
            end

        end

        def run_on_modifications(paths)
            post = Net::HTTP::Post.new(@uri.request_uri)
            body = paths.map do | file |
                asset_to_json(file)
            end
            post.body = Oj.dump(body)
            http = Net::HTTP.new(@uri.host, @uri.port)
            http.request(post)
        end

    end

end
