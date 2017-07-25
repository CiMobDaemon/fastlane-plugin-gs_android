module Fastlane
  module Actions
    class GsAndroidRcAction < Action
      def self.run(params)
				env = params[:ENV]
        #Helper::GsAndroidHelper.gradle_with_params("incrementVersionCode", "versionsFilePostfix": env["versionsFilePostfix"])
				#Helper::GsAndroidHelper.gradle_with_params("incrementRcVersionName", "versionsFilePostfix": env["versionsFilePostfix"])
				version_code = Helper::VersionWorker.incrementVersionCode(env["versionsFilePostfix"], env["build_gradle_file_path"])
				version_name = Helper::VersionWorker.incrementRcVersionName(env["versionsFilePostfix"], env["build_gradle_file_path"], env["general_major_version"])

				loadChangelog(env['alias'], version_name, version_code, env['locales'], env["version_code_prefix"])

				gradle(task: "clean")

				unless env["flavor"].nil?
						 gradle(task: "assemble", flavor: env["flavor"], build_type: "Release")
				else
						 gradle(task: "assemble", build_type: "Release")
				end

				#specially for MapMobile

				obb_main_file_version, obb_main_file_size = Helper::VersionWorker.getMainObbFileInfo(env["versionsFilePostfix"])
				obb_patch_file_version, obb_patch_file_size = Helper::VersionWorker.getPatchObbFileInfo(env["versionsFilePostfix"])

				unless obb_main_file_version.nil?

					#should check if new .obb files appeared (because Fastlane would do the same 12.07.2017)
					apk_file_path = File.dirname(build_gradle_file_path) + '/build/outputs/apk/'
					obb_file_path = "../../../obbFiles/#{env['versionsFilePostfix']}/"

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
						supply(track: "beta", skip_upload_metadata: true, skip_upload_images: true, skip_upload_screenshots: true,
						obb_main_references_version: obb_main_file_version.to_i, obb_main_file_size: obb_main_file_size.to_i,
						obb_patch_references_version: obb_patch_file_version.to_i, obb_patch_file_size: obb_patch_file_size.to_i)

						Helper::VersionWorker.savePatchObbFileInfo(env["versionsFilePostfix"], obb_patch_file_version.to_s, obb_patch_file_size.to_s)
					else
						supply(track: "beta", skip_upload_metadata: true, skip_upload_images: true, skip_upload_screenshots: true,
						obb_main_references_version: obb_main_file_version.to_i, obb_main_file_size: obb_main_file_size.to_i)
					end

					#saving should be here
					#Helper::GsAndroidHelper.gradle_with_params("saveObbFileInfo", "versionsFilePostfix": env["versionsFilePostfix"], "obbType": "main", "obbVersion": obbMainFileVersion.to_s, "obbSize": obbMainFileSize.to_s)
					#Helper::GsAndroidHelper.gradle_with_params("saveObbFileInfo", "versionsFilePostfix": env["versionsFilePostfix"], "obbType": "patch", "obbVersion": obbPatchFileVersion.to_s, "obbSize": obbPatchFileSize.to_s)
					Helper::VersionWorker.saveMainObbFileInfo(env["versionsFilePostfix"], obb_main_file_version.to_s, obb_main_file_size.to_s)
				else
					supply(track: "beta", skip_upload_metadata: true, skip_upload_images: true, skip_upload_screenshots: true)
				end

				#Helper::GsAndroidHelper.gradle_with_params("saveVersionCode", "versionsFilePostfix": env["versionsFilePostfix"])
				#Helper::GsAndroidHelper.gradle_with_params("saveRcVersionName", "versionsFilePostfix": env["versionsFilePostfix"])
				Helper::VersionWorker.saveVersionCode(env["versionsFilePostfix"], env["build_gradle_file_path"])
				Helper::VersionWorker.saveRcVersionName(env["versionsFilePostfix"], env["build_gradle_file_path"])
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
