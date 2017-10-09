module Fastlane
  module CustomSupply
      class << self
        attr_accessor :config
      end
      CHANGELOGS_FOLDER_NAME = "changelogs"
  end
end