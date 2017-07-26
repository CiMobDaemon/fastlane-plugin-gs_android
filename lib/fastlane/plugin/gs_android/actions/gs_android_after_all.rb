module Fastlane
  module Actions
    class GsAndroidAfterAllAction < Action
      def self.run(params)
        if params[:lane] == :release
          version_name = Helper::VersionWorker.getReleaseVersionName(ENV['versionsFilePostfix']).to_s
				else
					version_name = Helper::VersionWorker.getCurrentVersionName(ENV['build_gradle_file_path']).to_s
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
					build_number = Helper::VersionWorker.getRcVersionName(ENV['versionsFilePostfix']).build_number
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
					 gs_execute_command(options)
					 Helper::GsAndroidHelper.sendJobState(ENV['alias'], params[:lane], 'successful')
				end
      end

      def self.description
        'Action is called to cal bot command and send information about success'
      end

      def self.authors
        ['Dmitry Ulyanov']
      end

      def self.return_value
        # If your method provides a return value, you can describe here what it does
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
        # Adjust this if your plugin only works for a particular platform (iOS vs. Android, for example)
        # See: https://github.com/fastlane/fastlane/blob/master/fastlane/docs/Platforms.md

        [:android,].include?(platform)
      end
    end
  end
end
