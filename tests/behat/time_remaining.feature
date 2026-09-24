@quiz_livequizmonitor @mod @mod_quiz @quiz @report @javascript
Feature: Display accurate time remaining in Live Quiz Monitor
  In order to accurately monitor student progress
  As a teacher
  I need to see the correct remaining attempt time based on time limits and close dates

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
    And the following "question categories" exist:
      | contextlevel | reference | name           |
      | Course       | C1        | Test questions |
    And the following "questions" exist:
      | questioncategory | qtype       | name | questiontext |
      | Test questions   | shortanswer | SA1  | What is 2+2? |

  Scenario: No time limit, no close time outputs "00:00"
    Given the following "activities" exist:
      | activity | name          | course |
      | quiz     | Quiz No Limit | C1     |
    And quiz "Quiz No Limit" contains the following questions:
      | question | page |
      | SA1      | 1    |
    And I am on the "Quiz No Limit" "quiz activity" page logged in as "student1"
    And I press "Attempt quiz"
    And I log in as "teacher1"
    When I am on the live monitor report for "Quiz No Limit"
    Then I should see "00:00" in the "Sam Student" "table_row"

  Scenario: Time limit 45 mins, no close time outputs "44:5x"
    Given the following "activities" exist:
      | activity | name           | course | timelimit |
      | quiz     | Quiz 45m Limit | C1     | 2700      |
    And quiz "Quiz 45m Limit" contains the following questions:
      | question | page |
      | SA1      | 1    |
    And I am on the "Quiz 45m Limit" "quiz activity" page logged in as "student1"
    And I press "Attempt quiz"
    And I press "Start attempt"
    And I log in as "teacher1"
    When I am on the live monitor report for "Quiz 45m Limit"
    Then I should see "44:5" in the "Sam Student" "table_row"

  Scenario: No time limit, close time in 3 hours outputs 2:59:5x
    Given the following "activities" exist:
      | activity | name          | course | timeclose    |
      | quiz     | Quiz Close 3h | C1     | ##+3 hours## |
    And quiz "Quiz Close 3h" contains the following questions:
      | question | page |
      | SA1      | 1    |
    And I am on the "Quiz Close 3h" "quiz activity" page logged in as "student1"
    And I press "Attempt quiz"
    And I log in as "teacher1"
    When I am on the live monitor report for "Quiz Close 3h"
    Then I should see "2:59:5" in the "Sam Student" "table_row"
