CLASS lcl_buffer DEFINITION CREATE PRIVATE.
  PUBLIC SECTION.
    TYPES: BEGIN OF ty_buffer,
             flag    TYPE c LENGTH 1,
             lv_data TYPE ZCIT_HOS_22AD124,
           END OF ty_buffer.
    CLASS-DATA mt_buffer TYPE STANDARD TABLE OF ty_buffer WITH EMPTY KEY.
    CLASS-METHODS get_instance RETURNING VALUE(ro_instance) TYPE REF TO lcl_buffer.
    METHODS add_to_buffer IMPORTING iv_flag TYPE c is_hosp TYPE ZCIT_HOS_22AD124.
  PRIVATE SECTION.
    CLASS-DATA go_instance TYPE REF TO lcl_buffer.
ENDCLASS.

CLASS lcl_buffer IMPLEMENTATION.
  METHOD get_instance.
    IF go_instance IS NOT BOUND.
      go_instance = NEW #( ).
    ENDIF.
    ro_instance = go_instance.
  ENDMETHOD.

  METHOD add_to_buffer.
    INSERT VALUE ty_buffer( flag = iv_flag lv_data = is_hosp ) INTO TABLE mt_buffer.
  ENDMETHOD.
ENDCLASS.

CLASS lhc_Hospital DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Hospital RESULT result.
    METHODS create FOR MODIFY IMPORTING entities FOR CREATE Hospital.
    METHODS update FOR MODIFY IMPORTING entities FOR UPDATE Hospital.
    METHODS delete FOR MODIFY IMPORTING keys FOR DELETE Hospital.
    METHODS read FOR READ IMPORTING keys FOR READ Hospital RESULT result.
    METHODS lock FOR LOCK IMPORTING keys FOR LOCK Hospital.
ENDCLASS.

CLASS lhc_Hospital IMPLEMENTATION.
  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD create.
    DATA(lo_buffer) = lcl_buffer=>get_instance( ).
    LOOP AT entities ASSIGNING FIELD-SYMBOL(<ls_ent>).
      DATA ls_hosp TYPE ZCIT_HOS_22AD124.
      ls_hosp-app_id         = <ls_ent>-AppointmentID.
      ls_hosp-patient_name   = <ls_ent>-PatientName.
      ls_hosp-doc_specialist = <ls_ent>-DoctorSpecialty.
      ls_hosp-visit_date     = <ls_ent>-AppointmentDate.
      ls_hosp-visit_time     = <ls_ent>-AppointmentTime.
      ls_hosp-consult_fee    = <ls_ent>-ConsultingFee.
      ls_hosp-clinic_curr    = <ls_ent>-ClinicCurrency.

      lo_buffer->add_to_buffer( iv_flag = 'C' is_hosp = ls_hosp ).
      INSERT VALUE #( %cid = <ls_ent>-%cid AppointmentID = ls_hosp-app_id ) INTO TABLE mapped-hospital.
    ENDLOOP.
  ENDMETHOD.

  METHOD update.
    DATA(lo_buffer) = lcl_buffer=>get_instance( ).
    LOOP AT entities ASSIGNING FIELD-SYMBOL(<ls_ent>).
      DATA ls_db TYPE ZCIT_HOS_22AD124.
      SELECT SINGLE * FROM ZCIT_HOS_22AD124
        WHERE app_id = @<ls_ent>-AppointmentID
        INTO @ls_db.

      IF <ls_ent>-%control-PatientName = if_abap_behv=>mk-on.
        ls_db-patient_name = <ls_ent>-PatientName.
      ENDIF.

      IF <ls_ent>-%control-DoctorSpecialty = if_abap_behv=>mk-on.
        ls_db-doc_specialist = <ls_ent>-DoctorSpecialty.
      ENDIF.

      IF <ls_ent>-%control-AppointmentDate = if_abap_behv=>mk-on.
        ls_db-visit_date = <ls_ent>-AppointmentDate.
      ENDIF.

      lo_buffer->add_to_buffer( iv_flag = 'U' is_hosp = ls_db ).
      INSERT VALUE #( %cid = <ls_ent>-%cid_ref AppointmentID = ls_db-app_id ) INTO TABLE mapped-hospital.
    ENDLOOP.
  ENDMETHOD.

  METHOD delete.
    DATA(lo_buffer) = lcl_buffer=>get_instance( ).
    LOOP AT keys ASSIGNING FIELD-SYMBOL(<ls_key>).
      DATA ls_hosp_del TYPE ZCIT_HOS_22AD124.
      ls_hosp_del-app_id = <ls_key>-AppointmentID.
      lo_buffer->add_to_buffer( iv_flag = 'D' is_hosp = ls_hosp_del ).
    ENDLOOP.
  ENDMETHOD.

  METHOD read.
    SELECT app_id AS AppointmentID,
           patient_name AS PatientName,
           doc_specialist AS DoctorSpecialty,
           visit_date AS AppointmentDate,
           visit_time AS AppointmentTime,
           consult_fee AS ConsultingFee,
           clinic_curr AS ClinicCurrency
      FROM ZCIT_HOS_22AD124
      FOR ALL ENTRIES IN @keys
      WHERE app_id = @keys-AppointmentID
      INTO CORRESPONDING FIELDS OF TABLE @result.
  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.
ENDCLASS.

CLASS lsc_ZCIT_V_I_22AD124 DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS save REDEFINITION.
    METHODS finalize REDEFINITION.
    METHODS check_before_save REDEFINITION.
    METHODS adjust_numbers REDEFINITION.
    METHODS cleanup REDEFINITION.
    METHODS cleanup_finalize REDEFINITION.
ENDCLASS.

CLASS lsc_ZCIT_V_I_22AD124 IMPLEMENTATION.
  METHOD save.
    LOOP AT lcl_buffer=>mt_buffer ASSIGNING FIELD-SYMBOL(<ls_buf>).
      CASE <ls_buf>-flag.
        WHEN 'C'. INSERT ZCIT_HOS_22AD124 FROM @<ls_buf>-lv_data.
        WHEN 'U'. UPDATE ZCIT_HOS_22AD124 FROM @<ls_buf>-lv_data.
        WHEN 'D'. DELETE FROM ZCIT_HOS_22AD124 WHERE app_id = @<ls_buf>-lv_data-app_id.
      ENDCASE.
    ENDLOOP.
    CLEAR lcl_buffer=>mt_buffer.
  ENDMETHOD.

  METHOD finalize. ENDMETHOD.
  METHOD check_before_save. ENDMETHOD.
  METHOD adjust_numbers. ENDMETHOD.
  METHOD cleanup. ENDMETHOD.
  METHOD cleanup_finalize. ENDMETHOD.
ENDCLASS.
