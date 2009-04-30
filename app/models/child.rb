class Child < ActiveRecord::Base
  has_many :arrivals
  accepts_nested_attributes_for :arrivals
  validates_presence_of :name
end
