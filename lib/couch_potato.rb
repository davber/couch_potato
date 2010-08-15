require 'couchrest'
require 'json'
require 'json/add/core'
require 'json/add/rails'

require 'ostruct'

unless defined?(CouchPotato)
  module CouchPotato
    DEFAULT_TYPE_FIELD = 'ruby_class'

    # The name of the type field of CouchDB documents
    @@type_field = DEFAULT_TYPE_FIELD
    # The function mapping classes to the corresponding CouchDB design document.
    @@design_name_fun = lambda do |klass|
      klass_name = klass.to_s
      klass_name.gsub!(/([A-Z]+)([A-Z][a-z])/,'\1_\2')
      klass_name.gsub!(/([a-z\d])([A-Z])/,'\1_\2')
      klass_name.tr!("-", "_")
      klass_name.downcase
    end

    # Get the type field name to use.
    # NOTE: this is universal, so will transcend individual databases
    def self.type_field
      @@type_field
    end

    def self.type_field= type_field
      @@type_field = type_field
    end

    # Get the lambda to use for conversion from a class to the design document name
    def self.design_name_fun
      @@design_name_fun
    end

    def self.design_name_fun= fun
      @@design_name_fun = fun
    end

    Config = Struct.new(:database_name, :validation_framework).new
    Config.validation_framework = :validatable # default to the validatable gem for validations

    # Returns a database instance which you can then use to create objects and query views. You have to set the CouchPotato::Config.database_name before this works.
    def self.database
      @@__database ||= Database.new(self.couchrest_database)
    end

    # Returns the underlying CouchRest database object if you want low level access to your CouchDB. You have to set the CouchPotato::Config.database_name before this works.
    def self.couchrest_database
      @@__couchrest_database ||= CouchRest.database(full_url_to_database)
    end

    private

    def self.full_url_to_database
      raise('No Database configured. Set CouchPotato::Config.database_name') unless CouchPotato::Config.database_name
      if CouchPotato::Config.database_name.match(%r{https?://})
        CouchPotato::Config.database_name
      else
        "http://127.0.0.1:5984/#{CouchPotato::Config.database_name}"
      end
    end
  end
end

JSON.create_id = CouchPotato.type_field

$LOAD_PATH << File.dirname(__FILE__)

require 'core_ext/object'
require 'core_ext/time'
require 'core_ext/date'
require 'core_ext/string'
require 'core_ext/symbol'
require 'couch_potato/validation'
require 'couch_potato/persistence'
require 'couch_potato/railtie' if defined?(Rails)
