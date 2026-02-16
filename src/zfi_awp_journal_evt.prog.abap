*&---------------------------------------------------------------------*
*& Include          ZFI_AWP_JOURNAL_EVT
*&---------------------------------------------------------------------*

START-OF-SELECTION.
  DATA(lo_main) = NEW lcl_main( ).

END-OF-SELECTION.
  lo_main->main( ).
