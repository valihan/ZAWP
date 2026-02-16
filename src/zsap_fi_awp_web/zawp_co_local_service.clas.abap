class ZAWP_CO_LOCAL_SERVICE definition
  public
  inheriting from CL_PROXY_CLIENT
  create public .

public section.

  methods CONSTRUCTOR
    importing
      !DESTINATION type ref to IF_PROXY_DESTINATION optional
      !LOGICAL_PORT_NAME type PRX_LOGICAL_PORT_NAME optional
    preferred parameter LOGICAL_PORT_NAME
    raising
      CX_AI_SYSTEM_FAULT .
  methods GENERATE_DOCUMENT_SIGNATURE
    importing
      !GENERATE_DOCUMENT_SIGNATURE type ZAWP_GENERATE_DOCUMENT_SIGNAT1
    exporting
      !GENERATE_DOCUMENT_SIGNATURE_RE type ZAWP_GENERATE_DOCUMENT_SIGNATU
    raising
      CX_AI_SYSTEM_FAULT .
  methods GENERATE_DOCUMENT_XML_SIGNATUR
    importing
      !GENERATE_DOCUMENT_XML_SIGNATU1 type ZAWP_GENERATE_DOCUMENT_XML_SI1
    exporting
      !GENERATE_DOCUMENT_XML_SIGNATUR type ZAWP_GENERATE_DOCUMENT_XML_SIG
    raising
      CX_AI_SYSTEM_FAULT .
  methods GENERATE_SIGNATURE
    importing
      !GENERATE_SIGNATURE type ZAWP_GENERATE_SIGNATURE
    exporting
      !GENERATE_SIGNATURE_RESPONSE type ZAWP_GENERATE_SIGNATURE_RESPON
    raising
      CX_AI_SYSTEM_FAULT .
  methods SIGN_ID_LIST
    importing
      !SIGN_ID_LIST type ZAWP_SIGN_ID_LIST
    exporting
      !SIGN_ID_LIST_RESPONSE type ZAWP_SIGN_ID_LIST_RESPONSE
    raising
      CX_AI_SYSTEM_FAULT .
  methods SIGN_ID_WITH_REASON_LIST
    importing
      !SIGN_ID_WITH_REASON_LIST type ZAWP_SIGN_ID_WITH_REASON_LIST1
    exporting
      !SIGN_ID_WITH_REASON_LIST_RESPO type ZAWP_SIGN_ID_WITH_REASON_LIST
    raising
      CX_AI_SYSTEM_FAULT .
protected section.
private section.
ENDCLASS.



CLASS ZAWP_CO_LOCAL_SERVICE IMPLEMENTATION.


  method CONSTRUCTOR.

  super->constructor(
    class_name          = 'ZAWP_CO_LOCAL_SERVICE'
    logical_port_name   = logical_port_name
    destination         = destination
  ).

  endmethod.


  method GENERATE_DOCUMENT_SIGNATURE.

  data(lt_parmbind) = value abap_parmbind_tab(
    ( name = 'GENERATE_DOCUMENT_SIGNATURE' kind = '0' value = ref #(
 GENERATE_DOCUMENT_SIGNATURE ) )
    ( name = 'GENERATE_DOCUMENT_SIGNATURE_RE' kind = '1' value = ref #(
 GENERATE_DOCUMENT_SIGNATURE_RE ) )
  ).
  if_proxy_client~execute(
    exporting
      method_name = 'GENERATE_DOCUMENT_SIGNATURE'
    changing
      parmbind_tab = lt_parmbind
  ).

  endmethod.


  method GENERATE_DOCUMENT_XML_SIGNATUR.

  data(lt_parmbind) = value abap_parmbind_tab(
    ( name = 'GENERATE_DOCUMENT_XML_SIGNATU1' kind = '0' value = ref #(
 GENERATE_DOCUMENT_XML_SIGNATU1 ) )
    ( name = 'GENERATE_DOCUMENT_XML_SIGNATUR' kind = '1' value = ref #(
 GENERATE_DOCUMENT_XML_SIGNATUR ) )
  ).
  if_proxy_client~execute(
    exporting
      method_name = 'GENERATE_DOCUMENT_XML_SIGNATUR'
    changing
      parmbind_tab = lt_parmbind
  ).

  endmethod.


  method GENERATE_SIGNATURE.

  data(lt_parmbind) = value abap_parmbind_tab(
    ( name = 'GENERATE_SIGNATURE' kind = '0' value = ref #(
 GENERATE_SIGNATURE ) )
    ( name = 'GENERATE_SIGNATURE_RESPONSE' kind = '1' value = ref #(
 GENERATE_SIGNATURE_RESPONSE ) )
  ).
  if_proxy_client~execute(
    exporting
      method_name = 'GENERATE_SIGNATURE'
    changing
      parmbind_tab = lt_parmbind
  ).

  endmethod.


  method SIGN_ID_LIST.

  data(lt_parmbind) = value abap_parmbind_tab(
    ( name = 'SIGN_ID_LIST' kind = '0' value = ref #( SIGN_ID_LIST ) )
    ( name = 'SIGN_ID_LIST_RESPONSE' kind = '1' value = ref #(
 SIGN_ID_LIST_RESPONSE ) )
  ).
  if_proxy_client~execute(
    exporting
      method_name = 'SIGN_ID_LIST'
    changing
      parmbind_tab = lt_parmbind
  ).

  endmethod.


  method SIGN_ID_WITH_REASON_LIST.

  data(lt_parmbind) = value abap_parmbind_tab(
    ( name = 'SIGN_ID_WITH_REASON_LIST' kind = '0' value = ref #(
 SIGN_ID_WITH_REASON_LIST ) )
    ( name = 'SIGN_ID_WITH_REASON_LIST_RESPO' kind = '1' value = ref #(
 SIGN_ID_WITH_REASON_LIST_RESPO ) )
  ).
  if_proxy_client~execute(
    exporting
      method_name = 'SIGN_ID_WITH_REASON_LIST'
    changing
      parmbind_tab = lt_parmbind
  ).

  endmethod.
ENDCLASS.
