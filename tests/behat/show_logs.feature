@quiz_livequizmonitor @mod @mod_quiz @quiz @report
Feature: View student logs in Live Quiz Monitor
  In order to review student activity during an active quiz
  As a teacher
  I need to navigate directly to a student's logs

  Background:
    Given the following "users" exist:
      | username | firstname | lastname | email             |
      | teacher1 | Terry     | Teacher  | teacher1@test.com |
      | student1 | Sam       | Student  | student1@test.com |
      | student2 | Alex      | Other    | student2@test.com |
    And the following "courses" exist:
      | fullname | shortname | category |
      | Course 1 | C1        | 0        |
    And the following "course enrolments" exist:
      | user     | course | role           |
      | teacher1 | C1     | editingteacher |
      | student1 | C1     | student        |
      | student2 | C1     | student        |
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

  @javascript @showlogs
  Scenario: Show logs link opens full log report for student with quiz activity
    Given I am on the "Quiz 1" "quiz activity" page logged in as "student1"
    And I press "Attempt quiz"
    And I press "Start attempt"
    And I log in as "teacher1"

    When I am on the live monitor report for "Quiz 1"

    And I click on ".livequizmonitor-row-actions .dropdown-toggle" "css_element" in the "Sam Student" "table_row"
    Then "Show logs" "link" should exist in the "Sam Student" "table_row"

    When I click on "Show logs" "link" in the "Sam Student" "table_row"
    And I switch to a second window

    Then "Get these logs" "button" should exist
    And the field "id" matches value "Course 1"
    And the field "user" matches value "Sam Student"
    And the field "modid" matches value "Quiz 1"

  @javascript @showlogs
  Scenario: Show logs link opens full log report for student with no quiz activity
    When I am on the live monitor report for "Quiz 1"

    And I click on ".livequizmonitor-row-actions .dropdown-toggle" "css_element" in the "Alex Other" "table_row"
    Then "Show logs" "link" should exist in the "Alex Other" "table_row"

    When I click on "Show logs" "link" in the "Alex Other" "table_row"
    And I switch to a second window

    Then "Get these logs" "button" should exist
    And the field "id" matches value "Course 1"
    And the field "user" matches value "Alex Other"
    And the field "modid" matches value "Quiz 1"
    And I should see "Nothing to display"
