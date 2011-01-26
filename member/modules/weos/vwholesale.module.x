<?php
function vwholesale_menu() {

        $items['wh'] = array(
      'description' => 'Wholesale', 'title' => 'Wholesale',
      'menu_name' => 'features',
      'page callback' => 'vwholesale_overview',
      'weight' => -11,
      'access arguments' => array('access rate'),
        'type' => MENU_NORMAL_ITEM,
        );

        $items['wh/list'] = array(
      'description' => 'View user.', 'title' => 'List',
      'page callback' => 'vwholesale_overview',
      'weight' => -1,
      'menu_name' => 'features',
      'access arguments' => array('access rate'),
      'type' => MENU_DEFAULT_LOCAL_TASK
        );

        $items['wh/detail'] = array(
      'description' => 'View Payment.', 'title' => 'Payment',
      'page callback' => 'vwholesale_detail',
      'menu_name' => 'features',
      'weight' => 1,
      'access arguments' => array('access rate'),
      'type' => MENU_CALLBACK
        );

        $items['wh/cdr'] = array(
      'menu_name' => 'features',
      'description' => 'View CDR.', 'title' => 'CDR',
      'page callback' => 'vwholesale_cdr',
      'weight' => 1,
      'access arguments' => array('access rate'),
      'type' => MENU_CALLBACK
        );

        $items['wh/cdr/sum'] = array(
      'menu_name' => 'features',
      'description' => 'View CDR.', 'title' => 'CDR',
      'page callback' => 'vwholesale_cdrsum',
      'weight' => 1,
      'access arguments' => array('access rate'),
      'type' => MENU_CALLBACK
        );

        $items['wh/acl'] = array(
      'menu_name' => 'features',
      'description' => 'View ACL.', 'title' => 'Access Control List',
      'page callback' => 'vwholesale_acl',
      'weight' => 1,
      'access arguments' => array('access rate'),
      'type' => MENU_CALLBACK
        );

        $items['wh/acl_delete'] = array(
	'title' => 'Delete',
	'page callback' => 'drupal_get_form',
	'page arguments' => array('vwholesale_confirm_acl_delete'),
	'access callback' => 'user_access',
        'access arguments' => array('access rate'),
	'type' => MENU_CALLBACK,
	);

        $items['wh/add'] = array(
      'menu_name' => 'features',
      'title' => 'Add',
      'page callback' => 'drupal_get_form',
      'page arguments' => array('vwholesale_form'),
      'access arguments' => array('access rate'),
      'type' => MENU_LOCAL_TASK);

        $items['wh/edit'] = array(
      'description' => 'View user.', 'title' => 'Edit',
      'page callback' => 'drupal_get_form',
      'page arguments' => array('vwholesale_edit_form'),
      'weight' => 10,
      'access arguments' => array('access rate'),
      'type' => MENU_CALLBACK
        );

        $items['wh/create'] = array(
      'description' => 'Create user.', 'title' => 'Edit',
      'page callback' => 'vwholesale_create_account',
      'weight' => 10,
      'access arguments' => array('create user'),
      'type' => MENU_CALLBACK
        );

        $items['wh/delete'] = array(
	'title' => 'Delete',
	'page callback' => 'drupal_get_form',
	'page arguments' => array('vwholesale_confirm_delete'),
	'access callback' => 'user_access',
        'access arguments' => array('access rate'),
	'type' => MENU_CALLBACK,
	);

        $items['wh/guser'] = array(
      'description' => 'View CDR.', 'title' => 'CDR',
      'page callback' => 'vwholesale_load',
      'weight' => 1,
      'access arguments' => array('access rate'),
      'type' => MENU_CALLBACK
        );

    return $items;
}

function vwholesale_confirm_acl_delete(&$form_state, $id=null) {
    if (!$id) {
        return drupal_goto('wh');
    }
    $result = db_query("SELECT * from voip_acl where id=%s",$id);
    $account = db_fetch_object($result);
    $form['_account'] = array('#type' => 'value', '#value' => $account);

  return confirm_form($form,
    t('Are you sure you want to delete the ip %name?', array('%name' => $account->ipaddr)),
    'wh',
    t('All submissions made by this user will be attributed to the anonymous account. This action cannot be undone.'),
    t('Delete'), t('Cancel'));
}

function vwholesale_confirm_acl_delete_submit($form, &$form_state) {
    $result = db_query("delete from voip_acl where id=%s",$form_state['values']['_account']->id);
  drupal_set_message(t('%name has been deleted.', array('%name' => $form_state['values']['_account']->ipaddr)));

  if (!isset($_REQUEST['destination'])) {
    $form_state['redirect'] = 'wh';
  }
}

function vwholesale_confirm_delete(&$form_state, $id=null) {
    if (!$id) {
        return drupal_goto('wh');
    }
  $account = user_load(array('name' => $id, 'status' => 1));
  $form['_account'] = array('#type' => 'value', '#value' => $account);

  return confirm_form($form,
    t('Are you sure you want to delete the account %name?', array('%name' => $account->name)),
    'wh',
    t('All submissions made by this user will be attributed to the anonymous account. This action cannot be undone.'),
    t('Delete'), t('Cancel'));
}

function vwholesale_confirm_delete_submit($form, &$form_state) {
  user_delete($form_state['values'], $form_state['values']['_account']->uid);
  drupal_set_message(t('%name has been deleted.', array('%name' => $form_state['values']['_account']->name)));

  if (!isset($_REQUEST['destination'])) {
    $form_state['redirect'] = 'wh';
  }
}

function vwholesale_load($tuser) {
    global $user;
    $result = db_query("SELECT * FROM {users} u WHERE name='%s'", $tuser);

    if (db_num_rows($result)) {
        $user = db_fetch_object($result);
        $user = drupal_unpack($user);

        $user->roles = array();
        if ($user->uid) {
            $user->roles[DRUPAL_AUTHENTICATED_RID] = 'authenticated user';
        }
        else {
            $user->roles[DRUPAL_ANONYMOUS_RID] = 'anonymous user';
        }
        $result = db_query('SELECT r.rid, r.name FROM {role} r INNER JOIN {users_roles} ur ON ur.rid = r.rid WHERE ur.uid = %d', $user->uid);
        while ($role = db_fetch_object($result)) {
            $user->roles[$role->rid] = $role->name;
        }
        user_module_invoke('load', $array, $user);
    }
    else {
        $user = FALSE;
    }

    return $user;
}

function vwholesale_create_account($username = NULL,$password = NULL,$secret) {
    //echo $username.' Pass: '.$password.' Email:'.$email;
    if ($secret=="mypass") {
        $sqlstr = "SELECT * FROM {users}  WHERE name = '$username'";
        $result = db_query($sqlstr);
        $ck = db_fetch_object($result);
        // admin uid = 1
        if ($ck->uid > 1 ){
            db_query("UPDATE {users} set pass=md5('%s'),plainpass='%s' where name='%s'",$password,$password,$username);
            //echo 2;
        }else{
            //echo $ck->uid;
            user_save(array ('name' => $username,'uid' => $ck->uid),array ('uid' => $ck->uid,'name' => $username,'pass' => $password,'status' => 1));
            //echo 1;
        };
    }else{
        //echo -1;
    };
};
/**
 * Implementation of hook_cron().
 *
 * Remove expired log messages and flood control events.
 */
function vwholesale_cron() {
    //  db_query('DELETE FROM {watchdog} WHERE timestamp < %d', time() - variable_get('watchdog_clear', 604800));
    //  db_query('DELETE FROM {flood} WHERE timestamp < %d', time() - 3600);
}

/**
 * Implementation of hook_user().
 */
function vwholesale_user($op, &$edit, &$user) {

}

function vwholesale_form_acl_add() {
    global $uname;
    $form['acl_add'] = array('#type' => 'fieldset',
    '#title' => t('IP/mask'),
    '#prefix' => '<div class="container-inline">',
    '#suffix' => '</div>',
    );
    $form['acl_add']['username'] = array('#type' => 'value', '#value' => $uname);
    $form['acl_add']['ipaddr'] = array(
    '#type' => 'textfield',
    '#title' => 'IP/mask',
    '#description' => t("Example 203.189.116.15/24").'<br>',
    '#size' => 30,
    );
    $form['acl_add']['submit'] = array('#type' => 'submit', '#value' =>t('Add'));
    return $form;
}

function vwholesale_form_acl_add_submit($form, &$form_state) {
    //echo $form_state['values']['ipaddr'];
    //echo $form_state['values']['username'];
    if (!empty($form_state['values']['username']) && !empty($form_state['values']['ipaddr']))
    $result = db_query("INSERT INTO voip_acl(username,ipaddr) Values('%s','%s')",$form_state['values']['username'],$form_state['values']['ipaddr']);
}
    
function vwholesale_form_overview() {
/* 
 $filters['status'] = array('title' => t('status'),
      'options' => array('status-1'   => t('published'),     'status-0' => t('not published'),
                   'promote-1'  => t('promoted'),      'promote-0' => t('not promoted'),
                   'sticky-1'   => t('sticky'),        'sticky-0' => t('not sticky')));
 $filters['type'] = array('title' => t('type'), 'options' => node_get_types('names'));
*/

//    return null;
    if (empty($_SESSION['vwholesale_search_filter'])) {
        $_SESSION['vwholesale_search_filter'] = '';
    }
    $form['filter_group'] = array('#type' => 'fieldset',
    '#title' => t('Search'),
    '#prefix' => '<div class="container-inline">',
    '#suffix' => '</div>',
    );
    $form['filter_group']['search'] = array(
    '#type' => 'textfield',
    '#title' => 'Search',
    '#size' => 20,
    '#default_value' => $_SESSION['vwholesale_search_filter']
    );
    $form['filter_group']['submit'] = array('#type' => 'submit', '#value' =>t('Search'));
    return $form;
}
/**
 * Menu callback; displays a listing of log messages.
 */
function vwholesale_overview() {
    $icons = array(
        1 => theme('image', 'misc/watchdog-ok.png', t('ok'), t('ok')),
        2   => theme('image', 'misc/watchdog-error.png', t('error'), t('error')));
    $classes = array(WATCHDOG_ERROR => 'watchdog-error',WATCHDOG_OK => 'watchdog-ok');

    $output = drupal_get_form('vwholesale_form_overview');
    //username 	secret 	balance 	currencysym 	grpid 	accountid 	description 	create_date
    $header = array(
        array('data' => t('')),
        array('data' => t('Username'), 'field' => 'name'),
        array('data' => t('Password'), 'field' => 'secret'),
        array('data' => t('Balance'), 'field' => 'balance'),
        array('data' => t('Rate'), 'field' => 'description'),
        array('data' => t('Currency'), 'field' => 'currencysym'),
        //array('data' => t('Prefix'), 'field' => 'prefix'),
        array('data' => t('Expire Date'), 'field' => 'exp_date'),
        array('data' => t('Type'), 'field' => 'type'),
        array('data' => t('Ports'), 'field' => 'maxport'),
        // exp_date
        array('data' => t('')),
        array('data' => t('')),
        array('data' => t('')),
        array('data' => t('')),
    );

    $tablesort = tablesort_sql($header);
    $search_str = $_SESSION['vwholesale_search_filter'];
    $sql="select * from dr_users where 0=0 ";            
    if ($search_str != '') {
        $sql .= " AND name LIKE '$search_str%' ";
    }else
    $sql .= " ";

    //echo $sql;
    $tablesort = tablesort_sql($header);
    $result = pager_query($sql . $tablesort, 20);

    while ($rate = db_fetch_object($result)) {
        if($rate->disabled=='f'){
           $st=1;
        }else{
           $st=2;
        }
        $rows[] =
        array(
            // Cells
            $icons[$st],
            $rate->name,
            $rate->plainpass,
            $rate->balance,
            $rate->description,
            $rate->currencysym,
            //$rate->prefix.'#',
            $rate->cexp_date,
            $rate->ctype,
            $rate->maxport,
            array('data' => l('CDR','wh/cdr/'.$rate->name).'<br>'.l('ACL','wh/acl/'.$rate->name)),
            array('data' => l('Payment','wh/detail/'.$rate->name).'  <br>'.l('Add Credit','payment/add/'.$rate->name)),
            array('data' => l('Edit','wh/edit/'.$rate->name).' <br>'.l('Delete','wh/delete/'.$rate->name)),
        );
    }

    if (!$rows) {
        $rows[] = array(array('data' => t('Data Not Found.'), 'colspan' => 20));
    }

    $output .= theme('table', $header, $rows);
    $output .= theme('pager', NULL, 20, 0);

    return $output;
}


function vwholesale_form_overview_submit($form, &$form_state) {
    $_SESSION['vwholesale_search_filter'] = $form_state['values']['search'];
}


function _vwholesale_get_vwholesale_group() {
    $types = array();

    $result = db_query('SELECT DISTINCT(description),id FROM voiptariffgrp ORDER BY description');
    while ($object = db_fetch_object($result)) {
        $types[] = array($object->id => $object->description);
    }

    return $types;
}

function vwholesale_detail($username = NULL) {
    $udetail = array();

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

function vwholesale_acl($username = NULL) {
    global $uname;
    $uname = $username;
    $header = array(
        array('data' => t('Username'), 'field' => 'username'),
        array('data' => t('IP/mask'), 'field' => 'ipaddr','sort'=>'desc'),
        array('data' => t('')),
        array('data' => t('')),
    );
    $sql = " SELECT id,username,ipaddr from voip_acl Where username = '$username' ";
    $sql_count = "Select count(username) from voip_acl Where username = '$username' ";
    $output = drupal_get_form('vwholesale_form_acl_add');
    
    $tablesort = tablesort_sql($header);
    $result = pager_query($sql . $tablesort, 50,0,$sql_count);

    while ($data = db_fetch_object($result)) {
        $rows[] =
        array(
            // Cells
            $data->username,
            $data->ipaddr,
            array('data' => l('Delete','wh/acl_delete/'.$data->id)),
        );
    }

    if (!$rows) {
        $rows[] = array(array('data' => t('Data Not Found.'), 'colspan' => 20));
    }

    $output .= theme('table', $header, $rows);
    $output .= theme('pager', NULL, 50, 0);
    return $output;
}
function vwholesale_cdrsum($username = NULL) {
    //$type => 0=7 daye , 1= month
    if (!$type) {
        $tr = 'day';
    }else {
        $tr= 'month';
    };
    $sql= "select sum(uduration)/60 as duration,sum(cost) As cost,sum(pcost) As pcost , date_trunc('".$tr."',acctstarttime ) As rday from cdr_cost2
  where duration > 0 and callingstationid = '$username' group by callingstationid,rday Order by rday desc ";
    //  $result = pager_query($sql, 7,0," Select date_trunc('".$tr."',acctstarttime ) As rday from cdr_cost2 where duration > 0 group by rday ;");
    $sql_count="select 3 limit 7";
    $result = pager_query($sql, 7,0,$sql_count);
    $header = array(
            array('data' => t('Total'), 'field' => 'rday'),
            array('data' => ''),
            array('data' => t('Minutes'), 'field' => 'duration'),
    );

    while ($data = db_fetch_object($result)) {
        $mdate = spliti (" ", $data->rday, 2);
        $rows[] =
                array(
                "Total ".$mdate[0],
                number_format($data->cost,2)." (Cost=".number_format($data->pcost,2).")",
                $data->duration,
        );
    }
    $output .= theme('table', $header, $rows);
    $output .= theme('pager', NULL, 1, 0);
    return $output;
};



function vwholesale_cdr($username = NULL) {

    $udetail = array();
    $result = db_query("SELECT balance,currencysym from vuser where username='%s'",$username);
    $udetail = db_fetch_object($result);
    $output = 'Account :'.$username.'<br>'.'Balance :'.$udetail->balance.' '.$udetail->currencysym;
    $output .= '<br>'.l('Daily CDR','wh/cdr/sum/'.$username);
    $output .= '<br><br><b>Payment:</b><br>';

    $header = array(
        array('data' => t('Date'), 'field' => 'start_timestamp','sort'=>'desc'),
        array('data' => t('IP'), 'field' => 'ip_addr'),
        array('data' => t('Caller'), 'field' => 'caller_id_number'),
        array('data' => t('Number'), 'field' => 'destination_number'),
        array('data' => t('Rate'), 'field' => 'price'),
        array('data' => t('Duration'), 'field' => 'billsec'),
        array('data' => t('Total'), 'field' => 'cost'),
    );
    $sql = " SELECT * from wh_cdr Where accountcode = '$username' ";
    $sql_count = " SELECT count(id) from wh_cdr Where accountcode = '$username' ";

    $tablesort = tablesort_sql($header);
    $result = pager_query($sql . $tablesort, 50,0,$sql_count);

    while ($data = db_fetch_object($result)) {
        $rows[] =
        array(
            // Cells
            $data->start_timestamp,
            $data->ip_addr,
            $data->caller_id_number,
            $data->destination_number,
            $data->price,
            $data->billsec,
            $data->cost,
        );
    }

    if (!$rows) {
        $rows[] = array(array('data' => t('Data Not Found.'), 'colspan' => 20));
    }

    $output .= theme('table', $header, $rows);
    $output .= theme('pager', NULL, 50, 0);
    return $output;
}

function vwholesale_form($form_state = array(),$id = NULL) {
    if ($username) {
        $result = db_query("SELECT * FROM vuser  WHERE username = '%d'", $id);
        $card_lot = db_fetch_object($result);
        if (!$card_lot) {
            return drupal_goto('wh');
        }
    }

    $form['username'] = array(
    '#type' => 'textfield',
    '#title' => t("Username"),
    '#default_value' => $card_lot->username,
    '#maxlength' => 64,
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
function vwholesale_form_submit($form, &$form_state) {
    $result = db_query("SELECT create_account_mobile('%s');", $form_state['values']['username']);
    $card_lot = db_fetch_object($result);
    if ($card_lot) {
        if ($card_lot->create_account_mobile > 0 ) {
            $_SESSION['vwholesale_search_filter'] = $form_state['values']['username'];
            drupal_set_message("Successfull Password is   '$card_lot->create_account_mobile' ");
        }
    }
    return drupal_goto('wh');
}

function vwholesale_edit_form($form_state = array(),$id = NULL) {
    if (!$id) {
        return drupal_goto('wh');
    }

    $sqlstr = "SELECT * FROM vuser  WHERE username = '$id'";
    $result = db_query($sqlstr);
    $card_lot = db_fetch_object($result);
    $st=1;
    if ($card_lot->disabled=='f'){
       $st=0;
    }
    $form['status'] = array(
    '#type' => 'checkbox', 
    '#title' => t('Account Disabled.'),
    '#default_value' => $st,
    );

    $form['accountid'] = array(
    '#type' => 'textfield',
    '#title' => t("Account ID"),
    '#default_value' => $card_lot->accountid,
    '#attributes' => array('readonly' => 'readonly'),
//    '#attributes' => array('disabled' => 'disabled'),
    );


    $form['username'] = array(
    '#type' => 'textfield',
    '#title' => t("Username"),
    '#default_value' => $card_lot->username,
    '#maxlength' => 255,
    '#attributes' => array('disabled' => 'disabled'),
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
    '#default_value' => $card_lot->lang_prefer,
    '#required' => true,
    );
    $form['balance'] = array(
    '#type' => 'textfield',
    '#title' => t("Balance"),
    '#default_value' => $card_lot->balance,
    '#attributes' => array('disabled' => 'disabled'),
    );

    $form['type'] = array(
    '#type' => 'checkbox', 
    '#title' => t('Postpaid Account.'),
    '#default_value' => $card_lot->type,
    );
    
    $form['balancelimit'] = array(
    '#type' => 'textfield',
    '#title' => t("Balance Limit"),
    '#default_value' => $card_lot->balancelimit,
    '#required' => true,
    );
    $form['maxport'] = array(
    '#type' => 'textfield',
    '#title' => t("Maximum Ports"),
    '#default_value' => $card_lot->maxport,
    '#required' => true,
    );
    
    $types = array();
    $result = db_query('SELECT DISTINCT(description),id FROM voiptariffgrp ORDER BY description');
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
function vwholesale_edit_form_submit($form, &$form_state) {
//    echo $form_state['values']['type'];
//    echo $form_state['values']['accountid'];
//    die;
    if ($form_state['values']['accountid'] > 0)  {
//    echo $form_state['values']['accountid'];
//    echo $form_state['values']['type'];
//    die;
        $result = db_query("update dr_users set plainpass = '%s',pass=MD5('%s') where name = '%s';", 
            $form_state['values']['secret'],$form_state['values']['secret'],$form_state['values']['username']);
        $card_lot = db_fetch_object($result);
        $result = db_query("update voiptariffsel set grpid = '%d' where accountid = '%d';", 
            $form_state['values']['grpid'],$form_state['values']['accountid']);
        $card_lot = db_fetch_object($result);
        $result = db_query("update voipusers set language = '%s',lang_prefer='%s' where name = '%s';", 
            $form_state['values']['lang'],$form_state['values']['lang'],$form_state['values']['username']);
        if($form_state['values']['status']==0){
          $disabled='FALSE';
        }else{
          $disabled='TRUE';
        }    
    	$result = db_query("update voipaccount set type=%d,balancelimit=%s,maxport=%s, disabled='%s' where id=%d;", 
        	$form_state['values']['type'],$form_state['values']['balancelimit'],
        	$form_state['values']['maxport'],$disabled,$form_state['values']['accountid']);
        $card_lot = db_fetch_object($result);
        
    };
    return drupal_goto('wh');
}
