create or replace package body okta_pkg AS

  g_OKTA_host   constant varchar2(255) := 'https://dev-9999999-admin.okta.com'; --  enter your OKTA admin URL here
  g_auth_str    constant varchar2(255) := 'SSWS '||'999999-9999999999999999999999999999999'; -- enter your OKTA API Key here
  g_date_format constant varchar2(30)  := 'YYYY-MM-DD"T"HH24:MI:SS".000Z"';
  
  -- private function to handle OTKTA API errors (JSON)
  function handle_errors (
    in_json_result clob ) return t_error_list 
  is
   l_error_list t_error_list;
   l_count      pls_integer :=0;
  begin
  
   for l_rec in (
                select * from (
                with json_msg as (select in_json_result msg from dual)
                    select *
                    from json_msg, json_table (
                            msg, '$[*]'
                            columns (
                                errorCode           path '$.errorCode',
                                errorSummary        path '$.errorSummary',
                                errorLink           path '$.errorLink',
                                errorId             path '$.errorId',
                                nested path '$.errorCauses[*]' columns (
                                    errorCause       path '$.errorSummary'
                                    --nested path '$.objectClass[*]' columns ( objectClass PATH '$' )
                            )
                        ) )  j
      ))
   loop    

        if l_rec.errorCode is not null then
       
            l_count := l_count + 1;

            l_error_list(l_count).errorCode             := l_rec.errorCode;
            l_error_list(l_count).errorSummary          := l_rec.errorSummary;
            l_error_list(l_count).errorLink             := l_rec.errorLink;
            l_error_list(l_count).errorId               := l_rec.errorId;

            l_error_list(l_count).errorCause            := l_rec.errorCause;

        end if; 
       
   end loop;    
   
   if l_count > 0 then
   
     for i IN l_error_list.first .. l_error_list.last loop
      
         dbms_output.put_line('Oooops, an error happened.');  
         dbms_output.put_line('errorCode -> '||l_error_list(i).errorCode);
         dbms_output.put_line('errorSummary -> '||l_error_list(i).errorSummary);
         dbms_output.put_line('errorLink -> '||l_error_list(i).errorLink);
         dbms_output.put_line('errorId -> '||l_error_list(i).errorId);
         dbms_output.put_line('errorCause -> '||l_error_list(i).errorCause);
         
         --raise_application_error(-20001, 'OKTA Error '||l_error_list(i).errorCode||': ' || l_error_list(i).errorSummary||' ('||l_error_list(i).errorCause||')');
      
     end loop;
    
   end if;  

   return l_error_list;
    
  end handle_errors;
  
  -- private function to add JSON array values to user collection
  function populate_user_list (
    in_json_result clob) return t_user_list 
  is
   l_user_list t_user_list;
   l_count     pls_integer :=0;
  begin
  
   for l_rec in (
                select * from (
                with json_msg as (select in_json_result msg from dual)
                    select *
                    from json_msg, json_table (
                            msg, '$[*]'
                            columns (
                                id              path '$.id',
                                status          path '$.status',
                                created         path '$.created',
                                activated       path '$.activated',
                                statusChanged   path '$.statusChanged',
                                lastLogin       path '$.lastLogin',
                                lastUpdated     path '$.lastUpdated',
                                passwordChanged path '$.passwordChanged',

                                nested path '$.profile[*]' columns (
                                    firstName   path '$.firstName',
                                    lastName    path '$.lastName',
                                    login       path '$.login',
                                    email       path '$.email',
                                    mobilePhone path '$.mobilePhone',
                                    secondEmail path '$.secondEmail',
                                    division    path '$.division',
                                    role        path '$.role'
                                    --nested path '$.role[*]' columns ( user_role PATH '$' )
                            )
                        ) )  j
      ))
   loop    

       l_count := l_count + 1;

       l_user_list(l_count).id                := l_rec.id;
       l_user_list(l_count).status            := l_rec.status;
       l_user_list(l_count).created           := to_date(l_rec.created, g_date_format);
       l_user_list(l_count).activated         := to_date(l_rec.activated, g_date_format);
       l_user_list(l_count).statusChanged     := to_date(l_rec.statusChanged, g_date_format);
       l_user_list(l_count).lastLogin         := to_date(l_rec.lastLogin, g_date_format);
       l_user_list(l_count).lastUpdated       := to_date(l_rec.lastUpdated, g_date_format);
       l_user_list(l_count).passwordChanged   := to_date(l_rec.passwordChanged, g_date_format);

       l_user_list(l_count).firstName         := l_rec.firstName; 
       l_user_list(l_count).lastName          := l_rec.lastName; 
       l_user_list(l_count).login             := l_rec.login; 
       l_user_list(l_count).email             := l_rec.email; 
       l_user_list(l_count).mobilePhone       := l_rec.mobilePhone; 
       l_user_list(l_count).secondEmail       := l_rec.secondEmail; 
       l_user_list(l_count).division          := l_rec.division; 
       l_user_list(l_count).role              := l_rec.role; 
   end loop;    

   return l_user_list;
    
  end populate_user_list;


  -- private function to add JSON array values to group collection
  function populate_group_list (
    in_json_result clob) return t_group_list 
  is
   l_group_list t_group_list;
   l_count     pls_integer :=0;
  begin
  
   for l_rec in (
                select * from (
                with json_msg as (select in_json_result msg from dual)
                    select *
                    from json_msg, json_table (
                            msg, '$[*]'
                            columns (
                                id                    path '$.id',
                                created               path '$.created',
                                lastUpdated           path '$.lastUpdated',
                                lastMembershipUpdated path '$.lastMembershipUpdated',
                                type                  path '$.type',
                                objectClass           path '$.objectClass',

                                nested path '$.profile[*]' columns (
                                    name              path '$.name',
                                    description       path '$.description'
                                    --nested path '$.objectClass[*]' columns ( objectClass PATH '$' )
                            )
                        ) )  j
      ))
   loop    

       l_count := l_count + 1;

       l_group_list(l_count).id                      := l_rec.id;
       l_group_list(l_count).created                 := to_date(l_rec.created, g_date_format);
       l_group_list(l_count).lastUpdated             := to_date(l_rec.lastUpdated, g_date_format);
       l_group_list(l_count).lastMembershipUpdated   := to_date(l_rec.lastMembershipUpdated, g_date_format);

       l_group_list(l_count).objectClass             := l_rec.objectClass; 
       l_group_list(l_count).type                    := l_rec.type; 
       l_group_list(l_count).name                    := l_rec.name; 
       l_group_list(l_count).description             := l_rec.description; 
       
   end loop;    

   return l_group_list;
    
  end populate_group_list;

  -- get OKTA users list
  function get_user_list (
   in_id                in varchar2 default null ) return t_user_list
  is
    l_result        clob;
    l_returnvalue   t_user_list;
    l_method_url    varchar2(255) := '/api/v1/users/'||in_id||'?limit=25';
    l_count         pls_integer := 0;
  begin

    apex_web_service.g_request_headers(1).name  := 'Accept';
    apex_web_service.g_request_headers(1).value := 'application/json';
    apex_web_service.g_request_headers(2).name  := 'Content-Type';
    apex_web_service.g_request_headers(2).value := 'application/json';
    apex_web_service.g_request_headers(3).name  := 'Authorization';
    apex_web_service.g_request_headers(3).value := g_auth_str;

    l_result := apex_web_service.make_rest_request(
        p_url => g_OKTA_host||l_method_url,
        p_http_method => 'GET' );
   
   l_returnvalue := populate_user_list (
       in_json_result => l_result);

   return l_returnvalue;

  end get_user_list;

  -- get OKTA users list 
  function get_user_tab (
   in_id                in varchar2 default null ) return t_user_tab pipelined
  is
    l_user_list                  t_user_list;
  begin

    l_user_list := get_user_list (in_id);

    for i in 1 .. l_user_list.count loop
        pipe row (l_user_list(i));
    end loop;

    return;

  end get_user_tab;

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
  )
  is
    l_result        clob;
    l_request_body  clob; 
    l_method_url    varchar2(255) := '/api/v1/users';
    l_count         pls_integer := 0;
    l_error_list    t_error_list;
  begin

    case 
      when lower(in_activated) = 'true' then
         l_method_url := l_method_url || '?activate=true';
      else
         l_method_url := l_method_url || '?activate=false';
    end case;     

    apex_web_service.g_request_headers(1).name  := 'Accept';
    apex_web_service.g_request_headers(1).value := 'application/json';
    apex_web_service.g_request_headers(2).name  := 'Content-Type';
    apex_web_service.g_request_headers(2).value := 'application/json';
    apex_web_service.g_request_headers(3).name  := 'Authorization';
    apex_web_service.g_request_headers(3).value := g_auth_str;

    l_request_body := '{ "profile": {'||
                           '"firstName": "'||in_firstName||'",'||
                           '"lastName": "'||in_lastName||'",'||
                           '"email": "'||in_email||'",'||
                           '"login": "'||in_login_name||'"'||
                       '}';  

    if in_password is not null then                    
       l_request_body := l_request_body || ' ,
                             "credentials": {
                               "password" : { "value": "'||in_password||'" }'||

                               case when in_recovery_question is not null and
                                         in_recovery_answer is not null 
                               then ' ,"recovery_question": {
                                          "question": "'||in_recovery_question||'",
                                          "answer": "'||in_recovery_answer||'"
                                  }' end ||

                             ' }';
    end if;   

    if in_groupId is not null then                    
       l_request_body := l_request_body || ' ,
                            "groupIds": [
                              "'||in_groupId||'"
                            ]';
    end if;   

    l_request_body := l_request_body || ' }';    

    dbms_output.put_line(l_request_body); 
    dbms_output.put_line(''); 

    l_result := apex_web_service.make_rest_request(
        p_url         => g_OKTA_host||l_method_url,
        p_http_method => 'POST',
        p_body        => l_request_body );
        
    dbms_output.put_line(l_result); 
    dbms_output.put_line('');     
        
    out_user := populate_user_list (
       in_json_result => l_result);

     -- check the response for errors
    l_error_list := handle_errors (
       in_json_result => l_result );    

  end create_user;
  
  -- delete OKTA user
  procedure delete_user (
   in_id                in varchar2 )
  is
    l_result        clob;
    l_method_url    varchar2(255) := '/api/v1/users/'||in_id;
    l_error_list    t_error_list; 
  begin

    apex_web_service.g_request_headers(1).name  := 'Accept';
    apex_web_service.g_request_headers(1).value := 'application/json';
    apex_web_service.g_request_headers(2).name  := 'Content-Type';
    apex_web_service.g_request_headers(2).value := 'application/json';
    apex_web_service.g_request_headers(3).name  := 'Authorization';
    apex_web_service.g_request_headers(3).value := g_auth_str;

    l_result := apex_web_service.make_rest_request(
        p_url => g_OKTA_host||l_method_url,
        p_http_method => 'DELETE' );
        
    dbms_output.put_line(l_result); 
    dbms_output.put_line('');    
    
    -- check the response for errors
    l_error_list := handle_errors (
       in_json_result => l_result );     
        
  end delete_user;

  -- Deactivate OKTA user
  procedure deactivate_user (
   in_id                in varchar2 )
  is
    l_result        clob;
    l_method_url    varchar2(255) := '/api/v1/users/'||in_id||'/lifecycle/deactivate';
    l_error_list    t_error_list;  
  begin
    
    apex_web_service.g_request_headers(1).name  := 'Accept';
    apex_web_service.g_request_headers(1).value := 'application/json';
    apex_web_service.g_request_headers(2).name  := 'Content-Type';
    apex_web_service.g_request_headers(2).value := 'application/json';
    apex_web_service.g_request_headers(3).name  := 'Authorization';
    apex_web_service.g_request_headers(3).value := g_auth_str;

    l_result := apex_web_service.make_rest_request(
        p_url => g_OKTA_host||l_method_url,
        p_http_method => 'POST' );
        
    dbms_output.put_line(l_result); 
    dbms_output.put_line('');    
    
    -- check the response for errors
    l_error_list := handle_errors (
       in_json_result => l_result );     

  end deactivate_user; 

  -- Activate a Deactivated OKTA user 
  procedure activate_user (
   in_id                in varchar2,
   in_sendEmail         in varchar2 default 'false')
  is
    l_result        clob;
    l_method_url    varchar2(255) := '/api/v1/users/'||in_id||'/lifecycle/activate?sendEmail='||in_sendEmail;
    l_error_list    t_error_list;  
  begin
    
    apex_web_service.g_request_headers(1).name  := 'Accept';
    apex_web_service.g_request_headers(1).value := 'application/json';
    apex_web_service.g_request_headers(2).name  := 'Content-Type';
    apex_web_service.g_request_headers(2).value := 'application/json';
    apex_web_service.g_request_headers(3).name  := 'Authorization';
    apex_web_service.g_request_headers(3).value := g_auth_str;

    l_result := apex_web_service.make_rest_request(
        p_url => g_OKTA_host||l_method_url,
        p_http_method => 'POST' );
        
    dbms_output.put_line(l_result); 
    dbms_output.put_line('');    
    
    -- check the response for errors
    l_error_list := handle_errors (
       in_json_result => l_result );   

  end activate_user;      
  
  -- get OKTA groups list
  function get_group_list return t_group_list
  is
    l_result        clob;
    l_returnvalue   t_group_list;
    l_method_url    varchar2(255) := '/api/v1/groups';
    l_count         pls_integer := 0;
  begin

    apex_web_service.g_request_headers(1).name  := 'Accept';
    apex_web_service.g_request_headers(1).value := 'application/json';
    apex_web_service.g_request_headers(2).name  := 'Content-Type';
    apex_web_service.g_request_headers(2).value := 'application/json';
    apex_web_service.g_request_headers(3).name  := 'Authorization';
    apex_web_service.g_request_headers(3).value := g_auth_str;

    l_result := apex_web_service.make_rest_request(
        p_url => g_OKTA_host||l_method_url,
        p_http_method => 'GET' );  
        
    l_returnvalue := populate_group_list (
       in_json_result => l_result);  

   return l_returnvalue;

  end get_group_list;

  -- get OKTA groups table 
  function get_group_tab return t_group_tab pipelined
  is
    l_group_list                  t_group_list;
  begin

    l_group_list := get_group_list;

    for i in 1 .. l_group_list.count loop
        pipe row (l_group_list(i));
    end loop;

    return;

  end get_group_tab;
  
  -- create OKTA group
  procedure create_group (
   in_name              in varchar2,
   in_description       in varchar2,
   out_group            out t_group_list
  )
  is
    l_result        clob;
    l_request_body  clob; 
    l_returnvalue   t_group_list;
    l_error_list    t_error_list;
    l_method_url    varchar2(255) := '/api/v1/groups';
    l_count         pls_integer := 0;
  begin 

    apex_web_service.g_request_headers(1).name  := 'Accept';
    apex_web_service.g_request_headers(1).value := 'application/json';
    apex_web_service.g_request_headers(2).name  := 'Content-Type';
    apex_web_service.g_request_headers(2).value := 'application/json';
    apex_web_service.g_request_headers(3).name  := 'Authorization';
    apex_web_service.g_request_headers(3).value := g_auth_str;

    l_request_body := '{ "profile": {'||
                           '"name": "'||in_name||'",'||
                           '"description": "'||in_description||'"'||
                       '}';  

    l_request_body := l_request_body || ' }';    

    dbms_output.put_line(l_request_body); 
    dbms_output.put_line(''); 

    -- call OKTA REST API  
    l_result := apex_web_service.make_rest_request(
        p_url         => g_OKTA_host||l_method_url,
        p_http_method => 'POST',
        p_body        => l_request_body );

    dbms_output.put_line(l_result); 
    dbms_output.put_line('');     
        
    -- parse the JSON response from the OKTA REST API    
    out_group := populate_group_list (
       in_json_result => l_result);  
       
    -- check the response for errors
    l_error_list := handle_errors (
       in_json_result => l_result );  

  end create_group;
  
  -- delete OKTA group
  procedure delete_group (
   in_id                in varchar2 )
  is
    l_result        clob;
    l_method_url    varchar2(255) := '/api/v1/groups/'||in_id;
  begin

    apex_web_service.g_request_headers(1).name  := 'Accept';
    apex_web_service.g_request_headers(1).value := 'application/json';
    apex_web_service.g_request_headers(2).name  := 'Content-Type';
    apex_web_service.g_request_headers(2).value := 'application/json';
    apex_web_service.g_request_headers(3).name  := 'Authorization';
    apex_web_service.g_request_headers(3).value := g_auth_str;

    l_result := apex_web_service.make_rest_request(
        p_url => g_OKTA_host||l_method_url,
        p_http_method => 'DELETE' );
        
  end delete_group;

end okta_pkg;
/
