create or replace package okta_pkg as

  type t_user is record (
    id              varchar2(255),
    status          varchar2(255), 
    created         date, 
    activated       date, 
    statusChanged   date, 
    lastLogin       date, 
    lastUpdated     date,
    passwordChanged date, 
    firstName       varchar2(255), 
    lastName        varchar2(255), 
    login           varchar2(255), 
    email           varchar2(255), 
    mobilePhone     varchar2(255), 
    secondEmail     varchar2(255), 
    division        varchar2(255), 
    role            varchar2(255)
  );
  
  type t_group is record (
    id                     varchar2(255),
    created                date, 
    lastUpdated            date,
    lastMembershipUpdated  date, 
    objectClass            varchar2(255), 
    type                   varchar2(255), 
    name                   varchar2(255), 
    description            varchar2(255)
  );
  
  type t_error is record (
    errorCode              varchar2(1000),
    errorSummary           varchar2(1000), 
    errorLink              varchar2(255),
    errorId                varchar2(255), 
    errorCause             varchar2(2000)
  );

  type t_user_list is table of t_user index by binary_integer;
  type t_user_tab  is table of t_user;
  
  type t_group_list is table of t_group index by binary_integer;
  type t_group_tab  is table of t_group;

  type t_error_list is table of t_error index by binary_integer; 

  /**
  * Get a record with one or all OKTA users for this account.
  * Returns a record of type t_user_list.
  *
  * @example
  * TBD
  *
  * @param in_id An Id of a specific user. If null, all users will be returned.
  * @return t_user_list Record of type t_user_list.
  *
  * @author Plamen Mushkov
  */
  function get_user_list (
   in_id                in varchar2 default null ) return t_user_list;

  /**
  * Get a table with one or all OKTA users for this account. To be used with table() operator.
  *
  * @example
  * TBD
  *
  * @param in_id An Id of a specific user. If null, all users will be returned.
  * @return t_user_tab
  *
  * @author Plamen Mushkov
  */ 
  function get_user_tab (
   in_id                in varchar2 default null ) return t_user_tab pipelined;

  /**
  * Create a new OKTA user. A record with the newly created user is returned as out parameter.
  * Returns a record of type t_user_list.
  *
  * @example
  * TBD
  *
  * @param in_firstName          First name of the user. This is required field.
  * @param in_lastName           Last name of the user. This is required field.
  * @param in_email              Email of the user. This is required field.
  * @param in_login_name         Login name of the user. This is required field.
  * @param in_password           Password for the user. Not required.
  * @param in_recovery_question  Recovery question. Not required.
  * @param in_recovery_answer    Recovery answer. Not required.
  * @param in_activated          Indicate if the user is activated or not. Not required.
  * @param in_groupId            Group Id if you want to add the user into it. Not required.
  * @param out_user              Out parameter - record of type t_user_list.
  *
  * @author Plamen Mushkov
  */ 
  procedure create_user (
   in_firstName         in varchar2,
   in_lastName          in varchar2,
   in_email             in varchar2,
   in_login_name        in varchar2,
   in_password          in varchar2,
   in_recovery_question in varchar2,
   in_recovery_answer   in varchar2,
   in_activated         in varchar2,
   in_groupId           in varchar2,
   out_user             out t_user_list
  );
  
  /**
  * Delete the OKTA user with the provided ID.
  * If executed once, it deactivates the user. If executed second time - permanently deletes it.
  *
  * @example
  * TBD
  *
  * @param in_id The OKTA Id of the user.
  *
  * @author Plamen Mushkov
  */ 
  procedure delete_user (
   in_id                in varchar2 );

  /**
  * Deactivates the OKTA user with the provided ID. You can re-activate it, using the activate_user function.
  *
  * @example
  * TBD
  *
  * @param in_id The OKTA Id of the user.
  *
  * @author Plamen Mushkov
  */ 
  procedure deactivate_user (
   in_id                in varchar2 ); 

  /**
  * Activates a previously deactivated OKTA user with the provided ID.
  *
  * @example
  * TBD
  *
  * @param in_id The OKTA Id of the user.
  *
  * @author Plamen Mushkov
  */ 
  procedure activate_user (
   in_id                in varchar2,
   in_sendEmail         in varchar2 default 'false' );

  /**
  * Get a record with all OKTA groups for this account. 
  * Returns a record of type t_group_list.
  *
  * @example
  * TBD
  *
  * @return t_group_list A record of type t_group_list.
  *
  * @author Plamen Mushkov
  */
  function get_group_list return t_group_list;

  /**
  * Get a table with all OKTA groups for this account. To be used with table() operator.
  *
  * @example
  * TBD
  *
  * @return t_group_tab
  *
  * @author Plamen Mushkov
  */ 
  function get_group_tab return t_group_tab pipelined;
  
  /**
  * Create a new OKTA group. A record with the newly created group is returned as out parameter.
  * Returns a record of type t_group_list.
  *
  * @example
  * TBD
  *
  * @param in_name          Name of the OKTA group to be created. This is required field.
  * @param in_description   Description of the OKTA group. Not required.
  * @param out_group        Out parameter - record of type t_group_list.
  *
  * @author Plamen Mushkov
  */ 
  procedure create_group (
   in_name              in varchar2,
   in_description       in varchar2,
   out_group            out t_group_list
  );
  
  /**
  * Delete the OKTA group with the provided ID.
  *
  * @example
  * TBD
  *
  * @param in_id The OKTA Id of the group.
  *
  * @author Plamen Mushkov
  */ 
  procedure delete_group (
   in_id                in varchar2 );

end okta_pkg;
/
