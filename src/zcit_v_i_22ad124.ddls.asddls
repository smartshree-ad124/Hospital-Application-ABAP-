@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Clinic Interface View 22AD124'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZCIT_V_I_22AD124
  as select from zcit_hos_22ad124
{
  key app_id         as AppointmentID,
      patient_name   as PatientName,
      doc_specialist as DoctorSpecialty,
      visit_date     as AppointmentDate,
      visit_time     as AppointmentTime,
      @Semantics.amount.currencyCode: 'ClinicCurrency'
      consult_fee    as ConsultingFee,
      clinic_curr    as ClinicCurrency
}
