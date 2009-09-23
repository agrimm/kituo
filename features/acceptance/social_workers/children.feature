Feature:
  As a social worker
  I want to manage my children
  So that we have accurate data in the system

  Background:
    Given the following users exist:
      | Type          | Name        |
      | Social Worker | Xavier Shay |
    And the following scheduled visits exist:
      | Social Worker | Child       | Location | Date                 |
      | Xavier Shay   | Juma Masawe | Moshi    | First day this month |
    And I am signed in as "Xavier Shay"
    Given I click "Juma Masawe"

  Scenario: Editing a child
    And I click "Edit"
    And I fill in "child_name" with "Jumanne"
    And I select "Xavier Shay" from "child_social_worker_id"
    And I fill in "child_location" with "Arusha"
    And I press "Save"

    Then I should see "Jumanne"
    And I should see "Xavier Shay"
    And I should see "Arusha"

  Scenario: Changing the state of a child
    And I click "Edit"
    And I select "Reunified" from "child_state"
    And I press "Save"
    Then I should see "Reunified"
    Then I should see a reunification event for "today"

  Scenario: Scheduling a visit from the child page
    Given I click "Schedule a new visit"
    And I click day "2" in the calendar
    Then I should see a scheduled visit for "the second day of this month"

  Scenario: Completing a visit from the child page
    Given I click "Complete" for the visit scheduled for "the first day of this month"
    Then I should see a home visit for "the first day of this month"
    And I should not see a scheduled visit for "the first day of this month"

  Scenario: Editing a visit from the child page
    Given I click "Edit" for the visit scheduled for "the first day of this month"
    And I click day "2" in the calendar
    Then I should see a scheduled visit for "the second day of this month"
    And I should not see a scheduled visit for "the first day of this month"

  Scenario: Unscheduling a visit from the child page
    Given I click "Unschedule" for the visit scheduled for "the first day of this month"
    Then I should not see a scheduled visit for "the first day of this month"
