module Fastlane
  module Helper
    class GooglePlayLoader

      def self.update_changelog(projectAlias, package_name, version_name, track, locales, json_key_file_path)
        require 'googleauth'
				require 'google/apis/androidpublisher_v2'

				#Google api authorization
				scope = Google::Apis::AndroidpublisherV2::AUTH_ANDROIDPUBLISHER
				key_io = File.open(File.expand_path(json_key_file_path))
				auth_client = Google::Auth::ServiceAccountCredentials.make_creds(json_key_io: key_io, scope: scope)
				auth_client.fetch_access_token!
				android_publisher = Google::Apis::AndroidpublisherV2::AndroidPublisherService.new
				android_publisher.authorization = auth_client

				#create edit
				current_edit = android_publisher.insert_edit(package_name)

				#get version codes
				version_codes = android_publisher.get_edit_track(package_name, current_edit.id, track).version_codes

				version_codes.each do |version_code|
					Helper::GsAndroidHelper.loadChangelog(projectAlias, version_name, version_code,locales)

					locales.split(",").each do |locale|
						language = locale.strip

						#read changelog
						changelog = FileHelper.read(Helper::GsAndroidHelper::CHANGELOG_PATH_TEMPLATE % {Dir: Dir.pwd, country: language, version_code: version_code})

						apk_listing_object = Google::Apis::AndroidpublisherV2::ApkListing.new({
																																language: language,
																																recent_changes: changelog
																														})
						#Update changelog for existing
						android_publisher.update_edit_apklisting(package_name, current_edit.id, version_code, language, apk_listing_object)
					end
				end

				#commit edit
				android_publisher.commit_edit(package_name, current_edit.id)
      end
    end
  end
end
