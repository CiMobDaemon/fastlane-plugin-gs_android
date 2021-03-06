module Fastlane
  module Actions
    class GsAndroidReleaseAction < Action
      def self.run(params)
        UI.message('ReleaseAction started for ' + ENV['alias'])
        Helper::GsAndroidHelper.run_action(Actions::SupplyAction,
                                           track: 'beta',
                                           track_promote_to: 'production',
                                           skip_upload_apk: true,
                                           skip_upload_metadata: true,
                                           skip_upload_images: true,
                                           skip_upload_screenshots: true,
                                           skip_upload_changelogs:true)
        version_name = Helper::VersionWorker.get_rc_version_name(ENV['alias']).ignore_build.to_s
        UI.message('SupplyAction complete. Start update_changelog for version_name = ' + version_name)        
        Helper::GooglePlayLoader.update_changelog(ENV['alias'],
                                                  ENV['app_id'],
                                                  version_name,
                                                  'production',
                                                  ENV['locales'],
                                                  ENV['json_key_file'])
        UI.message('call save_release_version_name')        
        Helper::VersionWorker.save_release_version_name(ENV['alias'])
      end

      def self.description
        'Release action'
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
