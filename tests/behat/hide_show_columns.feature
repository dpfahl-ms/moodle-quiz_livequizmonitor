@quiz_livequizmonitor @mod @mod_quiz @quiz @report
Feature: Hide and show columns on the live quiz monitor report
  In order to declutter the live monitor table
  As a teacher
  I need to hide and show individual columns, with my choice remembered

  Background:
    Given the following "users" exist:
      | username | firstname | lastname | email             |
      | teacher1 | Terry     | Teacher  | teacher1@test.com |
      | student1 | Sam       | Student  | student1@test.com |
    And the following "courses" exist:
      | fullname | shortname | category |
      | Course 1 | C1        | 0        |
    And the following "course enrolments" exist:
      | user     | course | role           |
      | teacher1 | C1     | editingteacher |
      | student1 | C1     | student        |
    And the following "activities" exist:
      | activity | name   | course | timelimit |
      | quiz     | Quiz 1 | C1     | 600       |
    And the following "question categories" exist:
      | contextlevel | reference | name           |
      | Course       | C1        | Test questions |
    And the following "questions" exist:
      | questioncategory | qtype       | name | questiontext |
      | Test questions   | shortanswer | SA1  | What is 2+2? |
    And quiz "Quiz 1" contains the following questions:
      | question | page |
      | SA1      | 1    |
    And I log in as "teacher1"

  Scenario: Student column shows both name and email by default
    Given I am on the live monitor report for "Quiz 1"
    Then I should see "Sam Student"
    And I should see "student1@test.com"

  @javascript
  Scenario: Hiding the Student column keeps the Email column visible
    Given I am on the live monitor report for "Quiz 1"
    And I should see "Sam Student"
    And I should see "student1@test.com"
    When I click on ".livequizmonitor-th[data-column='student'] [data-action='toggle-column']" "css_element"
    Then I should not see "Sam Student"
    And I should see "student1@test.com"

  @javascript
  Scenario: Clicking the toggle a second time shows the Student column again
    Given I am on the live monitor report for "Quiz 1"
    And I click on ".livequizmonitor-th[data-column='student'] [data-action='toggle-column']" "css_element"
    And I should not see "Sam Student"
    When I click on ".livequizmonitor-th[data-column='student'] [data-action='toggle-column']" "css_element"
    Then I should see "Sam Student"

  @javascript
  Scenario: The Status and Actions columns have no hide/show toggle
    Given I am on the live monitor report for "Quiz 1"
    Then ".livequizmonitor-th[data-column='status'] [data-action='toggle-column']" "css_element" should not exist
    And ".livequizmonitor-th[data-column='actions'] [data-action='toggle-column']" "css_element" should not exist

  @javascript
  Scenario: Hidden columns stay hidden after reloading the report
    Given I am on the live monitor report for "Quiz 1"
    And I click on ".livequizmonitor-th[data-column='student'] [data-action='toggle-column']" "css_element"
    And I should not see "Sam Student"
    When I reload the page
    Then I should not see "Sam Student"
    And I should see "student1@test.com"
