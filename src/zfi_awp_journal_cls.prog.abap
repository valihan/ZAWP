*&---------------------------------------------------------------------*
*& Include          ZFI_AWP_JOURNAL_CLS
*&---------------------------------------------------------------------*

CLASS lcl_main DEFINITION.
  PUBLIC SECTION.
    METHODS:
      added_function FOR EVENT added_function OF cl_salv_events_table IMPORTING e_salv_function,
      double_click FOR EVENT double_click OF cl_salv_events_table IMPORTING row column,
      on_link_click FOR EVENT link_click OF cl_salv_events_table IMPORTING row column,
      main.

  PRIVATE SECTION.
    CONSTANTS sc_limit TYPE i VALUE 100.
    DATA mv_session_id TYPE string.
    DATA mv_tin TYPE string.
    DATA mo_log TYPE REF TO zif_bal_log.
    DATA mo_service TYPE REF TO zawp_co_awp_web_service.
    DATA mo_transit TYPE REF TO if_fikz_di_transit.
    DATA mo_helper TYPE REF TO cl_fikz_di_helper.
    DATA mo_selections TYPE REF TO cl_salv_selections.

    TYPES: BEGIN OF ts_data,
             awp_id                TYPE zawp_awp_info-awp_id,
             registration_number   TYPE char40,
             input_date            TYPE datum,
             status                TYPE zawp_awp_info-status,
             operator_full_name    TYPE char40,
             sender_signer_name    TYPE char40,
             recipient_signer_name TYPE char40,
*             creator_login                  TYPE string,
             rejection_reason      TYPE char40,
             revoke_reason         TYPE char40,
*             dissolution_reason             TYPE string,
*             rejection_of_dissolution_reaso TYPE string,
             last_update_date      TYPE datum,

             number                TYPE char10,
             sender_tin            TYPE char16,
             sender_name           TYPE char40,
             total_sum_with_tax    TYPE char16,
             total_sum_without_tax TYPE char16,
             total_turnover_size   TYPE char16,
             total_nds_amount      TYPE char16,
             currency_code         TYPE char4,
           END OF ts_data.
    DATA mt_awp TYPE STANDARD TABLE OF zawp_awp_info WITH NON-UNIQUE SORTED KEY awp_id COMPONENTS awp_id.
    DATA mt_data TYPE STANDARD TABLE OF ts_data WITH NON-UNIQUE SORTED KEY awp_id COMPONENTS awp_id.
    METHODS:
      sign IMPORTING iv_xml TYPE string RETURNING VALUE(rs_signature) TYPE zawp_generate_document_signatu RAISING zawp_cx_business_exception,
      close_session,
      get_session RETURNING VALUE(rv_session_id) TYPE string RAISING zawp_cx_business_exception,
      confirm IMPORTING it_rows TYPE salv_t_row RAISING zawp_cx_business_exception,
      parse_xml IMPORTING iv_xml TYPE string RETURNING VALUE(rs_awp) TYPE zawp_awp_v1 RAISING zawp_cx_business_exception,
      get_datum IMPORTING iv_ts TYPE xsddatetime_z RETURNING VALUE(rv_date) TYPE datum,
      get_awp RAISING zawp_cx_business_exception,
      display_alv.
ENDCLASS.

CLASS lcl_main IMPLEMENTATION.
  METHOD main.
    SELECT SINGLE paval FROM t001z INTO mv_tin WHERE bukrs = p_bukrs AND party = 'SAPK34'.

    mo_log = zcl_bal_log=>get_instance( iv_object    = 'APPL_LOG'
                                        iv_subobject = 'OTHERS' ).
    mo_transit = NEW cl_fikz_di_transit( ).

    TRY.
        mo_service = NEW zawp_co_awp_web_service( ).
        mo_helper  = NEW cl_fikz_di_helper( ).
        get_awp( ).
        display_alv( ).
      CATCH cx_static_check cx_dynamic_check INTO DATA(lx_error).
        close_session( ).
        mo_log->add_exception( lx_error ).
    ENDTRY.

    IF NOT mo_log->is_empty( ).
      mo_log->show( ).
    ENDIF.
  ENDMETHOD.

  METHOD get_awp.
    DATA: lv_last_id    TYPE string,
          lv_limit      TYPE int4,
          lv_last_block TYPE xsdboolean.
    TRY.
        cl_bs_soa_convert_xsddatetime=>map_xsddatetime_z_out( EXPORTING iv_date = so_date-low
                                                                        iv_time = '000000'
                                                                        iv_timezone = sy-zonlo
                                                              IMPORTING ev_xsd_datetime = DATA(lv_last_event_date) ).
      CATCH cx_bs_soa_exception INTO DATA(lx_soa).
        RAISE EXCEPTION TYPE zawp_cx_business_exception EXPORTING previous = lx_soa.
    ENDTRY.
    lv_last_id = 0.
    lv_last_block = abap_false.
    DATA(lv_ind) = 1.

    WHILE lv_last_block = abap_false AND lv_ind > 0.
      TRY.
          mo_service->query_update( EXPORTING query_update = VALUE #( awp_query_updates_request =
                                                VALUE #( base            = VALUE #( session_id = get_session( ) )
                                                         last_awp_id     = lv_last_id
                                                         last_event_date = lv_last_event_date
                                                         limit           = sc_limit ) )
                                    IMPORTING query_update_response = DATA(ls_response) ).
        CATCH zawp_cx_trusty_ocspnot_availab zawp_cx_access_denied_exceptio zawp_cx_business_exception zawp_cx_trusty_ocspunknown_pro
              zawp_cx_trusty_ocspnonce_excep zawp_cx_trusty_ocspcertificate zawp_cx_session_closed_excepti
              cx_ai_system_fault
          INTO DATA(lx_proxy).
          mo_log->add_exception( lx_proxy ).
      ENDTRY.
      lv_last_id         = ls_response-awp_query_updates_response-last_awp_id.
      lv_last_event_date = ls_response-awp_query_updates_response-last_event_date.
      lv_ind             = lines( ls_response-awp_query_updates_response-awp_info_list-awp_info ).
      IF lv_ind IS NOT INITIAL.
        INSERT LINES OF ls_response-awp_query_updates_response-awp_info_list-awp_info INTO TABLE mt_awp.
      ENDIF.
    ENDWHILE.
    close_session( ).

    LOOP AT mt_awp ASSIGNING FIELD-SYMBOL(<ls_awp>).
      CHECK get_datum( <ls_awp>-last_update_date ) IN so_date.
      DATA(ls_awp) = parse_xml( <ls_awp>-awp_body ).

      APPEND VALUE #(
             awp_id                         = <ls_awp>-awp_id
             registration_number            = <ls_awp>-registration_number
             input_date                     = get_datum( <ls_awp>-input_date )
             status                         = <ls_awp>-status
             operator_full_name             = <ls_awp>-operator_full_name
             sender_signer_name             = <ls_awp>-sender_signer_name
             recipient_signer_name          = <ls_awp>-recipient_signer_name
*             creator_login                  = <ls_awp>-creator_login
             rejection_reason               = <ls_awp>-rejection_reason
             revoke_reason                  = <ls_awp>-revoke_reason
*             dissolution_reason             = <ls_awp>-dissolution_reason
*             rejection_of_dissolution_reaso = <ls_awp>-rejection_of_dissolution_reaso
             last_update_date               = get_datum( <ls_awp>-last_update_date )

             number                         = ls_awp-number
             sender_tin                     = VALUE #( ls_awp-senders-sender[ 1 ]-tin OPTIONAL )
             sender_name                    = VALUE #( ls_awp-senders-sender[ 1 ]-tin OPTIONAL )
             total_sum_with_tax             = ls_awp-works_performed-total_sum_with_tax
             total_sum_without_tax          = ls_awp-works_performed-total_sum_without_tax
             total_turnover_size            = ls_awp-works_performed-total_turnover_size
             total_nds_amount               = ls_awp-works_performed-total_nds_amount
             currency_code                  = ls_awp-works_performed-currency_code
      ) TO mt_data.
    ENDLOOP.

*    mt_data = VALUE #( FOR ls_awp IN mt_awp
*                       (
*             awp_id                         = ls_awp-awp_id
*             registration_number            = ls_awp-registration_number
*             input_date                     = get_datum( ls_awp-input_date )
*             status                         = ls_awp-status
*             operator_full_name             = ls_awp-operator_full_name
*             sender_signer_name             = ls_awp-sender_signer_name
*             recipient_signer_name          = ls_awp-recipient_signer_name
**             creator_login                  = ls_awp-creator_login
*             rejection_reason               = ls_awp-rejection_reason
*             revoke_reason                  = ls_awp-revoke_reason
**             dissolution_reason             = ls_awp-dissolution_reason
**             rejection_of_dissolution_reaso = ls_awp-rejection_of_dissolution_reaso
*             last_update_date               = get_datum( ls_awp-last_update_date )
*             ) ).
*    DELETE mt_data WHERE NOT last_update_date IN so_date.
  ENDMETHOD.

  METHOD get_session.
    IF mv_session_id IS NOT INITIAL.
      rv_session_id = mv_session_id.
      RETURN.
    ENDIF.

    TRY.
        mo_transit->create_session( EXPORTING iv_tin              = mv_tin "mo_helper->get_user_iin( )
                                              iv_certificate      = mo_helper->if_fikz_di_helper~get_sign_x509_base64_cert( )
                                              iv_lp_name          = mo_helper->if_fikz_di_helper~get_logical_port( )
                                              iv_message_category = j3rdx_logmessage_incoming
                                              iv_auth_lp_name     = mo_helper->get_auth_logical_port( )
                                              iv_cert_type        = cl_fikz_di_helper=>gcs_cert_type-gost
                                    IMPORTING ev_session_id       = mv_session_id
                                              et_message          = DATA(lt_message)
                                              es_session_request  = DATA(ls_session_request) ).
      CATCH cx_fikz_di_session_error cx_fikz_di_transport_error INTO DATA(lx_fikz).
        RAISE EXCEPTION TYPE zawp_cx_business_exception EXPORTING previous = lx_fikz.
    ENDTRY.
    rv_session_id = mv_session_id.
  ENDMETHOD.

  METHOD close_session.
    IF mv_session_id IS INITIAL.
      RETURN.
    ENDIF.

    TRY.
        mo_transit->close_session( EXPORTING iv_session_id  = mv_session_id
                                             iv_tin         = mo_helper->get_user_iin( )
                                             iv_certificate = mo_helper->if_fikz_di_helper~get_sign_x509_base64_cert( )
                                             iv_lp_name     = mo_helper->if_fikz_di_helper~get_logical_port( )
                                             is_session_request = VALUE #( )
                                             ).
        CLEAR mv_session_id.
      CATCH cx_ai_system_fault INTO DATA(lx_proxy).
        mo_log->add_exception( lx_proxy ).
    ENDTRY.
  ENDMETHOD.

  METHOD display_alv.
    TRY.
        cl_salv_table=>factory( IMPORTING r_salv_table = DATA(lo_salv)
                                CHANGING t_table = mt_data ).
        DATA(lo_columns) = lo_salv->get_columns( ).
        lo_columns->get_column( 'AWP_ID' )->set_short_text( 'ID' ).
        lo_columns->get_column( 'AWP_ID' )->set_medium_text( 'ID' ).
        lo_columns->get_column( 'AWP_ID' )->set_long_text( 'ID' ).

        lo_columns->get_column( 'INPUT_DATE' )->set_short_text( 'Дата' ).
        lo_columns->get_column( 'INPUT_DATE' )->set_medium_text( 'Дата' ).
        lo_columns->get_column( 'INPUT_DATE' )->set_long_text( 'Дата' ).

        lo_columns->get_column( 'REGISTRATION_NUMBER' )->set_short_text( 'РегНомер' ).
        lo_columns->get_column( 'REGISTRATION_NUMBER' )->set_medium_text( 'РегНомер' ).
        lo_columns->get_column( 'REGISTRATION_NUMBER' )->set_long_text( 'РегНомер' ).

        lo_columns->get_column( 'STATUS' )->set_short_text( 'Статус' ).
        lo_columns->get_column( 'STATUS' )->set_medium_text( 'Статус' ).
        lo_columns->get_column( 'STATUS' )->set_long_text( 'Статус' ).

        lo_columns->get_column( 'OPERATOR_FULL_NAME' )->set_short_text( 'Оператор' ).
        lo_columns->get_column( 'OPERATOR_FULL_NAME' )->set_medium_text( 'ФИО оператора' ).
        lo_columns->get_column( 'OPERATOR_FULL_NAME' )->set_long_text( 'ФИО оператора отправившего АВР' ).

        lo_columns->get_column( 'SENDER_SIGNER_NAME' )->set_short_text( 'Должность' ).
        lo_columns->get_column( 'SENDER_SIGNER_NAME' )->set_medium_text( 'Должность сдавшего' ).
        lo_columns->get_column( 'SENDER_SIGNER_NAME' )->set_long_text( 'Должность сдавшего' ).

        lo_columns->get_column( 'RECIPIENT_SIGNER_NAME' )->set_short_text( 'ДолжПрин' ).
        lo_columns->get_column( 'RECIPIENT_SIGNER_NAME' )->set_medium_text( 'Долж. принимающего' ).
        lo_columns->get_column( 'RECIPIENT_SIGNER_NAME' )->set_long_text( 'Должность принимающего АВР' ).

        lo_columns->get_column( 'REJECTION_REASON' )->set_short_text( 'Причина' ).
        lo_columns->get_column( 'REJECTION_REASON' )->set_medium_text( 'Причина отклонения' ).
        lo_columns->get_column( 'REJECTION_REASON' )->set_long_text( 'Причина отклонения' ).

        lo_columns->get_column( 'REVOKE_REASON' )->set_short_text( 'ПричОтзыв' ).
        lo_columns->get_column( 'REVOKE_REASON' )->set_medium_text( 'Причина отзыва' ).
        lo_columns->get_column( 'REVOKE_REASON' )->set_long_text( 'Причина отзыва' ).

        lo_columns->get_column( 'NUMBER' )->set_short_text( 'Номер' ).
        lo_columns->get_column( 'NUMBER' )->set_medium_text( 'Номер' ).
        lo_columns->get_column( 'NUMBER' )->set_long_text( 'Номер' ).

        lo_columns->get_column( 'SENDER_TIN' )->set_short_text( 'БИН исп' ).
        lo_columns->get_column( 'SENDER_TIN' )->set_medium_text( 'БИН исполнителя' ).
        lo_columns->get_column( 'SENDER_TIN' )->set_long_text( 'БИН исполнителя' ).

        lo_columns->get_column( 'SENDER_NAME' )->set_short_text( 'Исполнит' ).
        lo_columns->get_column( 'SENDER_NAME' )->set_medium_text( 'Исполнитель' ).
        lo_columns->get_column( 'SENDER_NAME' )->set_long_text( 'Исполнитель' ).

        lo_columns->get_column( 'TOTAL_SUM_WITH_TAX' )->set_short_text( 'Сум с НДС' ).
        lo_columns->get_column( 'TOTAL_SUM_WITH_TAX' )->set_medium_text( 'Сумма с НДС' ).
        lo_columns->get_column( 'TOTAL_SUM_WITH_TAX' )->set_long_text( 'Сумма с НДС' ).

        lo_columns->get_column( 'TOTAL_SUM_WITHOUT_TAX' )->set_short_text( 'Сум бНДС' ).
        lo_columns->get_column( 'TOTAL_SUM_WITHOUT_TAX' )->set_medium_text( 'Сумма без НДС' ).
        lo_columns->get_column( 'TOTAL_SUM_WITHOUT_TAX' )->set_long_text( 'Сумма без НДС' ).

        lo_columns->get_column( 'TOTAL_TURNOVER_SIZE' )->set_short_text( 'Оборот' ).
        lo_columns->get_column( 'TOTAL_TURNOVER_SIZE' )->set_medium_text( 'Итоговый оборот' ).
        lo_columns->get_column( 'TOTAL_TURNOVER_SIZE' )->set_long_text( 'Итоговый размер оборота по реализации' ).

        lo_columns->get_column( 'TOTAL_NDS_AMOUNT' )->set_short_text( 'НДС' ).
        lo_columns->get_column( 'TOTAL_NDS_AMOUNT' )->set_medium_text( 'НДС' ).
        lo_columns->get_column( 'TOTAL_NDS_AMOUNT' )->set_long_text( 'НДС' ).


        lo_columns->get_column( 'CURRENCY_CODE' )->set_short_text( 'НДС' ).
        lo_columns->get_column( 'CURRENCY_CODE' )->set_medium_text( 'НДС' ).
        lo_columns->get_column( 'CURRENCY_CODE' )->set_long_text( 'НДС' ).

        lo_columns->set_optimize( abap_true ).

        lo_salv->set_screen_status( pfstatus = 'STANDARD'
                                    report   = sy-repid ).
        mo_selections = lo_salv->get_selections( ).
        mo_selections->set_selection_mode( if_salv_c_selection_mode=>row_column ).
        DATA(lo_events) = lo_salv->get_event( ).
        SET HANDLER added_function FOR lo_events.
*        SET HANDLER double_click FOR lo_events.
*        SET HANDLER on_link_click FOR lo_events.

        lo_salv->get_functions( )->set_all( ).
        lo_salv->display( ).
      CATCH cx_salv_msg cx_salv_not_found.
        MESSAGE 'Can''t show ALV' TYPE 'E'.
    ENDTRY.
  ENDMETHOD.

  METHOD get_datum.
    TRY.
        cl_bs_soa_convert_xsddatetime=>map_xsddatetime_z_in( EXPORTING iv_timezone     = sy-zonlo
                                                                       iv_xsd_datetime = iv_ts
                                                             IMPORTING ev_date         = rv_date ).
      CATCH cx_bs_soa_exception.
    ENDTRY.
  ENDMETHOD.

  METHOD added_function.
    CHECK e_salv_function = 'CONFIRM'.

    DATA(lt_rows) = mo_selections->get_selected_rows( ).
    IF lt_rows IS INITIAL.
      MESSAGE s000(00) WITH 'Выберите строки'.
      RETURN.
    ENDIF.
    confirm( lt_rows ).
  ENDMETHOD.

  METHOD double_click.
*    MESSAGE s001(00) WITH row '/' column DISPLAY LIKE 'i'.
*
*    READ TABLE mt_data ASSIGNING FIELD-SYMBOL(<ls_data>) INDEX row.
*    CHECK sy-subrc = 0.
*
*    ASSIGN mt_awp[ awp_id = <ls_data>-awp_id ] TO FIELD-SYMBOL(<ls_awp>).
*    CHECK sy-subrc = 0.

  ENDMETHOD.

  METHOD on_link_click.
*    CHECK mt_data IS NOT INITIAL.
  ENDMETHOD.

  METHOD parse_xml.
    DATA lv_xstring TYPE xstring.
    CALL FUNCTION 'ECATT_CONV_STRING_TO_XSTRING'
      EXPORTING
        im_string  = iv_xml
      IMPORTING
        ex_xstring = lv_xstring.

    DATA ls_awp TYPE zawp_awp_v1.
    TRY.
        cl_proxy_xml_transform=>xml_to_abap( EXPORTING xml_reader   = cl_sxml_string_reader=>create( lv_xstring )
                                                       ddic_type    = 'ZAWP_AWP_V1'
                                             IMPORTING abap_data    = rs_awp ).
      CATCH cx_proxy_fault INTO DATA(lx_error).
        mo_log->add_exception( lx_error ).
    ENDTRY.
  ENDMETHOD.

  METHOD confirm.
    DATA lt_action TYPE zawp_awp_action_info_tab.
    TRY.
*        mo_service->query_awp_by_id( EXPORTING query_awp_by_id = VALUE #( awp_query_by_id_request =
*                                                 VALUE #( base = VALUE #( session_id = get_session( ) )
*                                                          id_list = VALUE #( id = VALUE #( FOR lv_row IN it_rows
*                                                                                           ( mt_data[ lv_row ]-awp_id )
*                                                                                           ) ) ) )
*                                     IMPORTING query_awp_by_id_response = DATA(ls_query_awp_response) ).

        mo_service->query_view_awp( EXPORTING query_view_awp = VALUE #( awp_view_request =
                                                 VALUE #( BASE = VALUE #( session_id = get_session( ) )
                                                          id_list = VALUE #( id = VALUE #( FOR lv_row IN it_rows
                                                                                           ( mt_data[ lv_row ]-awp_id )
                                                                                           ) ) ) )
                                     IMPORTING query_view_awp_response = DATA(ls_query_view) ).

        LOOP AT it_rows ASSIGNING FIELD-SYMBOL(<lv_row_index>).
          READ TABLE mt_data INDEX <lv_row_index> ASSIGNING FIELD-SYMBOL(<ls_row>).
          CHECK sy-subrc = 0.

          IF <ls_row>-status = 'NOT_VIEWED' OR <ls_row>-status = 'DELIVERED'.

            APPEND INITIAL LINE TO lt_action ASSIGNING FIELD-SYMBOL(<ls_action>).
            DATA lv_xml TYPE string.
            lv_xml =
'<v1:awpAction xmlns:aawp="abstractAwp.awp" xmlns:v1="v1.awp">' &&
|<awpId>{ <ls_row>-awp_id }</awpId>| &&
'<actionType>CONFIRM</actionType><cause></cause>' &&
'<originalDocumentSignature>' &&
VALUE #( mt_awp[ KEY awp_id awp_id = <ls_row>-awp_id ]-signature OPTIONAL ) &&
'</originalDocumentSignature><cause> </cause></v1:awpAction>'.

            DATA(ls_sign) = sign( lv_xml ).
            <ls_action> = VALUE #( awp_action_body       = lv_xml
                                   awp_id                = <ls_row>-awp_id
                                   awp_version           = 'AwpV1'
                                   certificate           = mo_helper->if_fikz_di_helper~get_sign_x509_base64_cert( )
                                   signature             = ls_sign-document_signature_response-signature
                                   signature_type        = 'OPERATOR'
                                   recipient_signer_name = 'Старший бухгалтер' ).
          ENDIF.
        ENDLOOP.

        IF lt_action IS NOT INITIAL.
          mo_service->change_status( EXPORTING change_status = VALUE #( awp_change_status_request =
                                                 VALUE #( base = VALUE #( session_id = get_session( ) )
                                                          awp_action_info_list = VALUE #( awp_action_info = lt_action ) ) )
                                     IMPORTING change_status_response = DATA(ls_response)
             ).
        ENDIF.
      CATCH cx_ai_system_fault zawp_cx_access_denied_exceptio zawp_cx_business_exception zawp_cx_session_closed_excepti
        INTO DATA(lx_error).
        mo_log->add_exception( lx_error ).
    ENDTRY.
    close_session( ).
  ENDMETHOD.

  METHOD sign.
    TRY.
        SELECT SINGLE * FROM fikz_di_cust WHERE sap_user_name = @sy-uname INTO @DATA(ls_cust).
        DATA(lo_sign) = NEW zawp_co_local_service( ).
        DATA(lv_pin) = lcl_transit=>get_pin( CAST #( mo_transit ) ).
        lo_sign->generate_document_signature(
          EXPORTING
            generate_document_signature = VALUE #( document_signature_request =
              VALUE #( certificate_path = ls_cust-certificate_path
                       certificate_pin  = lv_pin
                       signable_data    = iv_xml ) )
          IMPORTING
            generate_document_signature_re = rs_signature
                       ).
      CATCH cx_ai_system_fault INTO DATA(lx_error).
        RAISE EXCEPTION TYPE zawp_cx_business_exception EXPORTING previous = lx_error.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
