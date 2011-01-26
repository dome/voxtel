<?php
/**
 * Field handler to show if user is admin or not.
 *
 * @ingroup views_field_handlers
 */
class og_views_handler_field_og_is_admin extends views_handler_field {
  function render($values) {
    $is_admin = $values->{$this->field_alias};
    $group = og_get_group_context();
    // Check that the queried admin nid matches the current group context 
    // -- outside a group context we can get unpredictable results for the nid 
    // in this entry.
    // don't use og_is_group_admin() here since we don't want mark on 'admin nodes' people.
    if ($group && ($group->nid === $is_admin)) {
      return t('admin'); 
    }
  }
}
