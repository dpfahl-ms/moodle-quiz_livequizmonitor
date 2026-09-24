@quiz_livequizmonitor @mod @mod_quiz @quiz @report
Feature: Filter by group override in live quiz monitor
  In order to quickly find students affected by a group extension
  As a teacher
  I need to filter the live quiz monitor by group override

  Background:
    Given the following "users" exist:
      | username | firstname | lastname | email             |
      | teacher1 | Terry     | Teacher  | teacher1@test.com |
      | student1 | Student   | ONE      | student1@test.com |
      | student2 | Student   | TWO      | student2@test.com |
      | student3 | Student   | THREE    | student3@test.com |
    And the following "courses" exist:
      | fullname | shortname | category |
      | Course 1 | C1        | 0        |
    And the following "course enrolments" exist:
      | user     | course | role           |
      | teacher1 | C1     | editingteacher |
      | student1 | C1     | student        |
      | student2 | C1     | student        |
      | student3 | C1     | student        |
    And the following "groups" exist:
      | name    | course | idnumber |
      | Group A | C1     | GA       |
    And the following "group members" exist:
      | user     | group |
      | student1 | GA    |
      | student3 | GA    |
    And the following "activities" exist:
      | activity | name   | course | timelimit |
      | quiz     | Quiz 1 | C1     | 0         |
    And the following "question categories" exist:
      | contextlevel | reference | name           |
      | Course       | C1        | Test questions |
    And the following "questions" exist:
      | questioncategory | qtype       | name | questiontext |
      | Test questions   | shortanswer | SA1  | What is 2+2? |
    And quiz "Quiz 1" contains the following questions:
      | question | page |
      | SA1      | 1    |
    And group "Group A" has a time limit override on quiz "Quiz 1"

  @javascript
  Scenario: Teacher can filter students down to only those with a group override
    Given I log in as "teacher1"
    And I am on the live monitor report for "Quiz 1"

    Then "With group override (2)" "button" should exist
    And I should see "Student ONE" in the "[data-region='student-table']" "css_element"
    And I should see "Student TWO" in the "[data-region='student-table']" "css_element"
    And I should see "Student THREE" in the "[data-region='student-table']" "css_element"

    When I click on "With group override (2)" "button"
    Then I should see "Student ONE" in the "[data-region='student-table']" "css_element"
    And I should not see "Student TWO" in the "[data-region='student-table']" "css_element"
    And I should see "Student THREE" in the "[data-region='student-table']" "css_element"

  @javascript
  Scenario: Clear filters resets the group override toggle
    Given I log in as "teacher1"
    And I am on the live monitor report for "Quiz 1"

    When I click on "With group override (2)" "button"
    And I should not see "Student TWO" in the "[data-region='student-table']" "css_element"
    And I click on "Reset all filters" "button"

    Then I should see "Student TWO" in the "[data-region='student-table']" "css_element"
    And "With group override (2)" "button" should exist

  @javascript
  Scenario: A user override takes precedence over a group override for the same student
    Given user "student1" has an attempts override on quiz "Quiz 1"
    And I log in as "teacher1"
    And I am on the live monitor report for "Quiz 1"

    # student1 has BOTH a user override and membership in the overridden group,
    # so only student3 should count towards the group-override total.
    Then "With group override (1)" "button" should exist
    And "With user override (1)" "button" should exist

    # student1 shows the user-override badge (fa-user-gear), not the group one.
    And "[data-field='fullname'] i[data-override-badge='user']" "css_element" should exist in the "Student ONE" "table_row"
    And "[data-field='fullname'] i[data-override-badge='group']" "css_element" should not exist in the "Student ONE" "table_row"

    # student3 (group only) shows the group-override badge (fa-users-gear).
    And "[data-field='fullname'] i[data-override-badge='group']" "css_element" should exist in the "Student THREE" "table_row"
    And "[data-field='fullname'] i[data-override-badge='user']" "css_element" should not exist in the "Student THREE" "table_row"

  @javascript
  Scenario: Time-related badge appears for both user and group time-related overrides
    Given I log in as "teacher1"
    And I am on the live monitor report for "Quiz 1"

    # Both group members get the timer badge from the group's time-related override.
    Then "[data-field='timeremaining'] .livequizmonitor-override-flag-timer" "css_element" should exist in the "Student ONE" "table_row"
    And "[data-field='timeremaining'] .livequizmonitor-override-flag-timer" "css_element" should exist in the "Student THREE" "table_row"
    And "[data-field='timeremaining'] .livequizmonitor-override-flag-timer" "css_element" should not exist in the "Student TWO" "table_row"

  @javascript
  Scenario: The user-override and group-override toggles are mutually exclusive with each other
    Given user "student2" has an attempts override on quiz "Quiz 1"
    And I log in as "teacher1"
    And I am on the live monitor report for "Quiz 1"

    When I click on "With user override (1)" "button"
    Then "With user override (1)" "button" should be visible
    And the "aria-pressed" attribute of "With user override (1)" "button" should contain "true"
    And the "aria-pressed" attribute of "With group override (2)" "button" should contain "false"

    # Clicking the group-override button cancels the user-override one, not adds to it.
    When I click on "With group override (2)" "button"
    Then the "aria-pressed" attribute of "With group override (2)" "button" should contain "true"
    And the "aria-pressed" attribute of "With user override (1)" "button" should contain "false"
    And I should see "Student ONE" in the "[data-region='student-table']" "css_element"
    And I should not see "Student TWO" in the "[data-region='student-table']" "css_element"

    # They do NOT cancel the status chips, which remain an independent (AND) dimension.
    When I click on "In progress" "button"
    Then the "aria-pressed" attribute of "In progress" "button" should contain "true"
    And the "aria-pressed" attribute of "With group override (2)" "button" should contain "true"
