require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

class UserWithPrivileges
  include Roles::RoleMethods
  
  attr_reader :privileges
    
  def initialize(*privileges)
    @privileges = privileges
  end
end

class Privileges::CrudPeople < Privileges::Base
end

class CrudAnimals < Privileges::Base
end

describe Privileges do
  it "knows when an object has a particular privilege" do
    user = UserWithPrivileges.new("crud_things")
    user.should have_privilege("crud_things")
    user.should_not have_privilege("destroy_the_world")
  end
  
  it "knows when an object has a privilege when the privilege responds to :name" do
    crud_things_privilege = stub("privilege", :name => "crud_things")
    user = UserWithPrivileges.new(crud_things_privilege)
    user.should have_privilege("crud_things")
  end
  
  it "can make a source object into a specified privilege using strings" do
    UserWithPrivileges.new("crud_people").with_privilege("crud_people").should be_kind_of(Privileges::CrudPeople)
  end

  it "can make a source object into a specified privilege using symbols" do
    UserWithPrivileges.new("crud_people").with_privilege(:crud_people).should be_kind_of(Privileges::CrudPeople)
  end
  
  it "won't make a source object into a specified privilege if it doesn't have that privilege" do
    lambda { 
      UserWithPrivileges.new("crud_people").with_privilege("destroy_the_world")
    }.should raise_error(Privileges::PrivilegeNotFound, "The #{UserWithPrivileges.name} doesn't have the 'destroy_the_world' privilege.")
  end
  
  it "will use the global namespace if a role can't be found in the Role namespace" do
    UserWithPrivileges.new("crud_animals").with_privilege("crud_animals").should be_kind_of(CrudAnimals)
  end
end

