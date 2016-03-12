require "spec_helper"

describe Person do
  describe "#without_remote_manager" do
    it "returns people who have no manager or whose manager is local" do
      local = create(:location)
      remote = create(:location)
      local_manager = create(
        :person,
        location: local,
        name: "local_manager",
        manager: nil
      )
      remote_manager = create(
        :person,
        location: remote,
        name: "remote_manager",
        manager: nil
      )
      create(
        :person,
        location: local,
        manager: local_manager,
        name: "has_local_manager"
      )
      create(
        :person,
        location: local,
        manager: remote_manager,
        name: "has_remote_manager"
      )

      result = Person.without_remote_manager

      expect(result.map(&:name)).
        to match_array(%w(local_manager remote_manager has_local_manager))
    end
  end

  describe ".order_by_location_name" do
    it "groups people by location" do
      locations = [
        create(:location, name: "location1"),
        create(:location, name: "location3"),
        create(:location, name: "location2")
      ]
      locations.each do |location|
        create(:person, location: location, name: "at-#{location.name}")
      end

      result = Person.order_by_location_name

      expect(result.map(&:name)).
        to eq(%w(at-location1 at-location2 at-location3))
    end
  end

  describe ".with_employees" do
    it "finds people who manage employees" do
      managers = [
        create(:person, name: "manager-one"),
        create(:person, name: "manager-two")
      ]
      managers.each do |manager|
        2.times do
          create(:person, name: "employee-of-#{manager.name}", manager: manager)
        end
      end

      result = Person.with_employees

      expect(result.map(&:name)).to match_array(%w(manager-one manager-two))
    end
  end

  describe ".with_local_coworkers" do
    it "finds people with other people at the same location" do
      location = create(:location)
      other_location = create(:location)
      create(:person, location: location, name: "with-coworkers-one")
      create(:person, location: location, name: "with-coworkers-two")
      create(:person, location: location, name: "with-coworkers-three")
      create(:person, location: other_location, name: "without-coworkers")

      result = Person.with_local_coworkers

      expect(result.map(&:name)).to match_array(%w(
        with-coworkers-one
        with-coworkers-two
        with-coworkers-three
      ))
    end
  end

  describe ".with_employees.with_local_coworkers.order_by_location_name" do
    it "combines scopes" do
      locations = [
        create(:location, name: "location1"),
        create(:location, name: "location3"),
        create(:location, name: "location2")
      ]
      managers = locations.map do |location|
        create(:person, name: "coworker-#{location.name}", location: location)
        create(:person, name: "manager-#{location.name}", location: location)
      end
      managers.each do |manager|
        2.times do
          create(:person, name: "employee-#{manager.name}", manager: manager)
        end
      end

      result = Person.with_employees.with_local_coworkers.order_by_location_name

      expect(result.map(&:name)).to eq(%w(
        manager-location1
        manager-location2
        manager-location3
      ))
    end
  end
end
