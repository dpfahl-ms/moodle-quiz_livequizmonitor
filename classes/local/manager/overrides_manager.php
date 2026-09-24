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
 * Reads core {quiz_overrides} rows for the live quiz monitor.
 *
 * Shared between the user-override filter (CTP-6723) and the
 * group-override filter (CTP-6724), since both read the same table -
 * they differ only in which column (userid vs groupid) is set.
 *
 * @package   quiz_livequizmonitor
 * @copyright 2026 SSYSTEMS
 * @license   http://www.gnu.org/copyleft/gpl.html GNU GPL v3 or later
 */

namespace quiz_livequizmonitor\local\manager;

use context_module;

/**
 * Manager for {quiz_overrides} lookups.
 */
class overrides_manager {
    /**
     * Columns in {quiz_overrides} that represent an id in another table.
     *
     * @var string[] columns that hold ids
     */
    protected const ID_COLUMNS = ['userid', 'groupid'];

    /**
     * Columns on {quiz_overrides} that represent an actual override value.
     *
     * A row only counts as "having an override" if at least one of these
     * is non-null. (In practice core's override form never saves a row
     * with all of these empty, but we check explicitly rather than relying
     * on that as an implementation detail of core.)
     *
     * @var string[]
     */
    protected const VALUE_COLUMNS = ['timeopen', 'timeclose', 'timelimit', 'attempts', 'password'];

    /**
     * Columns on {quiz_overrides} that relate to attempt timing.
     *
     * @var string[]
     */
    protected const TIME_COLUMNS = ['timeopen', 'timeclose', 'timelimit'];

    /**
     * Whether the viewer may see override information for this quiz.
     *
     * @param context_module $context Module context.
     * @return bool
     */
    public static function user_can_view_overrides(context_module $context): bool {
        return has_any_capability(['mod/quiz:viewoverrides', 'mod/quiz:manageoverrides'], $context);
    }

    /**
     * Load has-override flags for a set of users, keyed by a given column.
     *
     * @param int $quizid Quiz instance id.
     * @param string $idcolumn One of the ID_COLUMNS.
     * @param int[] $ids User ids or group ids to check.
     * @param string[] $valuecolumns Which VALUE_COLUMNS count as "a value". Defaults to all of them.
     * @return array<int, bool|stdClass> Map id => object containing boolean override flags.
     */
    protected static function get_override_map(
        int $quizid,
        string $idcolumn,
        array $ids,
        array $valuecolumns = self::VALUE_COLUMNS
    ): array {
        global $DB;

        $map = array_fill_keys($ids, false);
        if ($ids === [] || !in_array($idcolumn, self::ID_COLUMNS, true) || $valuecolumns === []) {
            return $map;
        }

        [$selectids, $params] = $DB->get_in_or_equal($ids, SQL_PARAMS_NAMED, 'id');
        $params['quizid'] = $quizid;

        // Join conditions on value columns, e.g. "timeopen IS NOT NULL OR timeclose IS NOT NULL ...".
        $selectnotnull = implode(' OR ', array_map(
            static fn(string $col): string => "$col IS NOT NULL",
            $valuecolumns
        ));

        $records = $DB->get_records_select(
            'quiz_overrides',
            "quiz = :quizid AND $idcolumn $selectids AND ($selectnotnull)",
            $params,
            '', // No ordering fields.
            "id, $idcolumn AS overrideid, " . implode(', ', $valuecolumns)
        );

        // Adjust override map for each override record.
        foreach ($records as $record) {
            $flags = (object)[
                'hasoverride' => true,
                'hastimeoverride' => false,
            ];
            foreach (self::TIME_COLUMNS as $column) {
                if (!empty($record->$column)) {
                    $flags->hastimeoverride = true;
                    break;
                }
            }
            $map[(int) $record->overrideid] = $flags;
        }

        return $map;
    }

    /**
     * Load has-user-override flags for a set of students in one quiz.
     *
     * @param int $quizid Quiz instance id.
     * @param int[] $userids Student user ids.
     * @return array<int, bool|stdClass> Map userid => object containing boolean override flags.
     */
    public static function get_user_override_map(int $quizid, array $userids): array {
        return self::get_override_map($quizid, 'userid', $userids);
    }

    /**
     * Load has-group-override flags for a set of groups in one quiz.
     *
     * @param int $quizid Quiz instance id.
     * @param int[] $groupids Group ids.
     * @return array<int, bool|stdClass> Map groupid => object containing boolean override flags.
     */
    public static function get_group_override_map(int $quizid, array $groupids): array {
        return self::get_override_map($quizid, 'groupid', $groupids);
    }
}
