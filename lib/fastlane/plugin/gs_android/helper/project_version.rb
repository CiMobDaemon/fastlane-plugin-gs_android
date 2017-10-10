class Integer
	def major
		Fastlane::Helper::ProjectVersion.new(self, 0)
	end

	def minor
		Fastlane::Helper::ProjectVersion.new(0, self)
	end

	def patch
		Fastlane::Helper::ProjectVersion.new(0, 0, self)
	end

	def build
		Fastlane::Helper::ProjectVersion.new(0, 0, nil, self)
	end
end

module Fastlane
	module Helper
		class ProjectVersion

			#return 0 if arg == nil
			def nullable(arg)
				arg == nil ? 0 : arg
			end

			def nullable_add(arg0, arg1)
				if arg0.nil? && arg1.nil?
					nil
				else
					nullable(arg0) + nullable(arg1)
				end
			end


			attr_accessor :major_version, :minor_version, :patch_version, :build_number
			def initialize(major_version, minor_version, patch_version = nil, build_number = nil)
				@major_version = major_version.to_i
				@minor_version = minor_version.to_i
				@patch_version = patch_version.to_s.empty? ? nil : patch_version.to_i
				@build_number = build_number.to_s.empty? ? nil : build_number.to_i
			end

			def ignore_patch
				ProjectVersion.new(self.major_version, self.minor_version, nil, self.build_number)
			end

			def ignore_build
				ProjectVersion.new(self.major_version, self.minor_version, self.patch_version, nil)
			end

			def to_s
				"#{self.major_version}.#{self.minor_version}" + (self.patch_version.nil? ? '' : ".#{self.patch_version}") + (self.build_number.nil? ? '' : "(#{self.build_number})")
			end

			def +(version)
				ProjectVersion.new(self.major_version + version.major_version,
													 self.minor_version + version.minor_version,
													 nullable_add(self.patch_version, version.patch_version),
													 nullable_add(self.build_number, version.build_number))
			end

			def <=>(version)
				if !version.instance_of? ProjectVersion
					nil

				elsif (self.major_version <=> version.major_version) != 0
					(self.major_version <=> version.major_version)

				elsif (self.minor_version <=> version.minor_version) != 0
					(self.minor_version <=> version.minor_version)

				elsif (nullable(self.patch_version) <=> nullable(version.patch_version)) != 0
					(nullable(self.patch_version) <=> nullable(version.patch_version))

				else
					(nullable(self.build_number) <=> nullable(version.build_number))
				end
			end

			def ==(version)
				(self <=> version) == 0
			end

			def <(version)
				(self <=> version) < 0
			end

			def >(version)
				(self <=> version) > 0
			end

			def <=(version)
				!(self > version)
			end

			def >=(version)
				!(self < version)
			end
		end
	end
end
