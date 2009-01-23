require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

class StaffMember
  include Roles::RoleMethods
  attr_reader :roles
  
  def initialize(*roles)
    @roles = roles
  end
end

class StaffMemberWithPrivileges
  include Roles::RoleMethods
  attr_reader :privileges
  
  def initialize(*privileges)
    @privileges = privileges
  end
end


class PaymentOperator < Roles::Base
  def employees
    ActiveRecordProxy.new Employee, self
  end

  module EmployeeMethods
    def foo
      "foo"
    end
  end
end

class Privileges::CrudThings < Privileges::Base
  def employees
    ActiveRecordProxy.new Employee, self
  end

  module EmployeeMethods
    def baz
      "baz"
    end
  end
end

class RoleShowingClassMethodCallback < Roles::Base
  def employees
    ActiveRecordProxy.new Employee, self
  end
  
  module EmployeeFindCallbacks
    def after_find(record, requestor)
      if record.nil?
        raise StandardError, "you found nothing!"
      else
        raise StandardError, "you can't do that #{record.name}!"
      end
    end

    def after_find_collection(records, requestor)
      if records.empty?
        raise StandardError, "you found nothing!"
      else
        raise StandardError, "you can't do that #{records.name}!"
      end
    end
  end
end

class RoleShowingDeclarativeClassMethodCallback < Roles::Base
  def employees
    ActiveRecordProxy.new Employee, self
  end
  
  after_find :employee do |record, requestor|
    if record.nil?
      raise StandardError, "you found nothing!"
    else
      raise StandardError, "you can't do that #{record.name}!"
    end
  end
  
  after_find_collection :employee do |records, requestor|
    if records.empty?
      raise StandardError, "you found nothing!"
    else
      raise StandardError, "you can't do that #{records.name}!"
    end
  end
end


class NormalUser < Roles::Base
  def employees
    ActiveRecordProxy.new Employee, self
  end
end


["role showing class method callbacks", "role showing declarative class method callbacks"].each do |role|
  describe Roles, "can add interject find callbacks to an ActiveRecord class with a module defined inside a role's namespace" do
    describe role do
      before(:each) do
        @staff_member = StaffMember.new(role)
      end
  
      %w(first last find_by_custom_finder_methods).each do |find_method|
        it "invokes find callbacks when using the .#{find_method} method" do
          employee = Employee.new :name => "stan"
          Employee.should_receive(find_method).and_return employee
          lambda { 
            @staff_member.in_role(role).employees.__send__ find_method
          }.should raise_error(StandardError, "you can't do that #{employee.name}!")
        end
        
        it "invokes the callback when a record is not found by #{find_method}" do
          Employee.stub!(find_method).and_return nil
          lambda { 
            @staff_member.in_role(role).employees.__send__ find_method
          }.should raise_error(StandardError, "you found nothing!")
        end
      end

      it "invokes callbacks when records are found using .all" do
        employees = [Employee.new]
        def employees.name ; "stan, kyle, eric, and kenny" ; end
        Employee.should_receive(:all).and_return employees
        lambda { 
          @staff_member.in_role(role).employees.all
        }.should raise_error(StandardError, "you can't do that #{employees.name}!")    
      end

      it "invokes the callback when an no records are found by .all" do
        Employee.stub!(:all).and_return []
        lambda { 
          @staff_member.in_role(role).employees.all
        }.should raise_error(StandardError, "you found nothing!")    
      end
        
      it "invokes callbacks when named scope methods are used" do
        employees = [Employee.new]
        def employees.name ; "stan, kyle, eric, and kenny" ; end
        Employee.should_receive(:all).and_return employees
        lambda {
          @staff_member.in_role(role).employees.descending.all
        }.should raise_error(StandardError, "you can't do that #{employees.name}!")
      end
    end
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


describe Privileges, "can extend privilege functionality on an ActiveRecord::Base instance with a module defined inside a role's namespace" do
  it "does not extend mixin functionality where there is no module defined" do
    staff_member = StaffMemberWithPrivileges.new("crud_things")
    employee = staff_member.with_privilege("crud_things").employees.first
    lambda { 
      employee.bar
    }.should raise_error(NoMethodError)
  end
  
  it "extends mixin functionality on an instance returned from .first method" do
    staff_member = StaffMemberWithPrivileges.new("crud_things")
    staff_member.with_privilege("crud_things").employees.first.baz.should == "baz"
  end
  
  it "extends mixin functionality on an instance returned from .last method" do
    staff_member = StaffMemberWithPrivileges.new("crud_things")
    staff_member.with_privilege("crud_things").employees.last.baz.should == "baz"
  end
  
  it "extends mixin functionality on an instance returned from .all method" do
    staff_member = StaffMemberWithPrivileges.new("crud_things")
    staff_member.with_privilege("crud_things").employees.all[0].baz.should == "baz"
  end
  
  it "extends mixin functionality on an instance returned from .find methods" do
    staff_member = StaffMemberWithPrivileges.new("crud_things")
    employee = Employee.first
    staff_member.with_privilege("crud_things").employees.find(employee).baz.should == "baz"
    staff_member.with_privilege("crud_things").employees.find_by_id(employee.id).baz.should == "baz"
  end
end
