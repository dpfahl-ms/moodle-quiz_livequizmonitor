@quiz_livequizmonitor @mod @mod_quiz @quiz @report
Feature: Show quiz password in Live Quiz Monitor
  In order to quickly check the quiz password while monitoring an attempt
  As a teacher
  I need to be able to view the quiz password in a modal dialog

  Background:
    Given the following "users" exist:
      | username | firstname | lastname | email             |
      | teacher1 | Terry     | Teacher  | teacher1@test.com |
    And the following "courses" exist:
      | fullname | shortname | category |
      | Course 1 | C1        | 0        |
    And the following "course enrolments" exist:
      | user     | course | role           |
      | teacher1 | C1     | editingteacher |
    And I log in as "teacher1"

  @javascript
  Scenario: Show password button does not appear when quiz has no password
    Given the following "activities" exist:
      | activity | name         | course |
      | quiz     | Quiz No Pass | C1     |
    When I am on the live monitor report for "Quiz No Pass"
    Then "Show quiz password" "button" should not exist

  @javascript
  Scenario: Show password button displays password modal and closes correctly
    Given the following "activities" exist:
      | activity | name           | course | quizpassword  |
      | quiz     | Quiz With Pass | C1     | SecretPass123 |
    # Quiz has password -> Button appears
    When I am on the live monitor report for "Quiz With Pass"
    Then "Show quiz password" "button" should exist

    # Click button -> Popup appears with password and Close button
    When I click on "Show quiz password" "button"
    Then "Quiz password" "dialogue" should exist
    And I should see "SecretPass123" in the ".modal-dialog" "css_element"
    And "Close" "button" should exist in the ".modal-dialog" "css_element"

    # Click Close button -> Popup disappears
    When I click on "Close" "button" in the ".modal-dialog" "css_element"
    Then "Quiz password" "dialogue" should not exist
