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
     * Load has-override flags for a set of users, keyed by userid.
     *
     * A user override always takes precedence over a group override for the
     * same student, regardless of which override record is processed first:
     * the user-override branch unconditionally overwrites the map entry, while
     * the group-override branch only writes when no override has been recorded
     * for that student yet.
     *
     * @param int $courseid Course id (to enumerate groups).
     * @param int $quizid Quiz instance id.
     * @param int[] $userids User ids to check.
     * @return array<int, bool|stdClass> Map userid => false, or an object of override flags.
     */
    public static function get_override_map(
        int $courseid,
        int $quizid,
        array $userids
    ): array {
        global $DB;

        $map = array_fill_keys($userids, false);
        if ($map === []) {
            return $map;
        }

        // Cache the array of groups with members.
        $groups = groups_get_all_groups($courseid, 0, 0, 'g.*', true);

        $overrides = $DB->get_records('quiz_overrides', ['quiz' => $quizid]);
        foreach ($overrides as $override) {
            $userid = (int) $override->userid;
            $groupid = (int) $override->groupid;

            // Determine if this is a time override.
            $hastimeoverride = (bool) array_filter(
                self::TIME_COLUMNS,
                static fn(string $column): bool => !empty($override->$column)
            );

            // User override.
            if ($userid && array_key_exists($userid, $map)) {
                $map[$userid] = (object) [
                    'hasuseroverride' => true,
                    'hasgroupoverride' => false,
                    'hastimeoverride' => $hastimeoverride,
                ];
                continue;
            }

            // Group override.
            if ($groupid && array_key_exists($groupid, $groups)) {
                foreach ($groups[$groupid]->members as $uid) {
                    if (array_key_exists($uid, $map) && $map[$uid] === false) {
                        $map[$uid] = (object) [
                            'hasuseroverride' => false,
                            'hasgroupoverride' => true,
                            'hastimeoverride' => $hastimeoverride,
                        ];
                    }
                }
                continue;
            }
        }

        return $map;
    }
}
