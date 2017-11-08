module Fastlane
  module Actions
    class GsAndroidOnErrorAction < Action
      def self.run(params)
        exception = params[:exception]
        begin
          if params[:lane] == :release
            version_name = Helper::VersionWorker.get_rc_version_name(ENV['alias']).ignore_build.to_s
          else
            version_name = Helper::VersionWorker.get_current_version_name(ENV['build_gradle_file_path']).to_s
          end
          message = "#{ENV['project_name']} #{version_name} build has failed. Reason:\n#{exception.message}"
        rescue StandardError => error
          message = "#{ENV['project_name']} build has failed. Reason:\n#{exception.message}\nError block has failed. Reason:\n#{error.message}"
        end
        UI.important(message)
        if params[:options] == nil
          Helper::GsAndroidHelper.send_job_state(ENV['alias'], params[:lane], 'failed', message)
        else
          Helper::GsAndroidHelper.send_job_state(ENV['alias'], params[:lane], 'failed', message, options[:restart_build_url])
        end
      end

      def self.description
        'Action is called to send information about errors'
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
          description: "Fatlane lane",
          optional: false,
          type: Symbol),

          FastlaneCore::ConfigItem.new(key: :exception,
          description: "Exception",
          optional: false,
          type: Object), # TODO: change the type

          FastlaneCore::ConfigItem.new(key: :options,
          description: "Additional options",
          optional: true,
          type: Object)
        ]
      end

      def self.is_supported?(platform)
        platform == :android
      end
    end
  end
end
