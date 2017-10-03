module Fastlane
  module Actions
    class GsAndroidOnErrorAction < Action
      def self.run(params)
        exception = params[:exception]
        begin
          if params[:lane] == :release
            version_name = Helper::VersionWorker.get_rc_version_name(ENV['alias']).normalized_name
          else
            version_name = Helper::VersionWorker.get_current_version_name(ENV['build_gradle_file_path']).to_s
          end
          message = "#{ENV['project_name']} #{version_name} build has failed. Reason:\n#{exception.message}"
        rescue StandardError => error
          message = "#{ENV['project_name']} build has failed. Reason:\n#{exception.message}\nError block has failed. Reason:\n#{error.message}"
        end
        UI.important(message)
        Helper::GsAndroidHelper.send_job_state(ENV['alias'], params[:lane], 'failed', message)
      end

      def self.description
        'Action is called to send information about errors'
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
          description: "Fatlane lane",
          optional: false,
          type: Symbol),

          FastlaneCore::ConfigItem.new(key: :exception,
          description: "Exception",
          optional: false,
          type: Object) # TODO: change the type
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
