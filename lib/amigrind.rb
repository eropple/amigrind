require 'amigrind/version'
require 'amigrind/core'
require 'amigrind/config'
require 'amigrind/repo'

require 'ptools'
require 'open3'
require 'fileutils'
require 'aws-sdk'
require 'racker'
require 'json'
require 'yaml'
require 'ice_nine'
require 'set'
require 'erubis'
require 'virtus'
require 'active_support/core_ext/string/inflections'
require 'active_support/core_ext/hash'
require 'active_support/core_ext/numeric/time'

# Pre-includes
module Amigrind
end

Dir["#{__dir__}/**/*.rb"].reject { |f| f.include?('/cli') }.sort.each { |f| require_relative f }

# Post-includes
module Amigrind
end
