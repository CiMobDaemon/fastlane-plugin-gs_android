module Fastlane
  module Helper
    class FileHelper
      def self.read(path)
        file = File.open(path, "r+")
        res = file.read
        file.close
        res
      end
      def self.write(path, str)
          require 'fileutils.rb'
          FileUtils.makedirs(File.dirname(path))
          file = File.open(path, "w+")
          file.write(str)
          file.close
      end
    end
  end
end
