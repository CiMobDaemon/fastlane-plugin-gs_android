module Fastlane
  module Helper
    class VersionWorker

      VERSIONS_URL_TEMPLATE = "http://mobile.geo4.io/bot/releaseBuilder/versions/"

      def self.increment_version_code(project_alias, build_gradle_path)
        UI.message(':incrementVersionCode - Incrementing Version Code...')
        version_code = VersionParser.parse_version_code_from_url("#{VERSIONS_URL_TEMPLATE}#{project_alias}")
        UI.message(":incrementVersionCode - current versionCode = #{version_code}")
        version_code += 1
        UI.message(":incrementVersionCode - next versionCode = #{version_code}")
        build_gradle_text = FileHelper.read(build_gradle_path)
        new_build_gradle_text = build_gradle_text.sub(build_gradle_text.match("versionCode \\d+").to_s, "versionCode #{version_code}")
        FileHelper.write(build_gradle_path, new_build_gradle_text)
        return version_code
      end

      def self.save_version_code(project_alias, build_gradle_path)
        UI.message(':saveVersionCode - Saving Version Code...')
        version_code = FileHelper.read(build_gradle_path).match("versionCode (\\d+)")[1].to_i
        UI.message(":saveVersionCode - versionCode = #{version_code}")
        VersionParser.save_version_code_to_url(VERSIONS_URL_TEMPLATE, project_alias, version_code)
      end

      def self.increment_beta_version_name(project_alias, build_gradle_path, general_major_version)
        UI.message(':incrementBetaVersionName - Incrementing Version Name...')
        beta_version_name = VersionParser.parse_beta_version("#{VERSIONS_URL_TEMPLATE}#{project_alias}")
        UI.message(":incrementBetaVersionName - current versionName = #{beta_version_name}")

        rc_version_name = VersionParser.parse_rc_version("#{VERSIONS_URL_TEMPLATE}#{project_alias}")

        beta_version_name = ProjectVersion.new(rc_version_name.major_version, rc_version_name.minor_version, 0) unless beta_version_name >= rc_version_name

        beta_version_name += 1.patch

        UI.message(":incrementBetaVersionName - new versionName = #{beta_version_name}")
        VersionParser.save_gradle_version(build_gradle_path, beta_version_name)
        return beta_version_name
      end

      def self.save_beta_version_name(project_alias, build_gradle_path)
        UI.message(':saveBetaVersionName - Saving Version Name...')
        beta_version_name = VersionParser.parse_gradle_version(build_gradle_path)
        UI.message(":saveBetaVersionName - versionName = #{beta_version_name}")
        VersionParser.save_beta_version(VERSIONS_URL_TEMPLATE, project_alias, beta_version_name)
      end

      def self.get_rc_version_name(project_alias)
        return VersionParser.parse_rc_version("#{VERSIONS_URL_TEMPLATE}#{project_alias}")
      end

      def self.increment_rc_version_name(project_alias, build_gradle_path, general_major_version)
        UI.message(':incrementRcVersionName - Incrementing Version Name...')
        rc_version_name = VersionParser.parse_rc_version("#{VERSIONS_URL_TEMPLATE}#{project_alias}")
        UI.message(":incrementRcVersionName - current versionName = #{rc_version_name}")

        if rc_version_name.major_version != general_major_version
          rc_version_name = general_major_version.major + 0.minor + 1.build
        else
          release_version_name = VersionParser.parse_release_version("#{VERSIONS_URL_TEMPLATE}#{project_alias}")
          if rc_version_name.ignore_build <= release_version_name
            rc_version_name = release_version_name + 1.minor + 1.build
          else
            rc_version_name += 1.build
          end
        end
        UI.message(":incrementRcVersionName - new versionName = #{rc_version_name}")
        VersionParser.save_gradle_version(build_gradle_path, rc_version_name)
        return rc_version_name
      end

      def self.save_rc_version_name(project_alias, build_gradle_path)
        UI.message(':saveRcVersionName - Saving Version Name...')
        rc_version_name = VersionParser.parse_gradle_version(build_gradle_path)
        old_rc_version_name = VersionParser.parse_rc_version("#{VERSIONS_URL_TEMPLATE}#{project_alias}")

        rc_version_name = old_rc_version_name if (rc_version_name.ignore_build == old_rc_version_name.ignore_build)
        rc_version_name += 1.build

        UI.message(":saveRcVersionName - versionName = #{rc_version_name}")
        VersionParser.save_rc_version(VERSIONS_URL_TEMPLATE, project_alias, rc_version_name)
      end

      def self.get_release_version_name(project_alias)
        return VersionParser.parse_release_version("#{VERSIONS_URL_TEMPLATE}#{project_alias}")
      end

      def self.save_release_version_name(project_alias)
        UI.message(':saveRcVersionName - Saving Version Name...')
        rc_version_name = VersionParser.parse_rc_version("#{VERSIONS_URL_TEMPLATE}#{project_alias}").ignore_build
        UI.message(":saveRcVersionName - versionName = #{rc_version_name}")
        VersionParser.save_release_version(VERSIONS_URL_TEMPLATE, project_alias, rc_version_name)
        rc_version_name.build_number = 0
        VersionParser.save_rc_version(VERSIONS_URL_TEMPLATE, project_alias, rc_version_name)
      end

      def self.get_current_version_name(build_gradle_path)
        return VersionParser.parse_gradle_version(build_gradle_path)
      end

      def self.save_main_obb_file_info(project_alias, version, size)
        VersionParser.save_main_obb_file_data(VERSIONS_URL_TEMPLATE, project_alias, version, size)
      end

      def self.save_patch_obb_file_info(project_alias, version, size)
        VersionParser.save_patch_obb_file_data(VERSIONS_URL_TEMPLATE, project_alias, version, size)
      end

      def self.get_main_obb_file_info(project_alias)
        VersionParser.parce_main_obb_data_from_url("#{VERSIONS_URL_TEMPLATE}#{project_alias}")
      end

      def self.get_patch_obb_file_info(project_alias)
        VersionParser.parce_patch_obb_data_from_url("#{VERSIONS_URL_TEMPLATE}#{project_alias}")
      end
    end
  end
end
