<?php
// This file is part of Moodle - http://moodle.org/
//
// Moodle is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// Moodle is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with Moodle.  If not, see <http://www.gnu.org/licenses/>.

/**
 * Shared helper for backdating quiz attempt activity in tests.
 *
 * @package   quiz_livequizmonitor
 * @copyright 2026 SSYSTEMS
 * @license   http://www.gnu.org/copyleft/gpl.html GNU GPL v3 or later
 */

namespace quiz_livequizmonitor\tests\traits;

/**
 * Provides a helper to simulate a stale/idle quiz attempt in tests.
 */
trait quiz_attempt_activity_trait {
    /**
     * Backdate the most recent question-attempt step so the attempt reads as idle.
     *
     * @param int $attemptid Attempt id.
     * @param int $minutesago Minutes to backdate the last activity.
     */
    private function backdate_last_activity(int $attemptid, int $minutesago): void {
        global $DB;

        $attempt = $DB->get_record('quiz_attempts', ['id' => $attemptid], '*', MUST_EXIST);
        $step = $DB->get_record_sql(
            "SELECT qas.*
            FROM {question_attempt_steps} qas
            JOIN {question_attempts} qa ON qa.id = qas.questionattemptid
            WHERE qa.questionusageid = :uniqueid
        ORDER BY qas.timecreated DESC",
            ['uniqueid' => $attempt->uniqueid],
            MUST_EXIST
        );
        $step->timecreated = time() - ($minutesago * 60);
        $DB->update_record('question_attempt_steps', $step);
    }
}
