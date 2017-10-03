module Fastlane
	module Helper
		class ProjectVersion
			attr_accessor :major_version, :minor_version, :patch_version, :build_number
			def initialize(major_version, minor_version, patch_version = nil, build_number = nil)
				@major_version = major_version.to_i
				@minor_version = minor_version.to_i
				@patch_version = patch_version.to_s.empty? ? nil : patch_version.to_i
				@build_number = build_number.to_s.empty? ? nil : build_number.to_i
			end
			
			def to_s
				return "#{self.major_version}.#{self.minor_version}" + (self.patch_version.nil? ? '' : ".#{self.patch_version}") + (self.build_number.nil? ? '' : "(#{self.build_number})")
			end

			def normalized_name
				return "#{self.major_version}.#{self.minor_version}" + (self.patch_version.nil? ? '' : ".#{self.patch_version}")
			end

			def set_new_version(major_version, minor_version, patch_version = nil, build_number = nil)
				self.major_version = major_version
				self.minor_version = minor_version
				self.patch_version = patch_version.nil? ? nil : patch_version
				self.build_number = build_number.nil? ? nil : build_number
			end
			
			def increment_major_version
				set_new_version(self.major_version + 1, self.minor_version, self.patch_version, self.build_number)
			end
			
			def increment_minor_version
				set_new_version(self.major_version, self.minor_version + 1, self.patch_version, self.build_number)
			end
			
			def increment_patch_version
				set_new_version(self.major_version, self.minor_version, self.patch_version.nil? ? 1 : self.patch_version + 1, self.build_number)
			end
			
			def increment_build_number
				set_new_version(self.major_version, self.minor_version, self.patch_version, self.build_number.nil? ? 1 : self.build_number + 1)
			end
		end
	end
end
