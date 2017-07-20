module Fastlane
  module Actions
    class GsBetaAction < Action
      def self.run(params)
      
      	env = params[:ENV]
      	
        # Increment the build number (not the version number)
		Helper::GsAndroidHelper.gradle_with_params("incrementVersionCode", "versionsFilePostfix": env["versionsFilePostfix"])
		Helper::GsAndroidHelper.gradle_with_params("incrementBetaVersionName", "versionsFilePostfix": env["versionsFilePostfix"])
		text = Helper::FileHelper.read(env['build_gradle_file_path'])
		version_name = text.match(/currentVersionName = '(.*)'/)[1]

		generateReleaseNotes("fileBeta", env['alias'], version_name, "Ru")
		generateReleaseNotes("fileBeta", env['alias'], version_name, "En")

		ruText = Helper::FileHelper.read(Dir.pwd + "/../../../notes/" + env['alias'] + "/" + version_name + "_Ru.txt")
		enText = Helper::FileHelper.read(Dir.pwd + "/../../../notes/" + env['alias'] + "/" + version_name + "_En.txt")

		require 'date'
		current_time = DateTime.now
		time_string = current_time.strftime "%d.%m.%Y %H:%M"
		crashlytics_changelog = time_string + "\n" + ruText + "\n\n" + enText
		UI.message("changelog = " + crashlytics_changelog)

		gradle(task: "clean")

		#Some applications have different apk types. We need only universal (if it exists) apk on crashlytics
		buildType = "Beta"

		unless env["apkType"].nil?
		      buildType = env["apkType"] + buildType
		end

		unless env["flavor"].nil?
		     gradle(task: "assemble", flavor: env["flavor"], build_type: buildType)
		else
		     gradle(task: "assemble", build_type: buildType)
		end

		crashlytics(
		   notes: crashlytics_changelog,
		   groups: params[:test_group_for_fabric]
		)

		Helper::GsAndroidHelper.gradle_with_params("saveVersionCode", "versionsFilePostfix": env["versionsFilePostfix"])
		Helper::GsAndroidHelper.gradle_with_params("saveBetaVersionName", "versionsFilePostfix": env["versionsFilePostfix"])
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
