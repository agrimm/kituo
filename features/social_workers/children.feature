Feature:
  As a social worker
  I want to manage my children
  So that we have accurate data in the system

  Background:
    Given the following users exist:
      | Role          | Name        |
      | Social Worker | Xavier Shay |
    And the following scheduled visits exist:
      | Social Worker | Child       | Location | Date                      |
      | Xavier Shay   | Juma Masawe | Moshi    | the 1st day of this month |
    And I am signed in as "Xavier Shay"

  Scenario: Editing a child
    Given I follow "Juma Masawe"
    And I follow "Edit"
    And I fill in "child_name" with "Jumanne"
    And I select "Xavier Shay" from "child_social_worker_id"
    And I fill in "child_location" with "Arusha"
    And I press "Save"

    Then I should see "Jumanne"
    And I should see "Xavier Shay"
    And I should see "Arusha"

  Scenario: Changing the state of a child
    Given I follow "Juma Masawe"
    And I follow "Edit"
    And I select "Reunified" from "child_state"
    And I press "Save"
    Then I should see "Reunified"
    Then I should see a reunification event for "today"

  @javascript
  Scenario: Changing the date of an event for a child
    And the following events exist:
      | Child       | Event         | Date                      |
      | Juma Masawe | Reunification | the 2nd day of this month |
      | Juma Masawe | Arrival       | the 3rd day of this month |
    Given I follow "Juma Masawe"
    Then I should see "At Amani"
    Given I follow "Edit" for the event that happened on "the 3rd day of this month"
    And I follow day "1" in the calendar
    Then I should see an arrival event for "the 1st day of this month"
    Then I should see that the child's state is "Reunified"

  Scenario: Destroying an event for a child
    And the following events exist:
      | Child       | Event         | Date                      |
      | Juma Masawe | Reunification | the 2nd day of this month |
    Given I follow "Juma Masawe"
    Given I follow "Delete" for the event that happened on "the 2nd day of this month"
    Then I should not see a reunification event for "the 2nd day of this month"
    Then I should see that the child's state is "Unknown status"

  @javascript
  Scenario: Scheduling a visit from the child page
    Given I follow "Juma Masawe"
    Given I follow "Schedule a new visit"
    And I follow day "2" in the calendar
    Then I should see a scheduled visit for "the 2nd day of this month"

  Scenario: Completing a visit from the child page
    Given I follow "Juma Masawe"
    Given I follow "Complete" for the visit scheduled for "the 1st day of this month"
    Then I should see a home visit for "the 1st day of this month"
    And I should not see a scheduled visit for "the 1st day of this month"

  @javascript
  Scenario: Editing a visit from the child page
    Given I follow "Juma Masawe"
    Given I follow "Edit" for the visit scheduled for "the 1st day of this month"
    And I follow day "2" in the calendar
    Then I should see a scheduled visit for "the 2nd day of this month"
    And I should not see a scheduled visit for "the 1st day of this month"

  Scenario: Unscheduling a visit from the child page
    Given I follow "Juma Masawe"
    Given I follow "Unschedule" for the visit scheduled for "the 1st day of this month"
    Then I should not see a scheduled visit for "the 1st day of this month"
