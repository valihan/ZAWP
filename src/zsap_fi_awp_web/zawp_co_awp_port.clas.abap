class ZAWP_CO_AWP_PORT definition
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
  methods OP
    importing
      !INPUT type ZAWP_MSG_IN
    raising
      CX_AI_SYSTEM_FAULT .
protected section.
private section.
ENDCLASS.



CLASS ZAWP_CO_AWP_PORT IMPLEMENTATION.


  method CONSTRUCTOR.

  super->constructor(
    class_name          = 'ZAWP_CO_AWP_PORT'
    logical_port_name   = logical_port_name
    destination         = destination
  ).

  endmethod.


  method OP.

  data(lt_parmbind) = value abap_parmbind_tab(
    ( name = 'INPUT' kind = '0' value = ref #( INPUT ) )
  ).
  if_proxy_client~execute(
    exporting
      method_name = 'OP'
    changing
      parmbind_tab = lt_parmbind
  ).

  endmethod.
ENDCLASS.
