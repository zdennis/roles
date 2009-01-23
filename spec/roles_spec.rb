require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

class UserWithRoles
  include Roles::RoleMethods
  
  def initialize(*roles)
    @roles = roles
  end

  def roles
    @roles
  end
end

class Roles::SuperUser < Roles::Base
end

class NormalUser < Roles::Base
end

describe Roles do
  it "knows when an object can be a particular role" do
    user = UserWithRoles.new("super user")
    user.should have_role("super user")
    user.should_not have_role("monkey boy")
  end
  
  it "knows when an object can be a particular role when the role responds to :name" do
    super_user_role = stub("role 1", :name => "fanboy")
    user = UserWithRoles.new(super_user_role)
    user.should have_role("fanboy")
  end
  
  it "can put a source object into a specified role using strings" do
    UserWithRoles.new("super user").in_role("super user").should be_kind_of(Roles::SuperUser)
  end

  it "can put a source object into a specified role using symbols" do
    UserWithRoles.new("super user").in_role(:"super user").should be_kind_of(Roles::SuperUser)
  end
  
  it "won't put a source object into a specified role if it doesn't have that role" do
    lambda { 
      UserWithRoles.new("normal user").in_role("super user")
    }.should raise_error(Roles::RoleNotFound, "The #{UserWithRoles.name} doesn't have the 'super user' role.")
  end
  
  it "will use the global namespace if a role can't be found in the Role namespace" do
    UserWithRoles.new("normal user").in_role("normal user").should be_kind_of(NormalUser)
  end
end