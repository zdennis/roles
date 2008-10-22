class Roles
  class RoleNotFound < StandardError ; end

  class Base
    attr_reader :source
    
    def initialize(source)
      @source = source
    end
  end
end

require File.expand_path(File.dirname(__FILE__) + "/roles/methods")
