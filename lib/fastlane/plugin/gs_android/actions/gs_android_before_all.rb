module Fastlane
  module Actions
    class GsAndroidBeforeAllAction < Action
      def self.run(params)
        #create AppFile because Fastlane cannot work with different Appfiles
        Helper::FileHelper.write(Dir.pwd + '/Appfile', "json_key_file \"#{ENV['json_key_file']}\"\npackage_name \"#{ENV['app_id']}\"")
        unless ENV["metadata_dir"].nil?
          system ("rm -rf metadata")
          system ("mv #{ENV["metadata_dir"]} metadata")
          UI.important("Use custom ITC metadata.")
        end
      end

      def self.description
        "Action to create Appfile and move metadata before lanes"
      end

      def self.authors
        ["Dmitry Ulyanov"]
      end

      def self.return_value
        # If your method provides a return value, you can describe here what it does
      end

      def self.details
      end

      def self.available_options
        []
      end

      def self.is_supported?(platform)
        # Adjust this if your plugin only works for a particular platform (iOS vs. Android, for example)
        # See: https://github.com/fastlane/fastlane/blob/master/fastlane/docs/Platforms.md

        [:android,].include?(platform)
      end
    end
  end
end
