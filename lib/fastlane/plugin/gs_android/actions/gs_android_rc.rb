module Fastlane
  module Actions
    class GsAndroidRcAction < Action
      def self.run(params)
	UI.message("RcAction with json_key_file = #{ENV['json_key_file']}")

	version_code = Helper::VersionWorker.increment_version_code(ENV['alias'],
	ENV['build_gradle_file_path']).to_s
	version_name = Helper::VersionWorker.increment_rc_version_name(ENV['alias'],
		ENV['build_gradle_file_path'],
	ENV['general_major_version'].to_i).ignore_build.to_s

	Helper::GsAndroidHelper.load_changelog(ENV['alias'],
		version_name,
		version_code,
		ENV['locales'],
	ENV['version_code_prefix'])

	gradle(task: "clean")

	if ENV['flavor'].nil?
		gradle(
		  task: "assemble",
		  build_type: "Release"
		)
	else
		gradle(
		  task: "assemble",
		  flavor: ENV['flavor'],
		  build_type: "Release"
		)
	end

	#specially for MapMobile

	obb_main_file_version, obb_main_file_size = Helper::VersionWorker.get_main_obb_file_info(ENV['alias'])
	obb_patch_file_version, obb_patch_file_size = Helper::VersionWorker.get_patch_obb_file_info(ENV['alias'])

	if obb_main_file_version.nil?
		Helper::GsAndroidHelper.run_action(Actions::SupplyAction,
			track: 'beta',
			skip_upload_metadata: true,
			skip_upload_images: true,
		skip_upload_screenshots: true)
	else

		#should check if new .obb files appeared (because Fastlane would do the same 12.07.2017)
		apk_file_path = File.dirname(ENV['build_gradle_file_path']) + '/build/outputs/apk/'
		obb_file_path = "../../obbFiles/#{ENV['alias']}/"

		search = File.join(obb_file_path, '*.obb')
		paths = Dir.glob(search, File::FNM_CASEFOLD)
		expansion_paths = {}
		paths.each do |path|
			filename = File.basename(path, '.obb')
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
			FileUtils.mv(expansion_paths['main'], apk_file_path + File.basename(expansion_paths['main'], '.obb'))
		end

		if obb_patch_file_version.nil?
			Helper::GsAndroidHelper.run_action(Actions::GsCustomSupply,
				track: 'beta',
				obb_main_references_version: obb_main_file_version.to_i,
			obb_main_file_size: obb_main_file_size.to_i)
		else
			if expansion_paths.key?('patch')
				obb_patch_file_version = version_code
				obb_patch_file_size = File.size(expansion_paths['patch'])
				require 'fileutils.rb'
				FileUtils.mv(expansion_paths['patch'], apk_file_path + File.basename(expansion_paths['patch'], '.obb'))
			end
			Helper::GsAndroidHelper.run_action(Actions::GsCustomSupply,
				track: 'beta',
				obb_main_references_version: obb_main_file_version.to_i,
				obb_main_file_size: obb_main_file_size.to_i,
				obb_patch_references_version: obb_patch_file_version.to_i,
			obb_patch_file_size: obb_patch_file_size.to_i)

			Helper::VersionWorker.save_patch_obb_file_info(ENV['alias'],
				obb_patch_file_version.to_s,
			obb_patch_file_size.to_s)
		end

		#saving should be here
		Helper::VersionWorker.save_main_obb_file_info(ENV['alias'],
			obb_main_file_version.to_s,
		obb_main_file_size.to_s)
	end
	Helper::VersionWorker.save_version_code(ENV['alias'],
	ENV['build_gradle_file_path'])
	Helper::VersionWorker.save_rc_version_name(ENV['alias'],
	ENV['build_gradle_file_path'])


      def self.description
				'Rc action'
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
