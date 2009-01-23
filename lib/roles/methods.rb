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
    role = role.to_s
    if has_role?(role)
      Roles.const_get(role.gsub(/\s+/, "_").classify).new self
    else
      raise Roles::RoleNotFound, "The #{self.class.name} doesn't have the '#{role}' role."
    end
  end
  
  def has_privilege?(privilege)
    if privileges.first.respond_to?(:name)
      return true if privileges.map(&:name).include?(privilege)
    else
      return true if privileges.include?(privilege)
    end
    false
  end
  
  def with_privilege(privilege)
    privilege = privilege.to_s
    if has_privilege?(privilege)
      Privileges.const_get(privilege.gsub(/\s+/, "_").classify.pluralize).new self
    else
      raise Privileges::PrivilegeNotFound, "The #{self.class.name} doesn't have the '#{privilege}' privilege."
    end
  end
end