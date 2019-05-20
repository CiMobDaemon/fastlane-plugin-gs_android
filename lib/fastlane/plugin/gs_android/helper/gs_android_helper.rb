module Fastlane
  module Helper
    class GsAndroidHelper
      # class methods that you define here become available in your action
      # as `Helper::GsAndroidHelper.your_method`
      #
      #fastlane has not option to execute gradle task with params (22.05.17)

			NOTES_PATH_TEMPLATE = '%{Dir}/../../notes/%{project_alias}/%{version_name}_%{lang}.txt'
			CHANGELOG_PATH_TEMPLATE = '%{Dir}/fastlane/metadata/android/%{country}/changelogs/%{version_code}.txt'

      def self.run_action(action, args)
      	configuration = FastlaneCore::Configuration.create(action.available_options, args)
      	action.run(configuration)
      end

     	def self.gradle_with_params(task, args)
				args.each do |paramName, paramValue|
					task = "-P#{paramName}=#{paramValue} #{task}"
				end
				UI.message("-------Task-------\n#{task}")
				self.run_action(Actions::GradleAction, task: task)
				#Actions::GradleAction.run(task: task)
			end

			#send job state https://forge.gradoservice.ru/projects/botback/wiki/Rest#jobStates
			def self.send_job_state(projectAlias, cmd, state, message = nil, restart_build_url = nil)
				require 'net/http'
				require 'uri'
				require 'json'

				uri = URI.parse('http://mobile.geo4.pro/bot/releaseBuilder/jobStates')
				data = {'alias': projectAlias, 'cmd': cmd, 'state': state}

				if message != nil
						data['message'] = message
				end

				if restart_build_url != nil
						data['restart_build_url'] = restart_build_url
				end

				# Create the HTTP objects
				http = Net::HTTP.new(uri.host, uri.port)
				request = Net::HTTP::Post.new(uri.request_uri)
				request['Content-Type'] = 'application/json'
				request.body = data.to_json

				# Send the request
				response = http.request(request)
				UI.message('------REQUEST------\n' + request.body + '\nResponse:\n' + response.body)
			end

			def self.generate_release_notes(cmd, project_alias, version_name, lang = nil)
				cmnd = cmd
				if lang != nil
					 cmnd = cmnd+lang
				else
					 raise 'Language is required for release notes generating.'
				end
				require 'fastlane/plugin/gs_deliver'
				configuration = FastlaneCore::Configuration.create(Actions::GsGetReleaseNotesAction.available_options, {cmd: cmnd,
																																																lang: lang,
																																																alias: project_alias,
																																																displayVersionName: version_name})
				Actions::GsGetReleaseNotesAction.run(configuration)
				notes_file_path = NOTES_PATH_TEMPLATE % {Dir: Dir.pwd, project_alias: project_alias, version_name: version_name, lang: lang}
				UI.message("Check exist #{notes_file_path}")
				unless File.exist?(notes_file_path)
						raise 'Не удалось сгенерировать ReleaseNotes'
				end
			end

			def self.load_changelog(project_alias, version_name, version_code, locales, version_code_prefixes = nil)
				UI.message("Loading changelog for #{project_alias} #{version_code} #{locales} #{version_code_prefixes}")
				locales.split(',').each do |locale|
					lang = locale.split('-')[0].strip.capitalize
					country = locale.strip

					notes_file_path = NOTES_PATH_TEMPLATE % {Dir: Dir.pwd, project_alias: project_alias, version_name: version_name, lang: lang}

					if File.exist?(notes_file_path)
						File.delete(notes_file_path)
					end

					generate_release_notes('fileClosed', project_alias, version_name, lang)

					text = FileHelper.read(notes_file_path)

					unless version_code_prefixes.nil?
							version_code_prefixes = version_code_prefixes.split(',')
							version_code_prefixes.each do |version_code_prefix|
								UI.message("Writing changelog to #{CHANGELOG_PATH_TEMPLATE % {Dir: Dir.pwd, country: country, version_code: "#{version_code_prefix}#{version_code}"}}")
									FileHelper.write(CHANGELOG_PATH_TEMPLATE % {Dir: Dir.pwd, country: country, version_code: "#{version_code_prefix}#{version_code}"}, text)
							end
					end
					UI.message("Writing changelog to #{CHANGELOG_PATH_TEMPLATE % {Dir: Dir.pwd, country: country, version_code: version_code}}")
					FileHelper.write(CHANGELOG_PATH_TEMPLATE % {Dir: Dir.pwd, country: country, version_code: version_code}, text)
				end
			end
    end
  end
end
