module Fastlane
  module Actions
    class GsAndroidReleaseAction < Action
      def self.run(params)
        version_name = Helper::VersionWorker.get_rc_version_name(ENV['alias']).normalized_name
        Helper::GooglePlayLoader.update_changelog(ENV['alias'], ENV['app_id'], version_name, 'beta', ENV['locales'], ENV['json_key_file'])

        Helper::GsAndroidHelper.run_action(Actions::SupplyAction, track: "beta", track_promote_to: "production", skip_upload_apk: true, skip_upload_metadata: true, skip_upload_images: true, skip_upload_screenshots: true)
        Helper::VersionWorker.save_release_version_name(ENV["alias"])
      end

      def self.description
        "Release action"
      end

      def self.authors
        ["Dmitry Ulyanov"]
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
