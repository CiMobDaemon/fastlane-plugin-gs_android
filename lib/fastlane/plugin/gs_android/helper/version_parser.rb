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

      def self.get_versions_from_url(url)
        require 'net/http'
        require 'json'

        uri = URI.parse(url)
        request = Net::HTTP::Get.new(uri.to_s)
        result = Net::HTTP.start(uri.host, uri.port) {|http|
          http.request(request)
        }
        return JSON.parse(result.body)
      end

      def self.parse_version_from_string(version)
        major_v, minor_v, tail = version.match("(\\d+)\\.(\\d+)(.*)").captures
        patch_v = tail.match("(\\.(\\d+))?")[2]
        build_n = tail.match("(\\((\\d+)\\))?")[2]
        return ProjectVersion.new(major_v, minor_v, patch_v, build_n)
      end

      def self.parse_version_from_url(url, version_name)
        version = self.get_versions_from_url(url)[version_name]

        if version.nil?
          message = "Cannot find '#{version_name}' on #{url}"
          UI.important(message)
          raise message
        else
          return self.parse_version_from_string(version)
        end
      end

      def self.parse_version_from_file(path, version_name)
        versions_text = FileHelper.read(path.to_s)
        version = versions_text.match(VERSION_TEMPLATE % {name: version_name})
        if version.nil?
          message = "Cannot find '#{version_name}' on #{path}"
          UI.important(message)
          raise message
        else
          version = version[1]
          return self.parse_version_from_string(version)
        end
      end

      def self.parse_beta_version(url)
        return self.parse_version_from_url(url, BETA_VERSION_NAME)
      end

      def self.parse_rc_version(url)
        return self.parse_version_from_url(url, RC_VERSION_NAME)
      end

      def self.parse_release_version(url)
        return self.parse_version_from_url(url, RELEASE_VERSION_NAME)
      end

      def self.parse_gradle_version(build_gradle_path)
        return self.parse_version_from_file(build_gradle_path, GRADLE_VERSION_NAME)
      end

      def self.save_version_to_url(url, project_alias, versions)
        require 'net/http'
        require 'json'

        uri = URI.parse(url)
        data = {"alias": project_alias}

        versions.each do |version_name, version_value|
          data[version_name] = version_value
        end
        http = Net::HTTP.new(uri.host, uri.port)
        request = Net::HTTP::Patch.new(uri.to_s)
        request['Content-Type'] = 'application/json'
        request.body = data.to_json
        http.request(request)
      end

      def self.save_version_to_file(path, version_name, version)
        versions_text = FileHelper.read(path.to_s)
        old_version = versions_text.match(VERSION_TEMPLATE % {name: version_name})
        if old_version.nil?
          UI.important("Cannot find '#{version_name}' on #{path}")
        else
          FileHelper.write(path.to_s, versions_text.sub(old_version.to_s, "#{version_name} = '#{version}'"))
        end
      end

      def self.save_beta_version(url, project_alias, version)
        self.save_version_to_url(url, project_alias, {"#{BETA_VERSION_NAME}": "#{version}"})
      end

      def self.save_rc_version(url, project_alias, version)
        self.save_version_to_url(url, project_alias, {"#{RC_VERSION_NAME}": "#{version}"})
      end

      def self.save_release_version(url, project_alias, version)
        self.save_version_to_url(url, project_alias, {"#{RELEASE_VERSION_NAME}": "#{version}"})
      end

      def self.save_gradle_version(build_gradle_path, version)
        v = version.dup.clone
        v.build_number = nil
        self.save_version_to_file(build_gradle_path, GRADLE_VERSION_NAME, v)
      end

      def self.parse_version_code_from_url(url)
        version_code = self.get_versions_from_url(url)[VERSION_CODE_NAME]

        if version_code.nil?
          message = "Cannot find version code on #{url}"
          UI.important(message)
          raise message
        else
          return version_code.to_i
        end
      end

      def self.save_version_code_to_url(url, project_alias, version_code)
        self.save_version_to_url(url, project_alias, {"#{VERSION_CODE_NAME}": "#{version_code}"})
      end

      def self.parse_version_code_from_file(path)
        versions_text = FileHelper.read(path.to_s)
        version = versions_text.match("#{VERSION_CODE_NAME} ?=? ?'?(\\d+)'?")
        if version.nil?
          UI.important("Cannot find '#{VERSION_CODE_NAME}' on #{path}")
          return nil
        else
          return version[1].to_i
        end
      end

      def self.save_version_code_to_file(path, version)
        versions_text = FileHelper.read(path.to_s)
        old_version = versions_text.match("#{VERSION_CODE_NAME} ?=? ?'?(\\d+)'?")
        if version.nil?
          UI.important("Cannot find '#{VERSION_CODE_NAME}' on #{path}")
        else
          FileHelper.write(path.to_s, versions_text.sub(old_version.to_s, "#{VERSION_CODE_NAME} = #{version}"))
        end
      end

      def self.parce_obb_data_from_url(url, names)
        versions = self.get_versions_from_url(url)
        return versions[names[:version]], versions[names[:size]]
      end

      def self.parce_main_obb_data_from_url(url)
        return parce_obb_data_from_url(url, OBB_MAIN_NAMES)
      end

      def self.parce_patch_obb_data_from_url(url)
        return parce_obb_data_from_url(url, OBB_PATCH_NAMES)
      end

      def self.save_obb_data_to_url(url, project_alias, names, version, size)
        self.save_version_to_url(url, project_alias, {"#{names[:version]}": version, "#{names[:size]}": size})
      end

      def self.save_main_obb_file_data(url, project_alias, version, size)
        self.save_obb_data_to_url(url, project_alias, OBB_MAIN_NAMES, version, size)
      end

      def self.save_patch_obb_file_data(url, project_alias, version, size)
        self.save_obb_data_to_url(url, project_alias, OBB_PATCH_NAMES, version, size)
      end
    end
  end
end