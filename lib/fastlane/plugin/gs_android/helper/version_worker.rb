module Fastlane
  module Helper
    class VersionWorker
      VERSION_FILES_PATH_TEMPLATE = "../../versionsFiles/versions%{postfix}.txt"

      def self.incrementVersionCode(versions_file_postfix, build_gradle_path)
        UI.message(":incrementVersionCode - Incrementing Version Code...")
        version_code = VersionParser.parseVersionCode(VERSION_FILES_PATH_TEMPLATE % {postfix: versions_file_postfix})
        UI.message(":incrementVersionCode - current versionCode = #{version_code}")
        version_code += 1
        UI.message(":incrementVersionCode - next versionCode = #{version_code}")
        build_gradle_text = FileHelper.read(build_gradle_path)
        new_build_gradle_text = build_gradle_text.sub(build_gradle_text.match("versionCode \\d+").to_s, "versionCode #{version_code}")
        FileHelper.write(build_gradle_path, new_build_gradle_text)
        return version_code
      end

      def self.saveVersionCode(versions_file_postfix, build_gradle_path)
        UI.message(":saveVersionCode - Saving Version Code...")
        version_code = FileHelper.read(build_gradle_path).match("versionCode (\\d+)")[1].to_i
        UI.message(":saveVersionCode - versionCode = #{version_code}")
        VersionParser.saveVersionCode(VERSION_FILES_PATH_TEMPLATE % {postfix: versions_file_postfix}, version_code)
      end

      def self.incrementBetaVersionName(versions_file_postfix, build_gradle_path, general_major_version)
        UI.message(":incrementBetaVersionName - Incrementing Version Name...")
        beta_version_name = VersionParser.parseBetaVersion(VERSION_FILES_PATH_TEMPLATE % {postfix: versions_file_postfix})
        UI.message(":incrementBetaVersionName - current versionName = #{beta_version_name}")
        if beta_version_name.major_version != general_major_version
          beta_version_name.set_new_version(general_major_version, 0, 1)
        else
          rc_version_name = VersionParser.parseRcVersion(VERSION_FILES_PATH_TEMPLATE % {postfix: versions_file_postfix})
          if beta_version_name.minor_version != rc_version_name.minor_version
            beta_version_name.set_new_version(beta_version_name.major_version, rc_version_name.minor_version, 1)
          else
            beta_version_name.increment_patch_version
          end
        end
        UI.message(":incrementBetaVersionName - new versionName = #{beta_version_name}")
        VersionParser.saveVersion(build_gradle_path, 'currentVersionName', beta_version_name)
        return beta_version_name
      end

      def self.saveBetaVersionName(versions_file_postfix, build_gradle_path)
        UI.message(":saveBetaVersionName - Saving Version Name...")
        beta_version_name = VersionParser.parseVersion(build_gradle_path, 'currentVersionName')
        UI.message(":saveBetaVersionName - versionName = #{beta_version_name}")
        VersionParser.saveBetaVersion(VERSION_FILES_PATH_TEMPLATE % {postfix: versions_file_postfix}, beta_version_name)
      end

      def self.getRcVersionName(versions_file_postfix)
        return VersionParser.parseRcVersion(VERSION_FILES_PATH_TEMPLATE % {postfix: versions_file_postfix})
      end

      def self.incrementRcVersionName(versions_file_postfix, build_gradle_path, general_major_version)
        UI.message(":incrementRcVersionName - Incrementing Version Name...")
        rc_version_name = VersionParser.parseRcVersion(VERSION_FILES_PATH_TEMPLATE % {postfix: versions_file_postfix})
        UI.message(":incrementRcVersionName - current versionName = #{rc_version_name}")
        if rc_version_name.major_version != general_major_version
          rc_version_name.set_new_version(general_major_version, 0)
        else
          release_version_name = VersionParser.parseReleaseVersion(VERSION_FILES_PATH_TEMPLATE % {postfix: versions_file_postfix})
          if rc_version_name.minor_version == release_version_name.minor_version
            rc_version_name.increment_minor_version
          end
        end
        UI.message(":incrementRcVersionName - new versionName = #{rc_version_name}")
        VersionParser.saveVersion(build_gradle_path, 'currentVersionName', rc_version_name)
        return rc_version_name
      end

      def self.saveRcVersionName(versions_file_postfix, build_gradle_path)
        UI.message(":saveRcVersionName - Saving Version Name...")
        rc_version_name = VersionParser.parseVersion(build_gradle_path, 'currentVersionName')
        UI.message(":saveRcVersionName - versionName = #{rc_version_name}")
        old_rc_version_name = VersionParser.parseRcVersion(VERSION_FILES_PATH_TEMPLATE % {postfix: versions_file_postfix})
        if rc_version_name.major_version == old_rc_version_name.major_version && rc_version_name.minor_version == old_rc_version_name.minor_version
          rc_version_name = old_rc_version_name
        end
        rc_version_name.increment_build_number
        VersionParser.saveRcVersion(VERSION_FILES_PATH_TEMPLATE % {postfix: versions_file_postfix}, rc_version_name)
      end

      def self.getReleaseVersionName(versions_file_postfix)
        return VersionParser.parseReleaseVersion(VERSION_FILES_PATH_TEMPLATE % {postfix: versions_file_postfix})
      end

      def self.saveReleaseVersionName(versions_file_postfix)
        UI.message(":saveRcVersionName - Saving Version Name...")
        rc_version_name = VersionParser.parseRcVersion(VERSION_FILES_PATH_TEMPLATE % {postfix: versions_file_postfix})
        UI.message(":saveRcVersionName - versionName = #{rc_version_name}")
        VersionParser.saveReleaseVersion(VERSION_FILES_PATH_TEMPLATE % {postfix: versions_file_postfix}, rc_version_name)
        rc_version_name.build_number = 0
        VersionParser.saveRcVersion(VERSION_FILES_PATH_TEMPLATE % {postfix: versions_file_postfix}, rc_version_name)
      end

      def self.getCurrentVersionName(build_gradle_path)
        return VersionParser.parseVersion(build_gradle_path, 'currentVersionName')
      end

      def self.saveMainObbFileInfo(versions_file_postfix, version, size)
        VersionParser.saveMainObbFileInfo(VERSION_FILES_PATH_TEMPLATE % {postfix: versions_file_postfix}, version, size)
      end

      def self.savePatchObbFileInfo(versions_file_postfix, version, size)
        VersionParser.savePatchObbFileInfo(VERSION_FILES_PATH_TEMPLATE % {postfix: versions_file_postfix}, version, size)
      end

      def self.getMainObbFileInfo(versions_file_postfix)
        VersionParser.parseMainObbFileInfo(VERSION_FILES_PATH_TEMPLATE % {postfix: versions_file_postfix})
      end

      def self.getPatchObbFileInfo(versions_file_postfix)
        VersionParser.parsePatchObbFileInfo(VERSION_FILES_PATH_TEMPLATE % {postfix: versions_file_postfix})
      end
    end
  end
end
