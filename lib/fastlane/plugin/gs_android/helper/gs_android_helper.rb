module Fastlane
  module Helper
    class GsAndroidHelper
      # class methods that you define here become available in your action
      # as `Helper::GsAndroidHelper.your_method`
      #
      #fastlane has not option to execute gradle task with params (22.05.17)
      def self.gradle_with_params(task, args)
        args.each do |paramName, paramValue|
				task = "-P#{paramName}=#{paramValue} #{task}"
				end
				UI.message("-------Task-------\n#{task}")
				Actions::GradleAction.run(task: task)
			end

				#send job state https://forge.gradoservice.ru/projects/botback/wiki/Rest#jobStates
				def self.send_job_state(projectAlias, cmd, state, message = nil)
					require 'net/http'
					require 'uri'
					require 'json'

					uri = URI.parse("http://mobile.geo4.io/bot/releaseBuilder/jobStates")
					data = {"alias":projectAlias,"cmd":cmd,"state":state}

					if message != nil
							data['message'] = message
					end

					# Create the HTTP objects
					http = Net::HTTP.new(uri.host, uri.port)
					request = Net::HTTP::Post.new(uri.request_uri)
					request['Content-Type'] = 'application/json'
					request.body = data.to_json

					# Send the request
					response = http.request(request)
					UI.message('------REQUEST------\n' + request.body + '\nResponse:\n' + response)
				end

			def self.generate_release_notes(cmd, project_alias, version, lang = nil)
			cmnd = cmd
			if lang != nil
				 cmnd = cmnd+lang
			else
				 raise 'Language is required for release notes generating.'
			end
			gs_get_release_notes(cmd: cmnd,
				 lang: lang,
				 alias: project_alias,
				 displayVersionName: version)
			UI.message("Check exist " + Dir.pwd + "/../../../notes/" + project_alias + "/" + version + "_" + lang + ".txt")
			if !File.exist?(Dir.pwd + "/../../../notes/" + project_alias + "/" + version + "_" + lang + ".txt")
					raise "Не удалось сгенерировать ReleaseNotes"
			end
			end

			def self.loadChangelog(projectAlias, version_name, version_code, locales, version_code_prefixes = nil)
				locales.split(",").each do |locale|
					lang = locale.split("-")[0].strip.capitalize
					country = locale.strip

					notesFilePath = Dir.pwd + "/../../../notes/#{projectAlias}/#{version_name}_#{lang}.txt"

					if File.exist?(notesFilePath)
						File.delete(notesFilePath)
					end

					generateReleaseNotes("fileClosed", projectAlias, version_name, lang)

					text = FileHelper.read(notesFilePath)

					unless version_code_prefixes.nil?
							version_code_prefix = version_code_prefixes.split(",")
							version_code_prefix.each do |version_code_prefix|
									FileHelper.write(Dir.pwd+"/metadata/android/#{country}/changelogs/#{version_code_prefix}#{version_code}.txt", text)
							end
					end
					FileHelper.write(Dir.pwd+"/metadata/android/#{country}/changelogs/#{version_code}.txt", text)
			end
	  end
      
    end
  end
end
