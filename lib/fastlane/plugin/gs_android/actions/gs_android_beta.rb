module Fastlane
  module Actions
    class GsAndroidBetaAction < Action
      def self.run(params)
        # Increment the build number (not the version number)
		#Helper::GsAndroidHelper.gradle_with_params("incrementVersionCode", "versionsFilePostfix": ENV["versionsFilePostfix"])
		#Helper::GsAndroidHelper.gradle_with_params("incrementBetaVersionName", "versionsFilePostfix": ENV["versionsFilePostfix"])
		Helper::VersionWorker.incrementVersionCode(ENV["versionsFilePostfix"], ENV["build_gradle_file_path"])
		version_name = Helper::VersionWorker.incrementBetaVersionName(ENV["versionsFilePostfix"], ENV["build_gradle_file_path"], ENV["general_major_version"]).to_s

		Helper::GsAndroidHelper.generate_release_notes("fileBeta", ENV['alias'], version_name, "Ru")
		Helper::GsAndroidHelper.generate_release_notes("fileBeta", ENV['alias'], version_name, "En")

		ruText = Helper::FileHelper.read(Helper::GsAndroidHelper::NOTES_PATH_TEMPLATE % {Dir: Dir.pwd, project_alias: ENV['alias'], version_name: version_name, lang: 'Ru'})
		enText = Helper::FileHelper.read(Helper::GsAndroidHelper::NOTES_PATH_TEMPLATE % {Dir: Dir.pwd, project_alias: ENV['alias'], version_name: version_name, lang: 'En'})

		require 'date'
		current_time = DateTime.now
		time_string = current_time.strftime "%d.%m.%Y %H:%M"
		crashlytics_changelog = time_string + "\n" + ruText + "\n\n" + enText
		UI.message("changelog = " + crashlytics_changelog)

		Helper::GsAndroidHelper.run_action(Actions::GradleAction, task: "clean")

		#Some applications have different apk types. We need only universal (if it exists) apk on crashlytics
		buildType = "Beta"

		unless ENV["apkType"].nil?
					buildType = ENV["apkType"] + buildType
		end

		unless ENV["flavor"].nil?
			Helper::GsAndroidHelper.run_action(Actions::GradleAction, task: "assemble", flavor: ENV["flavor"], build_type: buildType)
		else
			Helper::GsAndroidHelper.run_action(Actions::GradleAction, task: "assemble", build_type: buildType)
		end

		Helper::GsAndroidHelper.run_action(Actions::CrashlyticsAction,
			notes: crashlytics_changelog,
			groups: ENV['test_group_for_fabric']
		)

		#Helper::GsAndroidHelper.gradle_with_params("saveVersionCode", "versionsFilePostfix": ENV["versionsFilePostfix"])
		#Helper::GsAndroidHelper.gradle_with_params("saveBetaVersionName", "versionsFilePostfix": ENV["versionsFilePostfix"])
		Helper::VersionWorker.saveVersionCode(ENV["versionsFilePostfix"], ENV["build_gradle_file_path"])
		Helper::VersionWorker.saveBetaVersionName(ENV["versionsFilePostfix"], ENV["build_gradle_file_path"])
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
