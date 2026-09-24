@quiz_livequizmonitor @mod @mod_quiz @quiz @report
Feature: View student attempts in Live Quiz Monitor
  In order to review student attempts during an active quiz
  As a teacher
  I need to navigate directly to the quiz overview report

  Background:
    Given the following "users" exist:
      | username | firstname | lastname | email             |
      | teacher1 | Terry     | Teacher  | teacher1@test.com |
      | student1 | Sam       | Student  | student1@test.com |
      | student2 | Jane      | Student  | student2@test.com |
      | student3 | Alex      | Other    | student3@test.com |
    And the following "courses" exist:
      | fullname | shortname | category |
      | Course 1 | C1        | 0        |
    And the following "course enrolments" exist:
      | user     | course | role           |
      | teacher1 | C1     | editingteacher |
      | student1 | C1     | student        |
      | student2 | C1     | student        |
      | student3 | C1     | student        |
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

  @javascript @showattempts
  Scenario: Show attempts link opens quiz overview report for student with quiz activity
    # Student 1 starts a quiz and creates an attempt.
    Given I am on the "Quiz 1" "quiz activity" page logged in as "student1"
    And I press "Attempt quiz"
    And I press "Start attempt"

    # Student 2 also starts a quiz and creates an attempt.
    And I log in as "student2"
    And I am on the "Quiz 1" "quiz activity" page
    And I press "Attempt quiz"
    And I press "Start attempt"

    And I log in as "teacher1"
    When I am on the live monitor report for "Quiz 1"

    # Student 1 (Sam Student) has an active attempt -> "Show attempts" link exists.
    And I click on ".livequizmonitor-row-actions .dropdown-toggle" "css_element" in the "Sam Student" "table_row"
    Then "Show attempts" "link" should exist in the "Sam Student" "table_row"

    When I click on "Show attempts" "link" in the "Sam Student" "table_row"
    And I switch to a second window

    Then "Show report" "button" should exist
    And I should see "What to include in the report"
    And I should see "Sam Student"
    And I should see "Review attempt"
    And I should not see "Jane Student"

  @javascript @showattempts
  Scenario: Show attempts link opens quiz overview report for student with no quiz activity
    When I am on the live monitor report for "Quiz 1"

    And I click on ".livequizmonitor-row-actions .dropdown-toggle" "css_element" in the "Alex Other" "table_row"
    Then "Show attempts" "link" should exist in the "Alex Other" "table_row"

    When I click on "Show attempts" "link" in the "Alex Other" "table_row"
    And I switch to a second window

    Then "Show report" "button" should exist
    And I should see "What to include in the report"
    And I should see "Nothing to display"
