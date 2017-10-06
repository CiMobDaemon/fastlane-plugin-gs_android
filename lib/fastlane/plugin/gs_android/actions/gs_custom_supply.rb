module Fastlane
  module Actions
    class GsCustomSupply < Action
      def self.run(params)
        require '../custom_supply'
        Supply.config = params
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
        require '../custom_supply/custom_supply_'
        require '../custom_supply/options'
        CustomSupply::Options.available_options
      end

      def self.is_supported?(platform)
        platform == :android
      end
    end
  end
end