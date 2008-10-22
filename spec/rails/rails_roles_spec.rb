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

class RoleShowingClassMethodCallback < Roles::Base
  def employees
    Proxy.new Employee, self
  end
  
  module EmployeeFindCallbacks
    def after_find(record_or_records)
      raise StandardError, "you can't do that #{record_or_records.name}!"
    end
  end
end

class NormalUser < Roles::Base
  def employees
    Proxy.new Employee, self
  end
end


describe Roles, "can add interject find callbacks to an ActiveRecord class with a module defined inside a role's namespace" do
  before(:each) do
    @staff_member = StaffMember.new("role showing class method callbacks")
  end
  
  it "adds callbacks when using the .first method" do
    employee = Employee.new :name => "stan"
    Employee.should_receive(:first).and_return employee
    lambda { 
      @staff_member.in_role("role showing class method callbacks").employees.first
    }.should raise_error(StandardError, "you can't do that #{employee.name}!")
  end

  it "adds callbacks when using the .last method" do
    employee = Employee.new :name => "kyle"
    Employee.should_receive(:last).and_return employee
    lambda { 
      @staff_member.in_role("role showing class method callbacks").employees.last
    }.should raise_error(StandardError, "you can't do that #{employee.name}!")
  end

  it "adds callbacks when using the .all method" do
    employees = [Employee.new]
    def employees.name ; "stan, kyle, eric, and kenny" ; end
    Employee.should_receive(:all).and_return employees
    lambda { 
      @staff_member.in_role("role showing class method callbacks").employees.all
    }.should raise_error(StandardError, "you can't do that #{employees.name}!")    
  end

  it "adds callbacks when using the custom finder methods of ActiveRecord" do
    employee = Employee.new :name => "kenny"
    Employee.should_receive(:find_by_name).and_return employee
    lambda { 
      @staff_member.in_role("role showing class method callbacks").employees.find_by_name("rich")
    }.should raise_error(StandardError, "you can't do that #{employee.name}!")    
  end
  
  it "adds callbacks when named scope methods are used" do
    employees = [Employee.new]
    def employees.name ; "stan, kyle, eric, and kenny" ; end
    Employee.should_receive(:all).and_return employees
    lambda {
      @staff_member.in_role("role showing class method callbacks").employees.descending.all
    }.should raise_error(StandardError, "you can't do that #{employees.name}!")
  end
  
  it "doesn't invoke the callback when a record is not returned by .first, .last, or custom find methods" do
    Employee.stub!(:first => nil, :last => nil, :find_by_something => nil)
    lambda { 
      @staff_member.in_role("role showing class method callbacks").employees.first
      @staff_member.in_role("role showing class method callbacks").employees.last
      @staff_member.in_role("role showing class method callbacks").employees.find_by_something
    }.should_not raise_error
  end

  it "doesn't invoke the callback when an empty array is returned by .all or .find" do
    Employee.stub!(:all => [], :find => [])
    lambda { 
      @staff_member.in_role("role showing class method callbacks").employees.all
      @staff_member.in_role("role showing class method callbacks").employees.find(:all)
    }.should_not raise_error
  end
end


describe Roles, "can extend an ActiveRecord::Base instance with a module defined inside a role's namespace" do
  it "does not extend mixin functionality where there is no module defined" do
    staff_member = StaffMember.new("normal user")
    employee = staff_member.in_role("normal user").employees.first
    lambda { 
      employee.foo
    }.should raise_error(NoMethodError)
  end
  
  it "extends mixin functionality on an instance returned from .first method" do
    staff_member = StaffMember.new("payment operator")
    staff_member.in_role("payment operator").employees.first.foo.should == "foo"
  end
  
  it "extends mixin functionality on an instance returned from .last method" do
    staff_member = StaffMember.new("payment operator")
    staff_member.in_role("payment operator").employees.last.foo.should == "foo"
  end

  it "extends mixin functionality on an instance returned from .all method" do
    staff_member = StaffMember.new("payment operator")
    staff_member.in_role("payment operator").employees.all[0].foo.should == "foo"
  end
  
  it "extends mixin functionality on an instance returned from .find methods" do
    staff_member = StaffMember.new("payment operator")
    employee = Employee.first
    staff_member.in_role("payment operator").employees.find(employee).foo.should == "foo"
    staff_member.in_role("payment operator").employees.find_by_id(employee.id).foo.should == "foo"
  end
end