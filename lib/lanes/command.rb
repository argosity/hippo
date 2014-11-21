module Lanes
    module Command
        class << self

            # Reads and returns the contents of a usage file.  Used
            # internally by commands to populate their long_desc
            # @param [String] basename of file to read usage from
            def usage_from_file(file)
                Pathname.new(__FILE__).dirname.join("command","#{file}.usage").read
            end

            # Loads the code for the extension that the user is currently
            # working inside.  The `lanes` command uses this to detect
            # what actions should be taken.
            #
            # Will silently swallow any exceptions that are raised when the file is required and return nil
            #
            # @return [Extension] extension that was loaded, nil if none was found
            def load_current_extension
                previous = Extensions.all
                ext = Dir.glob("./lib/**/extension.rb").first
                if ext
                    begin
                        require(ext)
                    rescue
                        return nil
                    end
                    diff = Extensions.all - previous
                    return diff.any? ? diff.first.new : nil
                else
                    return nil
                end
            end

        end
    end
end
