class Roles::Base

  class Proxy < BlankSlate
    def initialize(obj_to_proxy, proxy_source)
      @obj_to_proxy = obj_to_proxy
      @proxy_source = proxy_source
    end
    
    def method_missing(method_name, *args, &blk)
      result = @obj_to_proxy.send method_name, *args, &blk
      if result.kind_of?(ActiveRecord::Base)
        find_and_mixin_custom_module_functionality result
        result
      else
        Proxy.new result, @proxy_source
      end
    end
    
  private
    
    def find_and_mixin_custom_module_functionality(object_to_extend)
      module_name = "#{object_to_extend.class.name}Methods"
      if @proxy_source.class.const_defined?(module_name)
        object_to_extend.extend @proxy_source.class.const_get(module_name)
      end
    end
    
  end
end