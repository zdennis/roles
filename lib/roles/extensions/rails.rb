class Roles::Base
  def self.after_find_for(klass, &blk)
    module_name = "#{klass.name}FindCallbacks"
    constant = self.const_set(module_name, Module.new)
    constant.instance_eval do 
      define_method(:after_find) do |*args|
        blk.call *args
      end
    end
  end
  
  class Proxy < BlankSlate
    CALLBACK_METHOD_REGEXP = /^((all|first|last)|find_.*)$/

    def initialize(obj_to_proxy, proxy_source)
      @obj_to_proxy = obj_to_proxy
      @proxy_source = proxy_source
    end
    
    def method_missing(method_name, *args, &blk)
      result = @obj_to_proxy.send method_name, *args, &blk

      if proxy_object_is_ancestor_of? ActiveRecord::Base
        find_and_execute_class_level_find_callbacks_for method_name, result
      end

      if result.kind_of?(ActiveRecord::Base)
        find_and_mixin_custom_module_functionality result
        result
      else
        Proxy.new result, @proxy_source
      end
    end
    
  private
  
    def proxy_object_is_ancestor_of?(klass)
      @obj_to_proxy.respond_to?(:ancestors) && @obj_to_proxy.ancestors.include?(klass)
    end
    
    def find_and_mixin_custom_module_functionality(record)
      module_name = "#{record.class.name}Methods"
      if @proxy_source.class.const_defined?(module_name)
        record.extend @proxy_source.class.const_get(module_name)
      end
    end
    
    def find_and_execute_class_level_find_callbacks_for method_name, record_or_records
      if method_name.to_s =~ CALLBACK_METHOD_REGEXP
        if record_or_records.is_a?(Array)
          namespace = record_or_records.first.class.name
        else
          namespace = record_or_records.class.name
        end
        module_name = "#{namespace}FindCallbacks"
        if @proxy_source.class.const_defined?(module_name)
          constant = @proxy_source.class.const_get(module_name)
          if constant.instance_methods.include?("after_find")
            Object.new.extend(constant).after_find record_or_records, @proxy_source.source
          end
        end
      end
    end

  end
end