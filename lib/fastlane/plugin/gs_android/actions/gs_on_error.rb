module Fastlane
  module Actions
    class GsOnErrorAction < Action
      def self.run(params)
      	ENV = params[:ENV]
      
      	text = FileHelper.read(ENV["build_gradle_file_path"])
		version_name = text.match(/currentVersionName = '(.*)'/)[1]
		if params[:lane] == :release
		 versionsFileText = File.read("../../../versionsFiles/versions" + ENV['versionsFilePostfix'] + ".txt")
		 version_name = versionsFileText.match("releaseVersionName = '(\\d+\\.\\d+\\.?\\d*)'")[1]
		end

		message = ENV["project_name"] + " " + version_name + " build has failed. Reason:\n" + params[:exception].message

		UI.important(message)

		sendJobState(ENV['alias'], params[:lane], 'failed', message)
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
          type: String),
          
          FastlaneCore::ConfigItem.new(key: :exception,
          description: "Fatlane exception",
          optional: false,
          type: Exception)
        ]
      end

      def self.is_supported?(platform)
        # Adjust this if your plugin only works for a particular platform (iOS vs. Android, for example)
        # See: https://github.com/fastlane/fastlane/blob/master/fastlane/docs/Platforms.md

        [:android,].include?(platform)
      end
