require 'googleauth'
require 'google/apis/androidpublisher_v2'

module Fastlane
  module CustomSupply
    class GooglePlayUploader
      def perform_upload
        client.begin_edit(package_name: CustomSupply.config[:package_name])
        upload_binaries unless CustomSupply.config[:skip_upload_apk]
        UI.message('Uploading all changes to Google Play...')
        client.commit_current_edit!
        UI.success('Successfully finished the upload to Google Play')
      end

      def upload_binaries
        apk_paths = [CustomSupply.config[:apk]] unless (apk_paths = CustomSupply.config[:apk_paths])

        apk_version_codes = []

        apk_paths.each do |apk_path|
          apk_version_codes.push(upload_binary_data(apk_path))
        end

        update_track(apk_version_codes)
      end

      private

      ##
      # Upload binary apk and obb and corresponding change logs with client
      #
      # @param [String] apk_path
      #    Path of the apk file to upload.
      #
      # @return [Integer] The apk version code returned after uploading, or nil if there was a problem
      def upload_binary_data(apk_path)
        apk_version_code = nil
        if apk_path
          UI.message("Preparing apk at path '#{apk_path}' for upload...")
          apk_version_code = client.upload_apk(apk_path)
          UI.user_error!("Could not upload #{apk_path}") unless apk_version_code

          if CustomCustomSupply.config[:obb_main_references_version] && CustomCustomSupply.config[:obb_main_file_size]
            update_obb(apk_version_code,
                     'main',
                     CustomSupply.config[:obb_main_references_version],
                     CustomSupply.config[:obb_main_file_size])
          end

          if CustomSupply.config[:obb_patch_references_version] && CustomSupply.config[:obb_patch_file_size]
            update_obb(apk_version_code,
                      'patch',
                      CustomSupply.config[:obb_patch_references_version],
                      CustomSupply.config[:obb_patch_file_size])
          end

          upload_obbs(apk_path, apk_version_code)

          if metadata_path
            all_languages.each do |language|
              next if language.start_with?('.') # e.g. . or .. or hidden folders
              upload_changelog(language, apk_version_code)
            end
          end
        else
          UI.message("No apk file found, you can pass the path to your apk using the `apk` option")
        end
        apk_version_code
      end

      def update_track(apk_version_codes)
        UI.message("Updating track '#{CustomSupply.config[:track]}'...")

        if CustomSupply.config[:track].eql?("rollout")
          client.update_track(CustomSupply.config[:track], CustomSupply.config[:rollout] || 0.1, apk_version_codes)
        else
          client.update_track(CustomSupply.config[:track], 1.0, apk_version_codes)
        end
      end

      # returns only language directories from metadata_path
      def all_languages
        Dir.entries(metadata_path)
            .select { |f| File.directory? File.join(metadata_path, f) }
            .reject { |f| f.start_with?('.') }
            .sort { |x, y| x <=> y }
      end

      def client
        @client ||= Client.make_from_config
      end

      def metadata_path
        CustomSupply.config[:metadata_path]
      end

      def update_obb(apk_version_code, expansion_file_type, references_version, file_size)
        UI.message("Updating '#{expansion_file_type}' expansion file from verison '#{references_version}'...")
        client.update_obb(apk_version_code,
                         expansion_file_type,
                         references_version,
                         file_size)
      end

      # searches for obbs in the directory where the apk is located and
      # upload at most one main and one patch file. Do nothing if it finds
      # more than one of either of them.
      def upload_obbs(apk_path, apk_version_code)
        expansion_paths = find_obbs(apk_path)
        ['main', 'patch'].each do |type|
          if expansion_paths[type]
            upload_obb(expansion_paths[type], type, apk_version_code)
          end
        end
      end

      # @return a map of the obb paths for that apk
      # keyed by their detected expansion file type
      # E.g.
      # { 'main' => 'path/to/main.obb', 'patch' => 'path/to/patch.obb' }
      def find_obbs(apk_path)
        search = File.join(File.dirname(apk_path), '*.obb')
        paths = Dir.glob(search, File::FNM_CASEFOLD)
        expansion_paths = {}
        paths.each do |path|
          type = obb_expansion_file_type(path)
          next unless type
          if expansion_paths[type]
            UI.important("Can only upload one '#{type}' apk expansion. Skipping obb upload entirely.")
            UI.important("If you'd like this to work differently, please submit an issue.")
            return {}
          end
          expansion_paths[type] = path
        end
        expansion_paths
      end

      def upload_obb(obb_path, expansion_file_type, apk_version_code)
        UI.message("Uploading obb file #{obb_path}...")
        client.upload_obb(obb_file_path: obb_path,
                          apk_version_code: apk_version_code,
                          expansion_file_type: expansion_file_type)
      end

      def obb_expansion_file_type(obb_file_path)
        filename = File.basename(obb_file_path, ".obb")
        if filename.include?('main')
          'main'
        elsif filename.include?('patch')
          'patch'
        end
      end
    end
  end
end
