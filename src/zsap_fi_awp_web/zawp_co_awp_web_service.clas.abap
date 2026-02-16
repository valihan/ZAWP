class ZAWP_CO_AWP_WEB_SERVICE definition
  public
  inheriting from CL_PROXY_CLIENT
  create public .

public section.

  methods CHANGE_STATUS
    importing
      !CHANGE_STATUS type ZAWP_CHANGE_STATUS
    exporting
      !CHANGE_STATUS_RESPONSE type ZAWP_CHANGE_STATUS_RESPONSE
    raising
      CX_AI_SYSTEM_FAULT
      ZAWP_CX_TRUSTY_OCSPNOT_AVAILAB
      ZAWP_CX_ACCESS_DENIED_EXCEPTIO
      ZAWP_CX_BUSINESS_EXCEPTION
      ZAWP_CX_TRUSTY_OCSPUNKNOWN_PRO
      ZAWP_CX_TRUSTY_OCSPNONCE_EXCEP
      ZAWP_CX_TRUSTY_OCSPCERTIFICATE
      ZAWP_CX_SESSION_CLOSED_EXCEPTI .
  methods CONSTRUCTOR
    importing
      !DESTINATION type ref to IF_PROXY_DESTINATION optional
      !LOGICAL_PORT_NAME type PRX_LOGICAL_PORT_NAME optional
    preferred parameter LOGICAL_PORT_NAME
    raising
      CX_AI_SYSTEM_FAULT .
  methods QUERY_AWP
    importing
      !QUERY_AWP type ZAWP_QUERY_AWP
    exporting
      !QUERY_AWP_RESPONSE type ZAWP_QUERY_AWP_RESPONSE1
    raising
      CX_AI_SYSTEM_FAULT
      ZAWP_CX_ACCESS_DENIED_EXCEPTIO
      ZAWP_CX_BUSINESS_EXCEPTION
      ZAWP_CX_SESSION_CLOSED_EXCEPTI .
  methods QUERY_AWP_BY_ID
    importing
      !QUERY_AWP_BY_ID type ZAWP_QUERY_AWP_BY_ID
    exporting
      !QUERY_AWP_BY_ID_RESPONSE type ZAWP_QUERY_AWP_BY_ID_RESPONSE
    raising
      CX_AI_SYSTEM_FAULT
      ZAWP_CX_ACCESS_DENIED_EXCEPTIO
      ZAWP_CX_BUSINESS_EXCEPTION
      ZAWP_CX_SESSION_CLOSED_EXCEPTI .
  methods QUERY_AWP_ERROR_BY_ID
    importing
      !QUERY_AWP_ERROR_BY_ID type ZAWP_QUERY_AWP_ERROR_BY_ID
    exporting
      !QUERY_AWP_ERROR_BY_ID_RESPONSE type ZAWP_QUERY_AWP_ERROR_BY_ID_RES
    raising
      CX_AI_SYSTEM_FAULT
      ZAWP_CX_ACCESS_DENIED_EXCEPTIO
      ZAWP_CX_BUSINESS_EXCEPTION
      ZAWP_CX_SESSION_CLOSED_EXCEPTI .
  methods QUERY_AWP_HISTORY_BY_ID
    importing
      !QUERY_AWP_HISTORY_BY_ID type ZAWP_QUERY_AWP_HISTORY_BY_ID
    exporting
      !QUERY_AWP_HISTORY_BY_ID_RESPON type ZAWP_QUERY_AWP_HISTORY_BY_ID_R
    raising
      CX_AI_SYSTEM_FAULT
      ZAWP_CX_BUSINESS_EXCEPTION
      ZAWP_CX_ACCESS_DENIED_EXCEPTIO
      ZAWP_CX_SESSION_CLOSED_EXCEPTI .
  methods QUERY_AWP_STATUS_BY_ID
    importing
      !QUERY_AWP_STATUS_BY_ID type ZAWP_QUERY_AWP_STATUS_BY_ID
    exporting
      !QUERY_AWP_STATUS_BY_ID_RESPONS type ZAWP_QUERY_AWP_STATUS_BY_ID_RE
    raising
      CX_AI_SYSTEM_FAULT
      ZAWP_CX_ACCESS_DENIED_EXCEPTIO
      ZAWP_CX_BUSINESS_EXCEPTION
      ZAWP_CX_SESSION_CLOSED_EXCEPTI .
  methods QUERY_DELETE_AWP
    importing
      !QUERY_DELETE_AWP type ZAWP_QUERY_DELETE_AWP
    exporting
      !QUERY_DELETE_AWP_RESPONSE type ZAWP_QUERY_DELETE_AWP_RESPONSE
    raising
      CX_AI_SYSTEM_FAULT
      ZAWP_CX_TRUSTY_OCSPNOT_AVAILAB
      ZAWP_CX_ACCESS_DENIED_EXCEPTIO
      ZAWP_CX_BUSINESS_EXCEPTION
      ZAWP_CX_TRUSTY_OCSPUNKNOWN_PRO
      ZAWP_CX_TRUSTY_OCSPNONCE_EXCEP
      ZAWP_CX_TRUSTY_OCSPCERTIFICATE
      ZAWP_CX_SESSION_CLOSED_EXCEPTI .
  methods QUERY_UPDATE
    importing
      !QUERY_UPDATE type ZAWP_QUERY_UPDATE
    exporting
      !QUERY_UPDATE_RESPONSE type ZAWP_QUERY_UPDATE_RESPONSE
    raising
      CX_AI_SYSTEM_FAULT
      ZAWP_CX_TRUSTY_OCSPNOT_AVAILAB
      ZAWP_CX_ACCESS_DENIED_EXCEPTIO
      ZAWP_CX_BUSINESS_EXCEPTION
      ZAWP_CX_TRUSTY_OCSPUNKNOWN_PRO
      ZAWP_CX_TRUSTY_OCSPNONCE_EXCEP
      ZAWP_CX_TRUSTY_OCSPCERTIFICATE
      ZAWP_CX_SESSION_CLOSED_EXCEPTI .
  methods QUERY_VIEW_AWP
    importing
      !QUERY_VIEW_AWP type ZAWP_QUERY_VIEW_AWP
    exporting
      !QUERY_VIEW_AWP_RESPONSE type ZAWP_QUERY_VIEW_AWP_RESPONSE
    raising
      CX_AI_SYSTEM_FAULT
      ZAWP_CX_TRUSTY_OCSPNOT_AVAILAB
      ZAWP_CX_ACCESS_DENIED_EXCEPTIO
      ZAWP_CX_BUSINESS_EXCEPTION
      ZAWP_CX_TRUSTY_OCSPUNKNOWN_PRO
      ZAWP_CX_TRUSTY_OCSPNONCE_EXCEP
      ZAWP_CX_TRUSTY_OCSPCERTIFICATE
      ZAWP_CX_SESSION_CLOSED_EXCEPTI .
  methods UPLOAD_AWP
    importing
      !UPLOAD_AWP type ZAWP_UPLOAD_AWP
    exporting
      !UPLOAD_AWP_RESPONSE type ZAWP_UPLOAD_AWP_RESPONSE1
    raising
      CX_AI_SYSTEM_FAULT
      ZAWP_CX_ACCESS_DENIED_EXCEPTIO
      ZAWP_CX_BUSINESS_EXCEPTION
      ZAWP_CX_SESSION_CLOSED_EXCEPTI .
protected section.
private section.
ENDCLASS.



CLASS ZAWP_CO_AWP_WEB_SERVICE IMPLEMENTATION.


  method CHANGE_STATUS.

  data(lt_parmbind) = value abap_parmbind_tab(
    ( name = 'CHANGE_STATUS' kind = '0' value = ref #( CHANGE_STATUS ) )
    ( name = 'CHANGE_STATUS_RESPONSE' kind = '1' value = ref #(
 CHANGE_STATUS_RESPONSE ) )
  ).
  if_proxy_client~execute(
    exporting
      method_name = 'CHANGE_STATUS'
    changing
      parmbind_tab = lt_parmbind
  ).

  endmethod.


  method CONSTRUCTOR.

  super->constructor(
    class_name          = 'ZAWP_CO_AWP_WEB_SERVICE'
    logical_port_name   = logical_port_name
    destination         = destination
  ).

  endmethod.


  method QUERY_AWP.

  data(lt_parmbind) = value abap_parmbind_tab(
    ( name = 'QUERY_AWP' kind = '0' value = ref #( QUERY_AWP ) )
    ( name = 'QUERY_AWP_RESPONSE' kind = '1' value = ref #(
 QUERY_AWP_RESPONSE ) )
  ).
  if_proxy_client~execute(
    exporting
      method_name = 'QUERY_AWP'
    changing
      parmbind_tab = lt_parmbind
  ).

  endmethod.


  method QUERY_AWP_BY_ID.

  data(lt_parmbind) = value abap_parmbind_tab(
    ( name = 'QUERY_AWP_BY_ID' kind = '0' value = ref #( QUERY_AWP_BY_ID
 ) )
    ( name = 'QUERY_AWP_BY_ID_RESPONSE' kind = '1' value = ref #(
 QUERY_AWP_BY_ID_RESPONSE ) )
  ).
  if_proxy_client~execute(
    exporting
      method_name = 'QUERY_AWP_BY_ID'
    changing
      parmbind_tab = lt_parmbind
  ).

  endmethod.


  method QUERY_AWP_ERROR_BY_ID.

  data(lt_parmbind) = value abap_parmbind_tab(
    ( name = 'QUERY_AWP_ERROR_BY_ID' kind = '0' value = ref #(
 QUERY_AWP_ERROR_BY_ID ) )
    ( name = 'QUERY_AWP_ERROR_BY_ID_RESPONSE' kind = '1' value = ref #(
 QUERY_AWP_ERROR_BY_ID_RESPONSE ) )
  ).
  if_proxy_client~execute(
    exporting
      method_name = 'QUERY_AWP_ERROR_BY_ID'
    changing
      parmbind_tab = lt_parmbind
  ).

  endmethod.


  method QUERY_AWP_HISTORY_BY_ID.

  data(lt_parmbind) = value abap_parmbind_tab(
    ( name = 'QUERY_AWP_HISTORY_BY_ID' kind = '0' value = ref #(
 QUERY_AWP_HISTORY_BY_ID ) )
    ( name = 'QUERY_AWP_HISTORY_BY_ID_RESPON' kind = '1' value = ref #(
 QUERY_AWP_HISTORY_BY_ID_RESPON ) )
  ).
  if_proxy_client~execute(
    exporting
      method_name = 'QUERY_AWP_HISTORY_BY_ID'
    changing
      parmbind_tab = lt_parmbind
  ).

  endmethod.


  method QUERY_AWP_STATUS_BY_ID.

  data(lt_parmbind) = value abap_parmbind_tab(
    ( name = 'QUERY_AWP_STATUS_BY_ID' kind = '0' value = ref #(
 QUERY_AWP_STATUS_BY_ID ) )
    ( name = 'QUERY_AWP_STATUS_BY_ID_RESPONS' kind = '1' value = ref #(
 QUERY_AWP_STATUS_BY_ID_RESPONS ) )
  ).
  if_proxy_client~execute(
    exporting
      method_name = 'QUERY_AWP_STATUS_BY_ID'
    changing
      parmbind_tab = lt_parmbind
  ).

  endmethod.


  method QUERY_DELETE_AWP.

  data(lt_parmbind) = value abap_parmbind_tab(
    ( name = 'QUERY_DELETE_AWP' kind = '0' value = ref #(
 QUERY_DELETE_AWP ) )
    ( name = 'QUERY_DELETE_AWP_RESPONSE' kind = '1' value = ref #(
 QUERY_DELETE_AWP_RESPONSE ) )
  ).
  if_proxy_client~execute(
    exporting
      method_name = 'QUERY_DELETE_AWP'
    changing
      parmbind_tab = lt_parmbind
  ).

  endmethod.


  method QUERY_UPDATE.

  data(lt_parmbind) = value abap_parmbind_tab(
    ( name = 'QUERY_UPDATE' kind = '0' value = ref #( QUERY_UPDATE ) )
    ( name = 'QUERY_UPDATE_RESPONSE' kind = '1' value = ref #(
 QUERY_UPDATE_RESPONSE ) )
  ).
  if_proxy_client~execute(
    exporting
      method_name = 'QUERY_UPDATE'
    changing
      parmbind_tab = lt_parmbind
  ).

  endmethod.


  method QUERY_VIEW_AWP.

  data(lt_parmbind) = value abap_parmbind_tab(
    ( name = 'QUERY_VIEW_AWP' kind = '0' value = ref #( QUERY_VIEW_AWP )
 )
    ( name = 'QUERY_VIEW_AWP_RESPONSE' kind = '1' value = ref #(
 QUERY_VIEW_AWP_RESPONSE ) )
  ).
  if_proxy_client~execute(
    exporting
      method_name = 'QUERY_VIEW_AWP'
    changing
      parmbind_tab = lt_parmbind
  ).

  endmethod.


  method UPLOAD_AWP.

  data(lt_parmbind) = value abap_parmbind_tab(
    ( name = 'UPLOAD_AWP' kind = '0' value = ref #( UPLOAD_AWP ) )
    ( name = 'UPLOAD_AWP_RESPONSE' kind = '1' value = ref #(
 UPLOAD_AWP_RESPONSE ) )
  ).
  if_proxy_client~execute(
    exporting
      method_name = 'UPLOAD_AWP'
    changing
      parmbind_tab = lt_parmbind
  ).

  endmethod.
ENDCLASS.
