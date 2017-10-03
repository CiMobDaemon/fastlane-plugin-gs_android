module Fastlane
  module Actions
    class GsAndroidRcAction < Action
      def self.run(params)
				version_code = Helper::VersionWorker.increment_version_code(ENV["alias"], ENV["build_gradle_file_path"]).to_s
				version_name = Helper::VersionWorker.increment_rc_version_name(ENV["alias"], ENV["build_gradle_file_path"], ENV["general_major_version"].to_i).to_s

				Helper::GsAndroidHelper.loadChangelog(ENV['alias'], version_name, version_code, ENV['locales'], ENV["version_code_prefix"])

				Helper::GsAndroidHelper.run_action(Actions::GradleAction, task: "clean")

				if ENV["flavor"].nil?
					Helper::GsAndroidHelper.run_action(Actions::GradleAction, task: "assemble", build_type: "Release")
				else
					Helper::GsAndroidHelper.run_action(Actions::GradleAction, task: "assemble", flavor: ENV["flavor"], build_type: "Release")
				end

				#specially for MapMobile

				obb_main_file_version, obb_main_file_size = Helper::VersionWorker.get_main_obb_file_info(ENV["alias"])
				obb_patch_file_version, obb_patch_file_size = Helper::VersionWorker.get_patch_obb_file_info(ENV["alias"])

				unless obb_main_file_version.nil?

					#should check if new .obb files appeared (because Fastlane would do the same 12.07.2017)
					apk_file_path = File.dirname(build_gradle_file_path) + '/build/outputs/apk/'
					obb_file_path = "../../obbFiles/#{ENV['versionsFilePostfix']}/"

					search = File.join(obb_file_path, '*.obb')
					paths = Dir.glob(search, File::FNM_CASEFOLD)
					expansion_paths = {}
					paths.each do |path|
						filename = File.basename(path, ".obb")
						if filename.include?('main')
							type = 'main'
							expansion_paths[type] = path
						elsif filename.include?('patch')
							type = 'patch'
							expansion_paths[type] = path
						end
					end

					if expansion_paths.key?('main')
						obb_main_file_version = version_code
						obb_main_file_size = File.size(expansion_paths['main'])
						require 'fileutils.rb'
						FileUtils.mv(expansion_paths['main'], apk_file_path + File.basename(expansion_paths['main'], ".obb"))
					end

					unless obb_patch_file_version.nil?
						if expansion_paths.key?('patch')
							obb_patch_file_version = version_code
							obb_patch_file_size = File.size(expansion_paths['patch'])
							require 'fileutils.rb'
							FileUtils.mv(expansion_paths['patch'], apk_file_path + File.basename(expansion_paths['patch'], ".obb"))
						end
						Helper::GsAndroidHelper.run_action(Actions::SupplyAction,track: "beta", skip_upload_metadata: true, skip_upload_images: true, skip_upload_screenshots: true,
						obb_main_references_version: obb_main_file_version.to_i, obb_main_file_size: obb_main_file_size.to_i,
						obb_patch_references_version: obb_patch_file_version.to_i, obb_patch_file_size: obb_patch_file_size.to_i)

						Helper::VersionWorker.save_patch_obb_file_info(ENV["alias"], obb_patch_file_version.to_s, obb_patch_file_size.to_s)
					else
						Helper::GsAndroidHelper.run_action(Actions::SupplyAction,track: "beta", skip_upload_metadata: true, skip_upload_images: true, skip_upload_screenshots: true,
						obb_main_references_version: obb_main_file_version.to_i, obb_main_file_size: obb_main_file_size.to_i)
					end

					#saving should be here
					Helper::VersionWorker.save_main_obb_file_info(ENV["alias"], obb_main_file_version.to_s, obb_main_file_size.to_s)
				else
					Helper::GsAndroidHelper.run_action(Actions::SupplyAction, track: "beta", skip_upload_metadata: true, skip_upload_images: true, skip_upload_screenshots: true)
				end
				Helper::VersionWorker.save_version_code(ENV["alias"], ENV["build_gradle_file_path"])
				Helper::VersionWorker.save_rc_version_name(ENV["alias"], ENV["build_gradle_file_path"])
      end

      def self.description
        "Rc action"
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
