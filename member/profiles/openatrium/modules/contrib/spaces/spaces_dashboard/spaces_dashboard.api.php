<?php

/**
 * @file
 * Hooks provided by Spaces Dashboard.
 */

/**
 * Alter the default dashboard access settings for a given block.
 *
 * @param &$access
 *   Boolean. The current access value for the block, passed by reference. If
 *   TRUE, this block is accessible for use on the dashboard by the current
 *   user. If FALSE, the block is inaccessible.
 * @param $block
 *   The block object for which access is being checked. Has both ->module and
 *   ->delta attributes.
 * @return
 *   The return value is unused. Your hook implementation should alter the
 *   $access parameter directly.
 */
function hook_spaces_dashboard_access_alter(&$access, $block) {
  // Don't allow access to any blocks from the menu module on the dashboard.
  if ($block->module === 'menu') {
    $access = FALSE;
  }
}
