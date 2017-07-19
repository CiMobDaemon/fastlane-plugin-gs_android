module Fastlane
	module Helper
		class ProjectVersion
    		attr_reader :major_version, :minor_version, :patch_version, :build_number
      		def initialize(major_version, minor_version, patch_version = nil, build_number = nil)
				@major_version = major_version
				@minor_version = minor_version
				@patch_version = patch_version
				@build_number = build_number
			end
			
			def to_s
				return "#{self.major_version}.#{self.minor_version}" + self.patch_version.nil? ? "" : ".#{self.patch_version}" + self.build_number.nil? ? "" : "(#{self.patch_version})"
			end
			
			def set_new_version(major_version, minor_version, patch_version = nil, build_number = nil)
				self.major_version = major_version
				self.minor_version = minor_version
				self.patch_version = patch_version.nil? ? nil : patch_version
				self.build_number = build_number.nil? ? nil : build_number
			end
			
			def increment_major_version
				set_new_version(self.major_version+1, self.minor_version, self.patch_version, self.build_number)
			end
			
			def increment_minor_version
				set_new_version(self.major_version, self.minor_version+1, self.patch_version, self.build_number)
			end
			
			def increment_patch_version
				set_new_version(self.major_version, self.minor_version, self.patch_version.nil? ? nil : self.patch_version + 1, self.build_number)
			end
			
			def increment_build_number
				set_new_version(self.major_version, self.minor_version, self.patch_version, self.build_number.nil? ? nil : self.build_number + 1)
			end
		end
  	end
end
