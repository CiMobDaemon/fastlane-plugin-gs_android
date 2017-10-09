require 'googleauth'
require 'google/apis/androidpublisher_v2'

module Fastlane
  module CustomSupply
    class GooglePlayClient
      # Connecting with Google
      attr_accessor :android_publisher
      # Reference to the entry we're currently editing. Might be nil if don't have one open
      attr_accessor :current_edit
      # Package name of the currently edited element
      attr_accessor :current_package_name

      #####################################################
      # @!group Login
      #####################################################

      def initialize(json_key_file_path)
        #Google api authorization
        scope = Google::Apis::AndroidpublisherV2::AUTH_ANDROIDPUBLISHER
        key_io = File.open(File.expand_path(json_key_file_path))
        auth_client = Google::Auth::ServiceAccountCredentials.make_creds(json_key_io: key_io, scope: scope)
        auth_client.fetch_access_token!
        self.android_publisher = Google::Apis::AndroidpublisherV2::AndroidPublisherService.new
        self.android_publisher.authorization = auth_client
      end

      #####################################################
      # @!group Handling the edit lifecycle
      #####################################################

      # Begin modifying a certain package
      def begin_edit(package_name: nil)
        UI.user_error!('You currently have an active edit') if @current_edit

        self.current_edit = call_google_api { self.android_publisher.insert_edit(package_name) }

        self.current_package_name = package_name
      end

      # Aborts the current edit deleting all pending changes
      def abort_current_edit
        ensure_active_edit!

        call_google_api { android_publisher.delete_edit(current_package_name, current_edit.id) }

        self.current_edit = nil
        self.current_package_name = nil
      end

      # Commits the current edit saving all pending changes on Google Play
      def commit_current_edit!
        ensure_active_edit!

        call_google_api { android_publisher.commit_edit(current_package_name, current_edit.id) }

        self.current_edit = nil
        self.current_package_name = nil
      end

      #####################################################
      # @!group Getting data
      #####################################################

      def get_version_codes(track)
        ensure_active_edit!
        return android_publisher.get_track(current_package_name, current_edit.id, track).version_codes
      end


      #####################################################
      # @!group Modifying data
      #####################################################

      def upload_apk(path_to_apk)
        ensure_active_edit!

        result_upload = call_google_api do
          android_publisher.upload_apk(
              current_package_name,
              current_edit.id,
              upload_source: path_to_apk
          )
        end

        return result_upload.version_code
      end

      # Updates the track for the provided version code(s)
      def update_track(track, rollout, apk_version_code)
        ensure_active_edit!

        track_version_codes = apk_version_code.kind_of?(Array) ? apk_version_code : [apk_version_code]

        track_body = Google::Apis::AndroidpublisherV2::Track.new({
                                                     track: track,
                                                     user_fraction: rollout,
                                                     version_codes: track_version_codes
                                                 })

        call_google_api do
          android_publisher.update_track(
              current_package_name,
              current_edit.id,
              track,
              track_body
          )
        end
      end

      def update_apk_listing_for_language(apk_version_code, language, changes)
        ensure_active_edit!

        call_google_api do
          android_publisher.update_apk_listing(
              current_package_name,
              current_edit.id,
              apk_version_code,
              language,
              Google::Apis::AndroidpublisherV2::ApkListing.new({
                                                   language: language,
                                                   recent_changes: changes
                                               })
          )
        end
      end

      def upload_obb(obb_file_path: nil, apk_version_code: nil, expansion_file_type: nil)
        ensure_active_edit!

        call_google_api do
          android_publisher.upload_expansion_file(
              current_package_name,
              current_edit.id,
              apk_version_code,
              expansion_file_type,
              upload_source: obb_file_path,
              content_type: 'application/octet-stream'
          )
        end
      end

      def update_obb(apk_version_code, expansion_file_type, references_version, file_size)
        ensure_active_edit!

        call_google_api do
            android_publisher.update_expansion_file(
                  current_package_name,
                  current_edit.id,
                  apk_version_code,
                  expansion_file_type,
                  Google::Apis::AndroidpublisherV2::ExpansionFile.new(
                        references_version: references_version,
                file_size: file_size
              )
            )
          end
      end

      private

      def ensure_active_edit!
        UI.user_error!('You need to have an active edit, make sure to call `begin_edit`') unless @current_edit
      end

      def call_google_api
        yield if block_given?
      rescue Google::Apis::ClientError => e
        UI.user_error! "Google Api Error: #{e.message}"
      end

    end
  end
end