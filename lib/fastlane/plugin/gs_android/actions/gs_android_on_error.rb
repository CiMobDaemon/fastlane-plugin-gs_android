module Fastlane
  module Actions
    class GsAndroidOnErrorAction < Action
      def self.run(params)
      	env = params[:ENV]
      	exception = params[:exception]
      
      	text = Helper::FileHelper.read(env["build_gradle_file_path"])
		version_name = text.match(/currentVersionName = '(.*)'/)[1]
		if params[:lane] == :release
		 versionsFileText = File.read("../../../versionsFiles/versions" + env['versionsFilePostfix'] + ".txt")
		 version_name = versionsFileText.match("releaseVersionName = '(\\d+\\.\\d+\\.?\\d*)'")[1]
		end

		message = env["project_name"] + " " + version_name + " build has failed. Reason:\n" + params[:exception].message

		UI.important(message)

		Helper::GsAndroidHelper.sendJobState(env['alias'], params[:lane], 'failed', message)
      end

      def self.description
        "Action is called to send information about errors"
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
          type: Hash),
          
          FastlaneCore::ConfigItem.new(key: :lane,
          description: "Fatlane lane",
          optional: false,
          type: Symbol),
          
          FastlaneCore::ConfigItem.new(key: :exception,
          description: "Exception",
          optional: false,
          type: Object)
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
