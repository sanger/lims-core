# requirement used by  everything
require 'facets/string'
require 'facets/kernel'
require 'facets/hash'
require 'facets/array'

require 'virtus'
require 'aequitas/virtus_integration'

module Lims::Core
  module Helpers
    def self.gem_available?(gem_name)
      begin
        Gem::Specification.find_by_name(gem_name)
      rescue Gem::LoadError
        false
      end
    end

    # Load the available gem for json
    if gem_available?('jrjackson')
      require 'jrjackson'
      def self.to_json(object)
        JrJackson::Json.dump(object)
      end

      def self.load_json(json)
        JrJackson::Json.load(json)
      end
    elsif gem_available?('oj')
      require 'oj'
      def self.to_json(object)
        Oj.dump(object, :mode => :compat)
      end

      def self.load_json(json)
        Oj.load(json)
      end
    else
      require 'json'
      def self.to_json(object)
        object.to_json
      end

      def self.load_json(json)
        JSON.parse(json)
      end
    end
  end
end

class Object
  def andtap(&block)
    self && (block ? block[self] : self)
  end

  def self.parent_scope()
    @__parent_scope ||= eval self.name.split('::').tap { |_| _.pop }.join('::')
  end
end
