module Fastlane
  module Actions
    class GsAfterAllAction < Action
      def self.run(params)
      	env = params[:ENV]
      
      	text = Helper::FileHelper.read(build_gradle_file_path)
		version_name = text.match(/currentVersionName = '(.*)'/)[1]

		cmd = ""
		options = {}
		if params[:lane] == :beta
		   cmd = "beta"
		   options = {cmd:cmd,
		      displayVersionName:version_name,
		      request: "cmd",
		      alias: env["alias"]
		   }
		elsif params[:lane] == :rc
			versionsFileText = File.read("../../../versionsFiles/versions" + env['versionsFilePostfix'] + ".txt")
			buildNumber = versioghsnsFileText.match("rcVersionName = '\\d+.\\d+\\((\\d+)\\)'")[1]
		    cmd = "mv2rc"
		    options = {cmd:cmd,
		       displayVersionName:version_name,
		       request: "cmd",
		       alias: env["alias"],
		       buildNumber: buildNumber
		    }
		elsif params[:lane] == :release
		    versionsFileText = File.read("../../../versionsFiles/versions" + env['versionsFilePostfix'] + ".txt")
		    cmd = "rc2release"
		    options = {cmd:cmd,
		       displayVersionName:versionsFileText.match("releaseVersionName = '(\\d+\\.\\d+\\.?\\d*)'")[1],
		       request: "cmd",
		       alias: env["alias"]
		    }
		end
		if cmd != ""
		   gs_execute_command(options)
		end
		Helper::GsAndroidHelper.sendJobState(env["alias"], params[:lane], 'successful')
      end

      def self.description
        "Action is called to cal bot command and send information about success"
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
          type: String)
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
