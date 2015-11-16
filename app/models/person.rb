class Person < ActiveRecord::Base
  belongs_to :location
  belongs_to :role
  belongs_to :manager, class_name: "Person", foreign_key: :manager_id
  has_many :employees, class_name: "Person", foreign_key: :manager_id

  def self.without_remote_manager
    all
  end

  def self.order_by_location_name
    joins(:location).order("locations.name")
  end

  def self.with_employees
    joins(:employees).distinct
  end

  def self.with_local_coworkers
    joins(location: :people).where("people_locations.id <> people.id").distinct
  end
end
