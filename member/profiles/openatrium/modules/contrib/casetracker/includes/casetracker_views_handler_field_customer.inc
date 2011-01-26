<?php
// $Id: casetracker_views_handler_field_user_name.inc,v 1.1 2009/02/09 23:22:58 jmiccolis Exp $

/**
 * Field handler to show Selective state.
 *
 * @ingroup views_field_handlers
 */
class casetracker_views_handler_field_customer extends views_handler_field {

  function render($values) {
    return $values->casetracker_case_customer;
  }
}