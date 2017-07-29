module Fastlane
  module Helper
    class VersionParser

      VERSION_CODE_NAME = 'versionCode'
      BETA_VERSION_NAME = 'betaVersionName'
      RC_VERSION_NAME = 'rcVersionName'
      RELEASE_VERSION_NAME = 'releaseVersionName'

      GRADLE_VERSION_NAME = 'currentVersionName'

      OBB_MAIN_NAMES = {version: 'mainObbFileVersion', size: 'mainObbFileSize'}
      OBB_PATCH_NAMES = {version: 'patchObbFileVersion', size: 'patchObbFileSize'}

      VERSION_TEMPLATE = "%{name} ?=? ?'?(\\d+\\.\\d+\\.?\\d*\\(?\\d*\\)?)'?"

      def self.parseVersion(path, version_name)
        versions_text = FileHelper.read(path.to_s)
        version = versions_text.match(VERSION_TEMPLATE % {name: version_name})
        if version.nil?
          message = "Cannot find '#{version_name}' on #{path}"
          UI.important(message)
          raise message
        else
          version = version[1]
          major_v, minor_v, tail = version.match("(\\d+)\\.(\\d+)(.*)")
          patch_v = tail.match("(\\.(\\d+))?")[2]
          build_n = tail.match("(\\((\\d+)\\))?")[2]
          return ProjectVersion.new(major_v, minor_v, patch_v, build_n)
        end
      end

      def self.parseBetaVersion(path)
        return self.parseVersion(path, BETA_VERSION_NAME)
      end

      def self.parseRcVersion(path)
        return self.parseVersion(path, RC_VERSION_NAME)
      end

      def self.parseReleaseVersion(path)
        return self.parseVersion(path, RELEASE_VERSION_NAME)
      end

      def self.parseGradleVersion(build_gradle_path)
        return self.parseVersion(build_gradle_path, GRADLE_VERSION_NAME)
      end

      def self.saveVersion(path, version_name, version)
        versions_text = FileHelper.read(path.to_s)
        old_version = versions_text.match(VERSION_TEMPLATE % {name: version_name})
        if version.nil?
          UI.important("Cannot find '#{version_name}' on #{path}")
        else
          FileHelper.write(path.to_s, versions_text.sub(old_version.to_s, "#{version_name} = '#{version}'"))
        end
      end

      def self.saveBetaVersion(path, version)
        self.saveVersion(path, BETA_VERSION_NAME, version)
      end

      def self.saveRcVersion(path, version)
        self.saveVersion(path, RC_VERSION_NAME, version)
      end

      def self.saveReleaseVersion(path, version)
        self.saveVersion(path, RELEASE_VERSION_NAME, version)
      end

      def self.saveGradleVersion(build_gradle_path, version)
        v = version.dup.clone
        v.build_number = nil
        self.saveVersion(build_gradle_path, GRADLE_VERSION_NAME, v)
      end

      def self.parseVersionCode(path)
        versions_text = FileHelper.read(path.to_s)
        version = versions_text.match("#{VERSION_CODE_NAME} ?=? ?'?(\\d+)'?")
        if version.nil?
          UI.important("Cannot find '#{VERSION_CODE_NAME}' on #{path}")
          return nil
        else
          return version[1].to_i
        end
      end

      def self.saveVersionCode(path, version)
        versions_text = FileHelper.read(path.to_s)
        old_version = versions_text.match("#{VERSION_CODE_NAME} ?=? ?'?(\\d+)'?")
        if version.nil?
          UI.important("Cannot find '#{VERSION_CODE_NAME}' on #{path}")
        else
          FileHelper.write(path.to_s, versions_text.sub(old_version.to_s, "#{VERSION_CODE_NAME} = #{version}"))
        end
      end

      def self.parseObbData(path, names)
        versions_text = FileHelper.read(path.to_s)
        version = versions_text.match("#{names[:version]} ?=? ?'?(\\d+)'?")
        size = versions_text.match("#{names[:size]} ?=? ?'?(\\d+)'?")
        return version.nil? ? nil : version[1].to_i, size.nil? ? nil : size[1].to_i
      end

      def self.parseMainObbFileInfo(path)
        return self.parseObbData(path, OBB_MAIN_NAMES)
      end

      def self.parsePatchObbFileInfo(path)
        return self.parseObbData(path, OBB_PATCH_NAMES)
      end

      def self.saveObbFileInfo(path, names, version, size)
        versions_text = FileHelper.read(path.to_s)
        old_version = versions_text.match("#{names[:version]} ?=? ?'?(\\d+)'?")
        old_size = versions_text.match("#{names[:size]} ?=? ?'?(\\d+)'?")
        if old_version.nil?
          UI.important("Cannot find '#{names[:version]}' on #{path}")
        elsif old_size.nil?
          UI.important("Cannot find '#{names[:size]}' on #{path}")
        else
          versions_text = versions_text.sub(old_version.to_s, "#{names[:version]} = #{version}")
          versions_text = versions_text.sub(old_size.to_s, "#{names[:size]} = #{size}")
          FileHelper.write(path.to_s, versions_text)
        end
      end

      def self.saveMainObbFileInfo(path, version, size)
        self.saveObbFileInfo(path, OBB_MAIN_NAMES, version, size)
      end

      def self.savePatchObbFileInfo(path, version, size)
        self.saveObbFileInfo(path, OBB_PATCH_NAMES, version, size)
      end
    end
  end
end