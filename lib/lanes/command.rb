require 'thor/error'

module Lanes
    module Command
        class << self

            # Reads and returns the contents of a usage file.  Used
            # internally by commands to populate their long_desc
            # @param [String] basename of file to read usage from
            def usage_from_file(file)
                Pathname.new(__FILE__).dirname.join("command","#{file}.usage").read.gsub(/\n/,"\n\x5")
            end

            # Loads the code for the extension that the user is currently
            # working inside.  The `lanes` command uses this to detect
            # what actions should be taken.
            #
            # Will silently swallow any exceptions that are raised when the file is required and return nil
            #
            # @return [Extension] extension that was loaded, nil if none was found
            def load_current_extension(raise_on_fail:false)
                ext = Dir.glob("./lib/*/extension.rb").first
                if ext
                    begin
                        require(ext)
                    rescue =>e
                        stack = e.backtrace[0..4].join("\n")
                        raise Thor::Error.new("Loading ./lib/*/extension.rb failed with: #{e}\n#{stack}")
                    end
                    Extensions.controlling
                else
                    return _maybe_fail(raise_on_fail)
                end
            end

            def _maybe_fail(should_raise)
                raise Thor::Error.new("Unable to locate Lanes environment.\nDoes ./lib/*/extension.rb exist?") if should_raise
                return nil
            end

        end
    end
end
