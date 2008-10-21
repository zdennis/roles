require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

class StaffMember
  include Roles::RoleMethods
  attr_reader :roles
  
  def initialize(*roles)
    @roles = roles
  end
end

class PaymentOperator < Roles::Base
  def employees
    Proxy.new Employee, self
  end

  module EmployeeMethods
    def foo
      "foo"
    end
  end
end

class NormalUser < Roles::Base
  def employees
    Proxy.new Employee, self
  end
end


describe Roles, "extending an ActiveRecord::Base instance with a module defined inside a role's namespace" do
  it "does not extend mixin functionality where there is no module defined" do
    staff_member = StaffMember.new("normal user")
    employee = staff_member.in_role("normal user").employees.first
    lambda { 
      employee.foo
    }.should raise_error(NoMethodError)
  end
  
  it "extends mixin functionality when using the ActiveRecord::Base.first method" do
    staff_member = StaffMember.new("payment operator")
    staff_member.in_role("payment operator").employees.first.foo.should == "foo"
  end
  
  it "extends mixin functionality when using the ActiveRecord::Base.last method" do
    staff_member = StaffMember.new("payment operator")
    staff_member.in_role("payment operator").employees.last.foo.should == "foo"
  end

  it "extends mixin functionality when using the ActiveRecord::Base.all method" do
    staff_member = StaffMember.new("payment operator")
    staff_member.in_role("payment operator").employees.all[0].foo.should == "foo"
  end
  
  it "extends mixin functionality when using the ActiveRecord::Base.find methods" do
    staff_member = StaffMember.new("payment operator")
    employee = Employee.first
    staff_member.in_role("payment operator").employees.find(employee).foo.should == "foo"
    staff_member.in_role("payment operator").employees.find_by_id(employee.id).foo.should == "foo"
  end
end