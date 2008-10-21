require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'rubygems'
require 'active_record'
require 'roles/extensions/rails'

def load_rails_test_database
  dbfile = File.join( File.dirname( __FILE__ ), 'test.db' )
  config = ActiveRecord::Base.configurations['test'] = { 
    :adapter  => "sqlite3",
    :dbfile => dbfile }
  ActiveRecord::Base.establish_connection config

  ActiveRecord::Schema.define(:version => 20081021175239) do
    create_table "employees", :force => true do |t|
      t.string   "title"
      t.string   "name"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end
end

def load_rails_test_data
  Employee.create!(:name => "Bob", :title => "supervisor")
  Employee.create!(:name => "Frank", :title => "employee")
end

class Employee < ActiveRecord::Base
end

load_rails_test_database
load_rails_test_data