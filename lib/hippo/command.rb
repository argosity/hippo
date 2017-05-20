require 'thor/error'

module Hippo
    module Command
        class << self

            # Reads and returns the contents of a usage file.  Used
            # internally by commands to populate their long_desc
            # @param [String] basename of file to read usage from
            def usage_from_file(file)
                Pathname.new(__FILE__).dirname.join("command","#{file}.usage").read.gsub(/\n/,"\n\x5")
            end

            def load_current_extension(raise_on_fail:false)
                Hippo::Extensions.bootstrap(raise_on_fail: raise_on_fail)
            end

        end
    end
end
