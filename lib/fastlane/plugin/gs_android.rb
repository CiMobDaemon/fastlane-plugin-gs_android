require 'fastlane/plugin/gs_android/version'

module Fastlane
  module GsAndroid
    def self.all_classes
      Dir[File.expand_path('**/{actions,helper,custom_supply}/*.rb', File.dirname(__FILE__))]
    end
  end
end

# By default we want to import all available actions and helpers
# A plugin can contain any number of actions and plugins
Fastlane::GsAndroid.all_classes.each do |current|
  require current
end
