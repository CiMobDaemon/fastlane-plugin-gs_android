module Fastlane
  module Actions
    class GsAndroidBeforeAllAction < Action
      def self.run(params)
        #create AppFile because Fastlane cannot work with different Appfiles
        system ('rm -rf Appfile')
        Helper::FileHelper.write(Dir.pwd + '/Appfile', "json_key_file \"#{ENV['json_key_file']}\"\npackage_name \"#{ENV['app_id']}\"")
        unless ENV['metadata_dir'].nil?
          UI.message('metadata dir will be replaced by '+ENV['metadata_dir'])
          system ('rm -rf fastlane/metadata')
          system ("mv fastlane/#{ENV['metadata_dir']} fastlane/metadata")
        end
      end

      def self.description
        'Action to create Appfile and move metadata before lanes'
      end

      def self.authors
        ['Dmitry Ulyanov']
      end

      def self.return_value
      end

      def self.details
      end

      def self.available_options
        []
      end

      def self.is_supported?(platform)
        platform == :android
      end
    end
  end
end
