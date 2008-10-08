require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

class User
  include Role::Methods
  
  def initialize(*roles)
    @roles = roles
  end

  def roles
    @roles
  end
end

class Role::SuperUser < Role
end

class NormalUser < Role
end

describe Role do
  it "knows when an object can be a particular role" do
    user = User.new("super user")
    user.should have_role("super user")
    user.should_not have_role("monkey boy")
  end
  
  it "can put a source object in a specified role" do
    User.new("super user").in_role("super user").should be_kind_of(Role::SuperUser)
  end
  
  it "will use the global namespace if a role can't be found in the Role namespace" do
    User.new("normal user").in_role("normal user").should be_kind_of(NormalUser)
  end
end