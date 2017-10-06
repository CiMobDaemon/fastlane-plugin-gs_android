module Fastlane
  module Actions
    class GsAndroidAfterAllAction < Action
      def self.run(params)
        if params[:lane] == :release
          version_name = Helper::VersionWorker.get_release_version_name(ENV['alias']).to_s
				else
					version_name = Helper::VersionWorker.get_current_version_name(ENV['build_gradle_file_path']).to_s
				end

				cmd = nil
				options = {}
				if params[:lane] == :beta
					 cmd = 'beta'
					 options = {cmd: cmd,
							displayVersionName: version_name,
							request: 'cmd',
							alias: ENV['alias']
					 }
				elsif params[:lane] == :rc
					build_number = Helper::VersionWorker.get_rc_version_name(ENV['alias']).build_number
						cmd = 'mv2rc'
						options = {cmd: cmd,
							 displayVersionName: version_name,
							 request: 'cmd',
							 alias: ENV['alias'],
							 buildNumber: build_number
						}
				elsif params[:lane] == :release
						cmd = 'rc2release'
						options = {cmd: cmd,
							 displayVersionName: version_name,
							 request: 'cmd',
							 alias: ENV['alias']
						}
				end
				unless cmd.nil?
					 Helper::GsAndroidHelper.run_action(Actions::GsExecuteCommandAction, options)
					 Helper::GsAndroidHelper.send_job_state(ENV['alias'], params[:lane], 'successful')
				end
      end

      def self.description
        'Action is called to cal bot command and send information about success'
      end

      def self.authors
        ['Dmitry Ulyanov']
      end

      def self.return_value
      end

      def self.details
      end

      def self.available_options
        [
					FastlaneCore::ConfigItem.new(key: :lane,
          description: 'Fatlane lane',
          optional: false,
          type: Symbol)
        ]
      end

      def self.is_supported?(platform)
        platform == :android
      end
    end
  end
end
