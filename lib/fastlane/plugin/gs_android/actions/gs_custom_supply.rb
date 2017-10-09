module Fastlane
  module Actions
    class GsCustomSupply < Action
      def self.run(params)
        # If no APK params were provided, try to fill in the values from lane context, preferring
        # the multiple APKs over the single APK if set.
        if params[:apk_paths].nil? && params[:apk].nil?
          all_apk_paths = Actions.lane_context[SharedValues::GRADLE_ALL_APK_OUTPUT_PATHS] || []
          if all_apk_paths.size > 1
            params[:apk_paths] = all_apk_paths
          else
            params[:apk] = Actions.lane_context[SharedValues::GRADLE_APK_OUTPUT_PATH]
          end
        end
        CustomSupply::config = params
        CustomSupply::GooglePlayUploader.new.perform_upload
      end

      def self.description
        'Custom google play uploader for projects with OBB files'
      end

      def self.authors
        ['Dmitry Ulyanov']
      end

      def self.return_value
      end

      def self.details
      end

      def self.available_options
        # require '../custom_supply/custom_supply'
        # require '../custom_supply/options'
        CustomSupply::Options.available_options
      end

      def self.is_supported?(platform)
        platform == :android
      end
    end
  end
end