module Lanes

    class Asset < Lanes::Model

        mount_uploader :file, Lanes::Concerns::AssetUploader

        belongs_to :owner, polymorphic: true

        validates :owner,  set: true

        after_update :remove_changed_file, if: lambda{ file_changed? }

        def serializable_hash(options = nil)
            values = super
            values.delete('file')
            values.merge!(file.as_json[:file].stringify_keys)
            values['original'] = { 'url' => values.delete('url') }
            values
        end

        def store_uploaded_file(f)
            ext = File.extname(f[:filename])
            if ext.blank?
                ext = '.' + FastImage.type(f[:tempfile]).to_s
            end
            self[:file] = ::Lanes::Strings.random + ext
            file.store!(f)
        end

        protected

        def remove_changed_file
            self.file_was.remove!
        end

    end

end
