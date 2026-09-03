@quiz_livequizmonitor @mod @mod_quiz @quiz @report
Feature: Sort students in Live Quiz Monitor
  In order to find students quickly
  As a teacher
  I need to sort the student list by different columns

  Background:
    Given the following "users" exist:
      | username  | firstname | lastname | email             |
      | teacher1  | Terry     | Teacher  | teacher1@test.com |
      | student-a | Name      | A        | email-2a@test.com  |
      | student-b | Name      | B        | email-3b@test.com  |
      | student-c | Name      | C        | email-1c@test.com  |
    And the following "courses" exist:
      | fullname | shortname | category |
      | Course 1 | C1        | 0        |
    And the following "course enrolments" exist:
      | user      | course | role           |
      | teacher1  | C1     | editingteacher |
      | student-a | C1     | student        |
      | student-b | C1     | student        |
      | student-c | C1     | student        |
    And the following "activities" exist:
      | activity | name   | course | timelimit |
      | quiz     | Quiz 1 | C1     | 600       |
    And the following "question categories" exist:
      | contextlevel | reference | name           |
      | Course       | C1        | Test questions |
    And the following "questions" exist:
      | questioncategory | qtype       | name | questiontext |
      | Test questions   | shortanswer | SA1  | What is 2+2? |
      | Test questions   | shortanswer | SA2  | What is 3+3? |
    And quiz "Quiz 1" contains the following questions:
      | question | page |
      | SA1      | 1    |
      | SA2      | 1    |
    And I log in as "teacher1"

  @javascript @sortcolumns
  Scenario: Sort students by column. Sort order is in progress (B), not started (C), completed (A), then alphabetical.
    Given student "student-a" has completed quiz "Quiz 1"
    And student "student-b" has answered question 1 in quiz "Quiz 1"

    When I am on the live monitor report for "Quiz 1"
    Then the following students should appear in order:
      | Name B |
      | Name C |
      | Name A |

    When I click on the "email" column header
    Then the following students should appear in order:
      | Name C |
      | Name A |
      | Name B |

    When I click on the "progress" column header
    Then the following students should appear in order:
      | Name C |
      | Name B |
      | Name A |

    When I click on the "progress" column header
    Then the following students should appear in order:
      | Name A |
      | Name B |
      | Name C |
