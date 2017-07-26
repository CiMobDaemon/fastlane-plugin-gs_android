module Fastlane
  module Actions
    class GsAndroidReleaseAction < Action
      def self.run(params)
        version_name = Helper::VersionParser.getRcVersionName(ENV['versionsFilePostfix']) # TODO: it will be better to parse it from GP

        Helper::GooglePlayLoader.update_changelog(ENV['alias'], ENV['app_id'], version_name, 'beta', ENV['locales'], ENV['json_key_file'])

        supply(track: "beta", track_promote_to: "production", skip_upload_apk: true, skip_upload_metadata: true, skip_upload_images: true, skip_upload_screenshots: true)
        #Helper::GsAndroidHelper.gradle_with_params("saveReleaseVersionName", "versionsFilePostfix": ENV["versionsFilePostfix"])
        Helper::VersionWorker.saveReleaseVersionName(ENV["versionsFilePostfix"])
      end

      def self.description
        "Release action"
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
