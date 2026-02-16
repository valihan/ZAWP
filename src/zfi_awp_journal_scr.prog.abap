*&---------------------------------------------------------------------*
*& Include          ZFI_AWP_JOURNAL_SCR
*&---------------------------------------------------------------------*

DATA lv_date TYPE datum.
PARAMETERS p_bukrs TYPE bukrs MEMORY ID buk OBLIGATORY.
SELECT-OPTIONS so_date FOR lv_date NO-EXTENSION MEMORY ID DAT OBLIGATORY DEFAULT sy-datum.
