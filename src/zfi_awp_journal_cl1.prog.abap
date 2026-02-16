*&---------------------------------------------------------------------*
*& Include          ZFI_AWP_JOURNAL_CL1
*&---------------------------------------------------------------------*

CLASS lcl_transit DEFINITION
  INHERITING FROM cl_fikz_di_transit.
  PUBLIC SECTION.
    CLASS-METHODS
      get_pin IMPORTING io_transit    TYPE REF TO cl_fikz_di_transit
              RETURNING VALUE(rv_pin) TYPE string.
ENDCLASS.

CLASS lcl_transit IMPLEMENTATION.
  METHOD get_pin.
    rv_pin = io_transit->ca_pin.
  ENDMETHOD.
ENDCLASS.
