module Fastlane
  module Actions
    class GsBetaAction < Action
      def self.run(params)
      
      	ENV = params[:ENV]
      	
        # Increment the build number (not the version number)
		gradleWithParam("incrementVersionCode", "versionsFilePostfix": ENV["versionsFilePostfix"])
		gradleWithParam("incrementBetaVersionName", "versionsFilePostfix": ENV["versionsFilePostfix"])
		text = Helper::FileHelper.read(ENV['build_gradle_file_path'])
		version_name = text.match(/currentVersionName = '(.*)'/)[1]

		generateReleaseNotes("fileBeta", ENV['alias'], version_name, "Ru")
		generateReleaseNotes("fileBeta", ENV['alias'], version_name, "En")

		ruText = Helper::FileHelper.read(Dir.pwd + "/../../../notes/" + ENV['alias'] + "/" + version_name + "_Ru.txt")
		enText = Helper::FileHelper.read(Dir.pwd + "/../../../notes/" + ENV['alias'] + "/" + version_name + "_En.txt")

		require 'date'
		current_time = DateTime.now
		time_string = current_time.strftime "%d.%m.%Y %H:%M"
		crashlytics_changelog = time_string + "\n" + ruText + "\n\n" + enText
		UI.message("changelog = " + crashlytics_changelog)

		gradle(task: "clean")

		#Some applications have different apk types. We need only universal (if it exists) apk on crashlytics
		buildType = "Beta"

		unless ENV["apkType"].nil?
		      buildType = ENV["apkType"] + buildType
		end

		unless ENV["flavor"].nil?
		     gradle(task: "assemble", flavor: ENV["flavor"], build_type: buildType)
		else
		     gradle(task: "assemble", build_type: buildType)
		end

		crashlytics(
		   notes: crashlytics_changelog,
		   groups: params[:test_group_for_fabric]
		)

		Helper::GsAndroidHelper.gradleWithParam("saveVersionCode", "versionsFilePostfix": ENV["versionsFilePostfix"])
		Helper::GsAndroidHelper.gradleWithParam("saveBetaVersionName", "versionsFilePostfix": ENV["versionsFilePostfix"])
      end

      def self.description
        "Beta action"
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
