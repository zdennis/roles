module Roles::RoleMethods
  def has_role?(role)
    if roles.first.respond_to?(:name)
      return true if roles.map(&:name).include?(role)
    else
      return true if roles.include?(role)
    end
    false
  end
  
  def in_role(role)
    if has_role?(role)
      Roles.const_get(role.gsub(/\s+/, "_").classify).new self
    else
      raise Roles::RoleNotFound, "The #{self.class.name} doesn't have the '#{role}' role."
    end
  end
end