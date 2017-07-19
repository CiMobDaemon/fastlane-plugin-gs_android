module Fastlane
  module Actions
    class GsReleaseAction < Action
      def self.run(params)
      
      	ENV = params[:ENV]
      	
        versionsFileText = File.read("../../../versionsFiles/versions" + ENV['versionsFilePostfix'] + ".txt")
		version_name = versionsFileText.match("rcVersionName = '(\\d+.\\d+)\\(\\d+\\)'")[1]
		
	  	updateChangelogOnGooglePlay(ENV['alias'], ENV['app_id'], version_name, 'beta', ENV['locales'], ENV['json_key_file'])
	  	
		supply(track: "beta", track_promote_to: "production", skip_upload_apk: true, skip_upload_metadata: true, skip_upload_images: true, skip_upload_screenshots: true)    
		Helper::GsAndroidHelper.gradleWithParam("saveReleaseVersionName", "versionsFilePostfix": ENV["versionsFilePostfix"])
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
        [          
          FastlaneCore::ConfigItem.new(key: :ENV,
          description: "Fatlane enviroment",
          optional: false,
          type: Hash)
        ]
      end

      def self.is_supported?(platform)
        # Adjust this if your plugin only works for a particular platform (iOS vs. Android, for example)
        # See: https://github.com/fastlane/fastlane/blob/master/fastlane/docs/Platforms.md

        [:android,].include?(platform)
      end
    end
  end
end
