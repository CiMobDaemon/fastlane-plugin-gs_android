module Fastlane
  module Actions
    class GsAndroidAction < Action
      def self.run(params)
        UI.message(Dir.pwd)
      end

      def self.description
        "Plugin for GS android projects"
      end

      def self.authors
        ["Dmitry Ulyanov"]
      end

      def self.return_value
      end

      def self.details
        # Optional:
        "Plugin for GS android projects"
      end

      def self.available_options
        [
          # FastlaneCore::ConfigItem.new(key: :your_option,
          #                         env_name: "GS_ANDROID_YOUR_OPTION",
          #                      description: "A description of your option",
          #                         optional: false,
          #                             type: String)
        ]
      end

      def self.is_supported?(platform)        #
        # [:ios, :mac, :android].include?(platform)
        true
      end
    end
  end
end
