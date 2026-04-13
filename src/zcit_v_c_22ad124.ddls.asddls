@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Clinic Consumption View 22AD124'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZCIT_V_C_22AD124
  as projection on ZCIT_V_I_22AD124
{
  key AppointmentID,
      PatientName,
      DoctorSpecialty,
      AppointmentDate,
      AppointmentTime,
      @Semantics.amount.currencyCode: 'ClinicCurrency'
      ConsultingFee,
      ClinicCurrency
}
