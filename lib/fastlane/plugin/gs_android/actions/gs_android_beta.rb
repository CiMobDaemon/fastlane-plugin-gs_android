module Fastlane
  module Actions
    class GsAndroidBetaAction < Action
      def self.run(params)
				Helper::VersionWorker.increment_version_code(ENV['alias'],
																										 ENV['build_gradle_file_path'])
				version_name = Helper::VersionWorker.increment_beta_version_name(ENV['alias'],
                                                                         ENV['build_gradle_file_path'],
                                                                         ENV['general_major_version']).to_s

				Helper::GsAndroidHelper.generate_release_notes('fileBeta', ENV['alias'], version_name, 'Ru')
				Helper::GsAndroidHelper.generate_release_notes('fileBeta', ENV['alias'], version_name, 'En')

				text_ru = Helper::FileHelper.read(Helper::GsAndroidHelper::NOTES_PATH_TEMPLATE % {Dir: Dir.pwd, project_alias: ENV['alias'], version_name: version_name, lang: 'Ru'})
				text_en = Helper::FileHelper.read(Helper::GsAndroidHelper::NOTES_PATH_TEMPLATE % {Dir: Dir.pwd, project_alias: ENV['alias'], version_name: version_name, lang: 'En'})

				require 'date'
				current_time = DateTime.now
				time_string = current_time.strftime '%d.%m.%Y %H : %M'
				crashlytics_changelog = time_string + "\n" + text_ru + "\n\n" + text_en
				UI.message('changelog = ' + crashlytics_changelog)

				Helper::GsAndroidHelper.run_action(Actions::GradleAction,
                                           task: 'clean')

				#Some applications have different apk types. We need only universal (if it exists) apk on crashlytics
				build_type = 'Beta'

				unless ENV['apkType'].nil?
							build_type = ENV['apkType'] + build_type
				end

				if ENV['flavor'].nil?
					Helper::GsAndroidHelper.run_action(Actions::GradleAction,
                                             task: 'assemble',
                                             build_type: build_type)
				else
					Helper::GsAndroidHelper.run_action(Actions::GradleAction,
                                             task: 'assemble',
                                             flavor: ENV['flavor'],
                                             build_type: build_type)
				end

				Helper::GsAndroidHelper.run_action(Actions::CrashlyticsAction,
                                            notes: crashlytics_changelog,
                                            groups: ENV['test_group_for_fabric']
                                          )

				Helper::VersionWorker.save_version_code(ENV['alias'],
                                                ENV['build_gradle_file_path'])
				Helper::VersionWorker.save_beta_version_name(ENV['alias'],
                                                     ENV['build_gradle_file_path'])
      end

      def self.description
        'Beta action'
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
