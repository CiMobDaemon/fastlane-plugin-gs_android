module Fastlane
  module Actions
    class GsAndroidRcAction < Action
      def self.run(params)
      
      	env = params[:ENV]
      	
        Helper::GsAndroidHelper.gradle_with_params("incrementVersionCode", "versionsFilePostfix": env["versionsFilePostfix"])
		Helper::GsAndroidHelper.gradle_with_params("incrementRcVersionName", "versionsFilePostfix": env["versionsFilePostfix"])
		text = Helper::FileHelper.read(build_gradle_file_path)
		version_name = text.match(/currentVersionName = '(.*)'/)[1]
		version_code = text.match(/versionCode (.*)/)[1]
		
		loadChangelog(env['alias'], version_name, version_code, env['locales'], env["version_code_prefix"])

		gradle(task: "clean")

		unless env["flavor"].nil?
		     gradle(task: "assemble", flavor: env["flavor"], build_type: "Release")
		else
		     gradle(task: "assemble", build_type: "Release")
		end
	
		#specially for MapMobile
		versionsFileText = File.read("../../../versionsFiles/versions#{env['versionsFilePostfix']}.txt")

		obbMainFileVersionSearch = versionsFileText.match("mainObbFileVersion = (\\d+)")
		obbPatchFileVersionSearch = versionsFileText.match("patchObbFileVersion = (\\d+)")
		obbMainFileSizeSearch = versionsFileText.match("mainObbFileSize = (\\d+)")
		obbPatchFileSizeSearch = versionsFileText.match("patchObbFileSize = (\\d+)")

		unless obbMainFileVersionSearch.nil?

		  #should check if new .obb files appeared (because Fastlane would do the same 12.07.2017)
		  apkFilePath = File.dirname(build_gradle_file_path) + '/build/outputs/apk/'
		  obbFilePath = "../../../obbFiles/#{env['versionsFilePostfix']}/"

		  search = File.join(obbFilePath, '*.obb')
		  paths = Dir.glob(search, File::FNM_CASEFOLD)
		  expansionPaths = {}
		  paths.each do |path|
		    filename = File.basename(path, ".obb")
		    if filename.include?('main')
		      type = 'main'
		    elsif filename.include?('patch')
		      type = 'patch'
		    end
		    expansionPaths[type] = path
		  end

		  obbMainFileVersion = obbMainFileVersionSearch[1]
		  obbMainFileSize = obbMainFileSizeSearch[1]
		  if expansionPaths.key?('main')
		    obbMainFileVersion = version_code
		    obbMainFileSize = File.size(expansionPaths['main'])
		    require 'fileutils.rb'
		    FileUtils.mv(expansionPaths['main'], apkFilePath + File.basename(expansionPaths['main'], ".obb"))
		  end

		  unless obbPatchFileVersionSearch.nil?
		    obbPatchFileVersion = obbPatchFileVersionSearch[1]
		    obbPatchFileSize = obbPatchFileSizeSearch[1]
		    if expansionPaths.key?('patch')
		      obbPatchFileVersion = version_code
		      obbPatchFileSize = File.size(expansionPaths['patch'])
		      require 'fileutils.rb'
		      FileUtils.mv(expansionPaths['patch'], apkFilePath + File.basename(expansionPaths['patch'], ".obb"))
		    end
		    supply(track: "beta", skip_upload_metadata: true, skip_upload_images: true, skip_upload_screenshots: true,
		    obb_main_references_version: obbMainFileVersion.to_i, obb_main_file_size: obbMainFileSize.to_i,
		    obb_patch_references_version: obbPatchFileVersion.to_i, obb_patch_file_size: obbPatchFileSize.to_i)
		  else
		    supply(track: "beta", skip_upload_metadata: true, skip_upload_images: true, skip_upload_screenshots: true,
		    obb_main_references_version: obbMainFileVersion.to_i, obb_main_file_size: obbMainFileSize.to_i)
		  end

		  #saving should be here
		  Helper::GsAndroidHelper.gradle_with_params("saveObbFileInfo", "versionsFilePostfix": env["versionsFilePostfix"], "obbType": "main", "obbVersion": obbMainFileVersion.to_s, "obbSize": obbMainFileSize.to_s)
		  Helper::GsAndroidHelper.gradle_with_params("saveObbFileInfo", "versionsFilePostfix": env["versionsFilePostfix"], "obbType": "patch", "obbVersion": obbPatchFileVersion.to_s, "obbSize": obbPatchFileSize.to_s)
		else
		  supply(track: "beta", skip_upload_metadata: true, skip_upload_images: true, skip_upload_screenshots: true)
		end

		Helper::GsAndroidHelper.gradle_with_params("saveVersionCode", "versionsFilePostfix": env["versionsFilePostfix"])
		Helper::GsAndroidHelper.gradle_with_params("saveRcVersionName", "versionsFilePostfix": env["versionsFilePostfix"])
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
