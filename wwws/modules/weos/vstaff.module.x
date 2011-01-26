<?php

function vstaff_perm() {
    return array('access staff');
}

function vstaff_menu() {
    global $user;


        $items['staff'] = array(
      'description' => 'View user.', 'title' => 'Staff',
      'page callback' => 'vstaff_overview',
      'menu_name' => 'features',
      'weight' => -5,
      'access arguments' => array('access staff'),
        'type' => MENU_NORMAL_ITEM,
        );

        $items['staff/list'] = array(
      'description' => 'View user.', 'title' => 'Member',
      'page callback' => 'vstaff_overview',
      'menu_name' => 'features',
      'weight' => -1,
      'access arguments' => array('access staff'),
      'type' => MENU_DEFAULT_LOCAL_TASK
        );


        $items['staff/cdr'] = array(
      'description' => 'View CDR.', 'title' => 'CDR',
      'page callback' => 'vstaff_cdr',
      'menu_name' => 'features',
      'weight' => 5,
      'access arguments' => array('access staff'),
      'type' => MENU_CALLBACK,
        );


        $items['staff/detail'] = array(
      'description' => 'View user detail.', 'title' => 'Detail',
      'page callback' => 'vstaff_detail',
      'menu_name' => 'features',
      'weight' => 1,
      'access arguments' => array('access staff'),
      'type' => MENU_CALLBACK
        );

        $items['staff/add'] = array(
      'title' => 'New Member',
      'page callback' => 'drupal_get_form',
      'page arguments' => array('vstaff_form'),
      'access arguments' => array('access staff'),
      'menu_name' => 'features',
      'weight' => 0,
      'type' => MENU_LOCAL_TASK
        );
        $items['staff/edit'] = array(
      'description' => 'View user.', 'title' => 'Edit',
      'page callback' => 'drupal_get_form',
      'page arguments' => array('vstaff_edit_form'),
      'menu_name' => 'features',
      'weight' => 10,
      'access arguments' => array('access staff'),
      'type' => MENU_CALLBACK
        );

        $items['staff/topup'] = array(
      'description' => 'View user.', 'title' => 'Topup',
      'page callback' => 'drupal_get_form',
      'menu_name' => 'features',
      'page arguments' => array('vstaff_topup_form'),
      'weight' => 10,
      'access arguments' => array('access staff'),
      'type' => MENU_LOCAL_TASK
        );

        $items['staff/transfer'] = array(
      'description' => 'View user.', 'title' => 'Transfer',
      'page callback' => 'drupal_get_form',
      'menu_name' => 'features',
      'page arguments' => array('vstaff_transfer_form'),
      'weight' => 10,
      'access arguments' => array('access staff'),
      'type' => MENU_LOCAL_TASK
        );

	$items['staff/card_check'] = array(
            'title' => 'Check Card',
            'page callback' => 'vcard_check',
    	    'menu_name' => 'features',
    	    'access arguments' => array('access staff'),
    	    'weight' => 10,
            'type' => MENU_LOCAL_TASK);

        $items['staff/ckuser'] = array(
    	    'description' => 'View user.', 'title' => 'Check User',
    	    'page callback' => 'vstaff_check_user',
    	    'menu_name' => 'features',
    	    'weight' => 10,
    	    'access arguments' => array('access staff'),
    	    'type' => MENU_LOCAL_TASK
        );

        $items['staff/rate'] = array(
    	    'description' => 'Rate.', 'title' => 'Check Rate',
            'page callback' => 'drupal_get_form',
             'page arguments' => array('vstaff_rate_form'),
    	    'menu_name' => 'features',
    	    'weight' => 10,
    	    'access arguments' => array('access staff'),
    	    'type' => MENU_LOCAL_TASK
        );
    $items['staff/card'] = array(
            'description' => 'Card Report', 'title' => 'Report Card',
            'page callback' => 'vreport_card',
    	    'menu_name' => 'features',
            'weight' => 7,
    	    'access arguments' => array('access staff'),
            'type' => MENU_LOCAL_TASK
    );

    return $items;
}

function vstaff_rate_form() {
	$form['rate'] = array(
	'#type' => 'textfield',
	'#title' => t("Search:"),
//        '#default_value' => isset($rate) ? $rate : '',
//        '#required' => TRUE,
        '#size' => 60,
        '#maxlength' => 64, 
	'#description' => t("Input Country Or Code."),
	'#autocomplete_path' => 'rate/autocomplete/'
	);
	return $form;
}

function vstaff_check_user() {
    $output = drupal_get_form('vstaff_form_overview');
    $search_str =$_SESSION['vstaff_search_filter'];
    $username = $search_str;
    $header = array(
        array('data' => t('Username'), 'field' => 'username'),
        array('data' => t('Password'), 'field' => 'secret'),
        array('data' => t('Lang'), 'field' => 'language'),
        array('data' => t('Balance'), 'field' => 'balance'),
        array('data' => t('Rate'), 'field' => 'description'),
        array('data' => t('Currency'), 'field' => 'currencysym'),
        array('data' => t('Expire Date'), 'field' => 'exp_date'),
    );

    $tablesort = tablesort_sql($header);
    $search_str = $_SESSION['vstaff_search_filter'];
    $sql = "select * from vuser where 0=0 ";
    if ($search_str != '') {
        $sql .= " AND username LIKE '$search_str%' ";
    }else
    $sql .= " ";

    //echo $sql;
    $result = pager_query($sql . $tablesort, 1);

    while ($rate = db_fetch_object($result)) {
        $rows[] =
        array(
            // Cells
            $rate->username,
            $rate->secret,
            $rate->lang_prefer,
            $rate->balance,
            $rate->description,
            $rate->currencysym,
            $rate->exp_date,
        );
    }

    if (!$rows) {
        $rows[] = array(array('data' => t('Data Not Found.'), 'colspan' => 20));
    }

    $output .= theme('table', $header, $rows);
    $output .= theme('pager', NULL, 1, 0);

    $output .= '<br><br><b>Payment:</b><br>';

    $header2 = array(
        array('data' => t('Username'), 'field' => 'username'),
        array('data' => t('Date'), 'field' => 'date','sort'=>'desc'),
        array('data' => t('Amount'), 'field' => 'paid'),
        array('data' => t('Ref'), 'field' => 'ref'),
    );

    $sql = "   SELECT * from vpayment where username='$username'   ";
    $sql_count = "select count(username) from vpayment where username='$username'";

    $tablesort = tablesort_sql($header);
    $result = pager_query($sql . $tablesort, 10,0,$sql_count);
    while ($rate = db_fetch_object($result)) {
        $rows2[] =
        array(
            $rate->username,
            $rate->date,
            $rate->paid,
            $rate->ref,
        );
    }

    if (!$rows) {
        $rows[] = array(array('data' => t('Data Not Found.'), 'colspan' => 20));
    }

    $output .= theme('table', $header2, $rows2);
    $output .= theme('pager', NULL, 10, 0);

    $output .= '<br><br><b>Call history:</b><br>';

    $header1 = array(
        array('data' => t('Date'), 'field' => 'acctstarttime','sort' => 'desc'),
        array('data' => t('Username'), 'field' => 'username'),
        array('data' => t('Number'), 'field' => 'calledstationid'),
        array('data' => t('Destination'), 'field' => 'tariffdesc'),
        array('data' => t('Rate'), 'field' => 'price'),
        array('data' => t('Duration'), 'field' => 'duration'),
        array('data' => t('Total'), 'field' => 'cost'),
        array('data' => t('Service <br>Charge'), 'field' => 'Service charge'),
    );
    $sql = " SELECT username,date_trunc('min',acctstarttime) as cdate,calledstationid,tariffdesc,price,duration,
  cost,o_service_charge from voipcall Where username = '$username'";

    $tablesort = tablesort_sql($header1);
//    $sql_count = "Select count(username) from voipcall Where username = '$username'";
    $sql_count = "Select count(username) from voipcall Where username = '$username' Limit 10 Offset 0";
    $result = pager_query($sql . $tablesort, 40,0);

    while ($rate = db_fetch_object($result)) {
        $rows1[] =
        array(
            $rate->cdate,
            $rate->username,
            $rate->calledstationid,
            $rate->tariffdesc,
            $rate->price,
            $rate->duration,
            $rate->cost,
            $rate->o_service_charge,
        );
    }

    if (!$rows1) {
        $rows1[] = array(array('data' => t('Data Not Found.'), 'colspan' => 20));
    }

    $output .= theme('table', $header1, $rows1);
    $output .= theme('pager', NULL, 40, 0);

    return $output;
}

function vstaff_service_charge_form() {
    global $user;

    $result = db_query("SELECT d_service_charge from voipusers where username='%s';", $user->name);
    $data = db_fetch_object($result);

    $form['service_charge'] = array(
    '#type' => 'textfield',
    '#title' => t("Service Charge (%)"),
    '#default_value' => $data->d_service_charge,
    '#maxlength' => 6,
    '#required' => true,
    );

    $form['submit'] = array(
    '#type' => 'submit',
    '#value' => 'Submit',
    );


    return $form;
}

function vstaff_service_charge_form_submit($form, &$form_state) {
    global $user;
    if ($form['service_charge'] > 0) {
    $result = db_query("UPDATE voipusers set d_service_charge=%d where username='%s';", $form['service_charge'],$user->name);
    $result = db_query("UPDATE voipusers set service_charge=%d where owner='%s';", $form['service_charge'],$user->name);
    $result = db_query("UPDATE dr_users set service_charge = %d where name in (select username from voipusers where owner='%s')",$form['service_charge'],$user->name);
    }else {
            drupal_set_message("Service Charge > 0 ",'error');
        };
    $form_state['redirect'] = drupal_goto('staff');
};


function vstaff_form_overview() {

    if (empty($_SESSION['vstaff_search_filter'])) {
        $_SESSION['vstaff_search_filter'] = '';
    }

    $form['search'] = array(
    '#type' => 'textfield',
    '#title' => 'Search',
    '#size' => 10,
    '#default_value' => $_SESSION['vstaff_search_filter']
    );

    $form['submit'] = array('#type' => 'submit', '#value' =>t('Filter'));
//    $form['#redirect'] = FALSE;

    return $form;
}
/**
 * Menu callback; displays a listing of log messages.
 */
function vstaff_overview() {
    global $user;

    $output = drupal_get_form('vstaff_form_overview');
    //username 	secret 	balance 	currencysym 	grpid 	accountid 	description 	create_date
    $header = array(
        array('data' => t('Username'), 'field' => 'name'),
        array('data' => t('Password'), 'field' => 'plainpass'),
        array('data' => t('Lang'), 'field' => 'language'),
        array('data' => t('Balance'), 'field' => 'balance'),
        array('data' => t('Rate'), 'field' => 'description'),
        array('data' => t('Currency'), 'field' => 'currencysym'),
        array('data' => t('Expire Date'), 'field' => 'exp_date'),
        // exp_date
        //    array('data' => t('Operations'))
    );

    $tablesort = tablesort_sql($header);
    $search_str = $_SESSION['vstaff_search_filter'];
    $sql = "SELECT *
         FROM dr_users As d
                    LEFT JOIN voipaccount ON d.vuid = voipaccount.id
                                  LEFT JOIN voiptariffgrp ON grpid = voiptariffgrp.id
                                                  WHERE 0 = 0 ";
    if ($search_str != '') {
        $sql .= " AND name LIKE '$search_str%' ";
    }else
    $sql .= " ";

    //echo $sql;
    $result = pager_query($sql . $tablesort, 20);

    while ($rate = db_fetch_object($result)) {
        $rows[] =
        array(
            // Cells
            $rate->name,
            $rate->plainpass,
            $rate->language,
            $rate->balance,
            $rate->description,
            $rate->currencysym,
            $rate->exp_date,
            array('data' => l('CDR','staff/cdr/'.$rate->name)),
            array('data' => l('Payment','staff/detail/'.$rate->name)),
            array('data' => l('Edit','staff/edit/'.$rate->name)),
            array('data' => l('Top Up','staff/topup/'.$rate->name)),
        );
    }

    if (!$rows) {
        $rows[] = array(array('data' => t('Data Not Found.'), 'colspan' => 20));
    }

    $output .= theme('table', $header, $rows);
    $output .= theme('pager', NULL, 20, 0);

    return $output;
}


function vstaff_form_overview_submit($form, &$form_state) {
    $_SESSION['vstaff_search_filter'] = $form_state['values']['search'];
}


function _vstaff_get_vstaff_group() {
    $types = array();

    $result = db_query('SELECT DISTINCT(description),id FROM voiptariffgrp ORDER BY description');
    while ($object = db_fetch_object($result)) {
        $types[] = array($object->id => $object->description);
    }

    return $types;
}

function vstaff_form($form_state,$id = NULL) {
    global $user,$rminimum;

    $form['username'] = array(
    '#type' => 'textfield',
    '#title' => t("Username"),
    '#default_value' => $card_lot->username,
    '#maxlength' => 64,
    '#required' => true,
    );
/*
    $form['credit'] = array(
    '#type' => 'textfield',
    '#title' => t("Credit"),
    '#default_value' => 0,
    '#maxlength' => 20,
    '#required' => true,
    );
*/
    $form['submit'] = array(
    '#type' => 'submit',
    '#value' => 'Submit',
    );


    return $form;
}

/**
 * Add/Edit bookmark form submit
 */
function vstaff_form_submit($form, &$form_state) {
    global $user,$rminimum;

if ($form_state['values']['credit'] < 0) {
            drupal_set_message("Minimum Credit ".$rminimum,'error');
            return drupal_goto('staff/member');
    };

    if ($user->balance < $form_state['values']['credit']) {
            drupal_set_message("Credit not enough.Please Buy Credit Before Add member.",'error');
            return drupal_goto('staff/member');
    };

    $result = db_query("SELECT create_account_mobile('%s');", $form_state['values']['username']);
    $card_lot = db_fetch_object($result);
    if ($card_lot) {
        if ($card_lot->create_account_mobile > 0 ) {
            $_SESSION['vstaff_search_filter'] = $form_state['values']['username'];
            drupal_set_message("Successfull Password is   '$card_lot->create_account_mobile' ");
//    if($user->balance > $form_state['values']['credit']){
//        $result = db_query("SELECT i_pay('%s','%s',%d,1) As cpay ;", $user->name,$form_state['values']['username'],$form_state['values']['credit']);
//        $card_lot = db_fetch_object($result);
//    };        
    }else {
            drupal_set_message("Create User ".$form['username']." Fail.",'error');
        };
    };
    

    return drupal_goto('staff');
}

function vstaff_topup_form($form_state,$id = NULL) {
    global $user;
    if ($id) {
        $form['username'] = array(
        '#type' => 'textfield',
        '#title' => t("Username"),
        '#default_value' => $id,
        '#maxlength' => 255,
        '#required' => true,
        '#attributes' => array('readonly' => 'readonly'),
        );
    }else {
        $form['username'] = array(
        '#type' => 'textfield',
        '#title' => t("Username"),
        '#default_value' => $card_lot->username,
        '#maxlength' => 255,
        '#required' => true,
        );
    };


    $form['pin'] = array(
    '#type' => 'textfield',
    '#title' => t("TopUP From PIN"),
    '#default_value' => '',
    '#required' => false,
    );


    $form['submit'] = array(
    '#type' => 'submit',
    '#value' => 'TopUp',
    );

    return $form;
}

/**
 * Add/Edit bookmark form submit
 */
function vstaff_topup_form_submit($form, &$form_state) {
    global $user;
    if ((strlen($form_state['values']['username']) > 0) AND (strlen($form_state['values']['pin']) > 0) ){
        $result = db_query("SELECT card_pay('%s','%s',1) As cpay ;", $form_state['values']['pin'],$form_state['values']['username']);
        $card_lot = db_fetch_object($result);
        if (!$card_lot) {
            drupal_set_message("TopUp From ".$form_state['values']['pin']." Fail.",'error');
            return drupal_goto('staff');
        }else{
            if ($card_lot->cpay > 0) {
                drupal_set_message("TopUp From ".$form_state['values']['pin']." Success.");
                return drupal_goto('staff/detail/'.$form_state['values']['username']);
            }else{
                drupal_set_message("TopUp From ".$form_state['values']['pin']." Fail.",'error');
                return drupal_goto('staff');
            };
        };
    };
    $result = db_query("SELECT balance,currencysym from voipaccount where id=%d ",$user->vuid);
    $udetail = db_fetch_object($result);
    if (!$udetail) {
        drupal_set_message("Balance Not found. Please contact Admin ",'error');
        return drupal_goto('staff');
    }

    if ((strlen($form_state['values']['username']) > 0) AND (strlen($form_state['values']['tpay']) > 0) )
    if($udetail->balance > $form_state['values']['tpay']){
        $result = db_query("SELECT i_pay('%s','%s',%d,1) As cpay ;", $user->name,$form_state['values']['username'],$form_state['values']['tpay']);
        $card_lot = db_fetch_object($result);
        if (!$card_lot) {
            drupal_set_message("Transfer ".$form_state['values']['tpay']." Fail.",'error');
            return drupal_goto('staff');
        }else{
            if ($card_lot->cpay > 0) {
                drupal_set_message("Transfer ".$form_state['values']['tpay']." Success.");
                return drupal_goto('staff/detail/'.$form_state['values']['username']);
            }else{
                drupal_set_message("Transfer ".$form_state['values']['tpay']." Fail.",'error');
                return drupal_goto('staff');
            };
        };
    };

    drupal_set_message(" Fail.",'error');
    return drupal_goto('staff/detail/'.$form_state['values']['username']);
}

function vstaff_transfer_form($form_state,$id = NULL) {
    global $user;
    if ($id) {
        $form['fusername'] = array(
        '#type' => 'textfield',
        '#title' => t("From Username"),
        '#default_value' => $id,
        '#maxlength' => 255,
        '#required' => true,
        '#attributes' => array('readonly' => 'readonly'),
        );
    }else {
        $form['fusername'] = array(
        '#type' => 'textfield',
        '#title' => t("From Username"),
        '#default_value' => $card_lot->username,
        '#maxlength' => 255,
        '#required' => true,
        );
    };


        $form['tusername'] = array(
        '#type' => 'textfield',
        '#title' => t("To Username"),
        '#maxlength' => 255,
        '#required' => true,
        );

        $form['amt'] = array(
        '#type' => 'textfield',
        '#title' => t("Amount"),
        '#maxlength' => 255,
        '#required' => true,
        );


    $form['submit'] = array(
    '#type' => 'submit',
    '#value' => 'TopUp',
    );

    return $form;
}

/**
 * Add/Edit bookmark form submit
 */
function vstaff_transfer_form_submit($form, &$form_state) {
    global $user;
    $result = db_query("SELECT balance,currencysym from vuser where username='%s' ",$form_state['values']['fusername']);
    $udetail = db_fetch_object($result);
    if (!$udetail) {
        drupal_set_message("User :".$form_state['values']['fusername']."not found",'error');
        return drupal_goto('staff');
    }else{
         if ($udetail->balance < $form_state['values']['amt']) {
    	    drupal_set_message("Low Balance : ".$udetail->balance,'error');
    	    return drupal_goto('staff');
         }else{
    	    $result = db_query("SELECT i_pay('%s','%s',%d,1) As cpay ;", 
    	      $form_state['values']['fusername'],$form_state['values']['tusername'],$form_state['values']['amt']);
    	    $card_lot = db_fetch_object($result);
    	    if (!$card_lot) {
        	    drupal_set_message("Transfer ".$form_state['values']['amt']." Fail.",'error');
        	    return drupal_goto('staff');
    	    }else{
            if ($card_lot->cpay > 0) {
                drupal_set_message("Transfer ".$form_state['values']['amt']." Success.");
                return drupal_goto('staff/detail/'.$form_state['values']['fusername']);
            }else{
                drupal_set_message("Transfer ".$form_state['values']['tpay']." Fail.",'error');
                return drupal_goto('staff');
            };
        };
         
         };    
    }

                return drupal_goto('staff');
}

function vstaff_edit_form($form_state,$id = NULL) {
    global $user;
    if (!$id) {
        return drupal_goto('staff');
    }

    $sqlstr = "SELECT * FROM vuser  WHERE name = '$id'";
    $result = db_query($sqlstr);
    $card_lot = db_fetch_object($result);
    if (!$card_lot) {
        drupal_set_message("User ".$id." Not Found.",'error');
        //return $output;
        return drupal_goto('staff');
    };
    //$sqlstr = "SELECT language vuser dr_users  WHERE name = '$id';";
    //$result = db_query($sqlstr);
    //$l = db_fetch_object($result);

    $form['accountid'] = array(
    '#type' => 'textfield',
    '#title' => t("Account ID"),
    '#default_value' => $card_lot->id,
    '#required' => true,
    '#attributes' => array('readonly' => 'readonly'),
    );

    $form['username'] = array(
    '#type' => 'textfield',
    '#title' => t("Username"),
    '#default_value' => $card_lot->name,
    '#maxlength' => 255,
    '#required' => true,
    '#attributes' => array('readonly' => 'readonly'),
    );

    $form['secret'] = array(
    '#type' => 'textfield',
    '#title' => t("Password"),
    '#default_value' => $card_lot->secret,
    '#required' => true,
    );

    $form['lang'] = array(
    '#type' => 'textfield',
    '#title' => t("Language"),
    '#default_value' => $card_lot->language,
    '#required' => true,
    );
    $form['balance'] = array(
    '#type' => 'textfield',
    '#title' => t("Balance"),
    '#default_value' => $card_lot->balance,
    '#required' => true,
    '#attributes' => array('readonly' => 'readonly'),
    );

    $types = array();
    $result = db_query('SELECT DISTINCT(description),id FROM voiptariffgrp where id = %d',$card_lot->grpid);
    while ($object = db_fetch_object($result)) {
        $names[$object->id] = $object->description;
    }
    $form['grpid'] = array(
    '#type' => 'select',
    '#title' => t("rate"),
    '#options' => $names,
    '#default_value' => $card_lot->grpid,
    '#required' => true,
    );

    $form['submit'] = array(
    '#type' => 'submit',
    '#value' => 'Submit',
    );


    return $form;
}

/**
 * Add/Edit bookmark form submit
 */
function vstaff_edit_form_submit($form, &$form_state) {
    if ($form['accountid'] > 0)  {
        $result = db_query("update dr_users set plainpass = '%s',pass=MD5('%s'),language = '%s' where name = '%s';",
           $form_state['values']['secret'],$form_state['values']['secret'],$form_state['values']['lang'],$form_state['values']['username']);
        $card_lot = db_fetch_object($result);
    };
    return drupal_goto('staff');
}

function vstaff_topup_myaccount_form() {

    if (empty($_SESSION['vstaff_search_filter'])) {
        $_SESSION['vstaff_search_filter'] = '';
    }

    $form['tpin'] = array(
    '#type' => 'textfield',
    '#title' => 'Top UP From PIN',
    '#size' => 50,
    );

    $form['submit'] = array('#type' => 'submit', '#value' =>t('Top UP'));
//    $form['#redirect'] = FALSE;
    return $form;
}

function vstaff_topup_myaccount_form_submit($form, &$form_state) {
    global $user;
    if (strlen($form['tpin']) > 0) {
        $result = db_query("SELECT card_pay('%s','%s',1) As cpay ;", $form['tpin'],$user->name);
        $card_lot = db_fetch_object($result);
        if (!$card_lot) {
            drupal_set_message("TopUp From ".$form['tpin']." Fail.",'error');
            return drupal_goto('staff');
        }else{
            if ($card_lot->cpay > 0) {
                drupal_set_message("TopUp From ".$form['tpin']." Success.");
                return drupal_goto('staff/detail/'.$form['username']);
            }else{
                drupal_set_message("TopUp From ".$form['tpin']." Fail.",'error');
                return drupal_goto('staff');
            };
        };
    };

    drupal_set_message(" Fail.",'error');
    return drupal_goto('staff/detail/'.$form['username']);
}


function vstaff_rate_form_overview() {

    if (empty($_SESSION['vstaff_overview_filter'])) {
        $_SESSION['vstaff_overview_filter'] = '0';
    }
    if (empty($_SESSION['vstaff_search_filter'])) {
        $_SESSION['vstaff_search_filter'] = '';
    }

    $form['search'] = array(
    '#type' => 'textfield',
    '#title' => 'Search',
    '#size' => 20,
    '#default_value' => $_SESSION['vstaff_search_filter']
    );

    $form['submit'] = array('#type' => 'submit', '#value' =>t('Filter'));
//    $form['#redirect'] = FALSE;

    return $form;
}

/**
 * Menu callback; displays a listing of log messages.
 */
function vstaff_rate_overview() {
    global $user;
    $icons = array(WATCHDOG_NOTICE  => '',
        WATCHDOG_WARNING => theme('image', 'misc/watchdog-warning.png', t('warning'), t('warning')),
        WATCHDOG_ERROR   => theme('image', 'misc/watchdog-error.png', t('error'), t('error')));
    $classes = array(WATCHDOG_NOTICE => 'watchdog-notice', WATCHDOG_WARNING => 'watchdog-warning', WATCHDOG_ERROR => 'watchdog-error');

    $result = db_query('SELECT  DISTINCT(description),grpid As id FROM user_rate_group Where accountid=%d',$user->vuid);
    $object = db_fetch_object($result);
    //echo $object->id;
    $type=$object->id;

    $output = drupal_get_form('vstaff_rate_form_overview');

    $header = array(
        array('data' => t('Destination'), 'field' => 'description'),
        array('data' => t('Prefix'), 'field' => 'prefix'),
        array('data' => t('Price'), 'field' => 'price'),
        array('data' => t('Currency'), 'field' => 'currencysym'),
        array('data' => t('Group'), 'field' => 'group_dsc'),
    );

    $tablesort = tablesort_sql($header);
    $type = $_SESSION['vstaff_overview_filter'];
    $search_str = $_SESSION['vstaff_search_filter'];
/*
SELECT voiptariff.id, voiptariffdst.prefix, voiptariffdst.description, voiptariff.price, voiptariff.currencysym, voiptariff.grpid, voiptariffgrp.description AS group_dsc, voiptariffgrp.uid, voiptariff.initialincrement, voiptariff.regularincrement, voiptariff.graceperiod
   FROM voiptariff
      LEFT JOIN voiptariffdst ON voiptariff.dstid = voiptariffdst.id
         LEFT JOIN voiptariffgrp ON voiptariff.grpid = voiptariffgrp.id;
*/
    $sql = "
   SELECT voiptariff.id, voiptariff.prefix, voiptariff.description, voiptariff.price, voiptariff.currencysym, voiptariff.grpid, voiptariffgrp.description AS group_dsc, voiptariffgrp.uid, voiptariff.initialincrement, voiptariff.regularincrement, voiptariff.graceperiod
   FROM voiptariff
         LEFT JOIN voiptariffgrp ON voiptariff.grpid = voiptariffgrp.id
  ";
    $sql_count = "select count(id) from voiptariff";
    //echo "type: ".$type;
    //if ($type != '0') {
    if ($object->id != '0') {
        $sql .= " WHERE grpid = $object->id ";
        $sql_count .= " WHERE grpid = $object->id ";
    }else{
        $sql .= " WHERE 0=0 ";
        $sql_count .= " WHERE 0=0 ";

    }
    if ($search_str != '') {
        $sql .= " AND upper(voiptariff.description) LIKE upper('$search_str%') Or prefix LIKE '$search_str%' AND grpid = $object->id ";
        $sql_count .= " AND upper(voiptariff.description) LIKE upper('$search_str%') Or prefix LIKE '$search_str%' AND grpid = $object->id";
    };
    //echo $sql;
    $result = pager_query($sql . $tablesort, 50,0,$sql_count);

    while ($rate = db_fetch_object($result)) {
        $rows[] =
        array(
            // Cells
            $rate->description,
            $rate->prefix,
            $rate->price,
            $rate->currencysym,
            $rate->group_dsc,
        );
    }

    if (!$rows) {
        $rows[] = array(array('data' => t('Data Not Found.'), 'colspan' => 20));
    }

    $output .= theme('table', $header, $rows);
    $output .= theme('pager', NULL, 50, 0);

    return $output;
}

function vstaff_rate_form_overview_submit($form, &$form_state) {
    $_SESSION['vstaff_overview_filter'] = $form_state['values']['filter'];
    $_SESSION['vstaff_search_filter'] = $form_state['values']['search'];
}

function vstaff_detail($username = NULL) {
    global $user;
    $icons = array(WATCHDOG_NOTICE  => '',
        WATCHDOG_WARNING => theme('image', 'misc/watchdog-warning.png', t('warning'), t('warning')),
        WATCHDOG_ERROR   => theme('image', 'misc/watchdog-error.png', t('error'), t('error')));
    $classes = array(WATCHDOG_NOTICE => 'watchdog-notice', WATCHDOG_WARNING => 'watchdog-warning', WATCHDOG_ERROR => 'watchdog-error');
    $udetail = array();
    if (strlen($username)==0)
    $username = $user->name;
    $result = db_query("SELECT balance,currencysym from vuser where username='%s'",$username);
    $udetail = db_fetch_object($result);
    $output = 'Account :'.$username.'<br>'.'Balance :'.$udetail->balance.' '.$udetail->currencysym;
    $output .= '<br><br><b>Payment:</b><br>';

    $header = array(
        array('data' => t('Username'), 'field' => 'username'),
        array('data' => t('Date'), 'field' => 'date','sort'=>'desc'),
        array('data' => t('Amount'), 'field' => 'paid'),
        array('data' => t('Ref'), 'field' => 'ref'),
    );

    $sql = "   SELECT * from vpayment where username='$username'   ";
    $sql_count = "select count(username) from vpayment where username='$username'";

    $tablesort = tablesort_sql($header);
    $result = pager_query($sql . $tablesort, 10,0,$sql_count);
    while ($rate = db_fetch_object($result)) {
        $rows[] =
        array(
            // Cells
            $rate->username,
            $rate->date,
            $rate->paid,
            $rate->ref,
        );
    }

    if (!$rows) {
        $rows[] = array(array('data' => t('Data Not Found.'), 'colspan' => 20));
    }

    $output .= theme('table', $header, $rows);
    $output .= theme('pager', NULL, 10, 0);

    return $output;
}

function vstaff_cdr($username = NULL) {
    global $user;
    if (strlen($username)==0)
	$username = $user->name;

    $udetail = array();
    $result = db_query("SELECT balance,currencysym from vuser where username='%s'",$username);
    $udetail = db_fetch_object($result);
    $output = 'Account :'.$username.'<br>'.'Balance :'.$udetail->balance.' '.$udetail->currencysym;
    $output .= '<br><br><b>Payment:</b><br>';

    $header = array(
        array('data' => t('Username'), 'field' => 'username'),
        array('data' => t('Date'), 'field' => 'acctstarttime','sort'=>'desc'),
        array('data' => t('Number'), 'field' => 'calledstationid'),
        array('data' => t('Destination'), 'field' => 'tariffdesc'),
        array('data' => t('Rate'), 'field' => 'price'),
        array('data' => t('Duration'), 'field' => 'duration'),
        array('data' => t('Total'), 'field' => 'cost'),
        array('data' => t('Service <br>Charge'), 'field' => 'Service charge'),
    );
    $sql = " SELECT username,date_trunc('min',acctstarttime) as cdate,calledstationid,tariffdesc,price,duration,
  cost,o_service_charge from voipcall Where username = '$username' ";

    $tablesort = tablesort_sql($header);
    $sql_count = "Select count(username) from voipcall Where username = '$username'";
    $result = pager_query($sql . $tablesort, 30,0,$sql_count);

    while ($rate = db_fetch_object($result)) {
        $rows[] =
        array(
            // Cells
            $rate->username,
            $rate->cdate,
            $rate->calledstationid,
            $rate->tariffdesc,
            $rate->price,
            $rate->duration,
            $rate->cost,
            $rate->o_service_charge,
        );
    }

    if (!$rows) {
        $rows[] = array(array('data' => t('Data Not Found.'), 'colspan' => 20));
    }

    $output .= theme('table', $header, $rows);
    $output .= theme('pager', NULL, 30, 0);
    return $output;
}

