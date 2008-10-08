module Role::Methods
  def has_role?(role)
    return true if roles.include?(role)
    false
  end
  
  def in_role(role)
    Role.const_get(role.gsub(/\s+/, "_").classify).new self
  end
end