class AppStrings {
  AppStrings._();

  static const String appName    = 'MaternalCare Monitor';
  static const String appTagline = 'Improving maternal health outcomes in Rubare Town Council';

  // Auth
  static const String login           = 'Login';
  static const String register        = 'Register';
  static const String logout          = 'Logout';
  static const String username        = 'Username';
  static const String password        = 'Password';
  static const String confirmPassword = 'Confirm Password';
  static const String fullName        = 'Full Name';
  static const String role            = 'Role';
  static const String email           = 'Email';
  static const String firstUserAdmin  = 'The first registered user becomes Administrator.';
  static const String noAccount       = "Don't have an account?";
  static const String hasAccount      = 'Already have an account?';

  // Navigation
  static const String dashboard      = 'Dashboard';
  static const String patients       = 'Patients';
  static const String anc            = 'ANC Visits';
  static const String delivery       = 'Delivery';
  static const String postnatal      = 'Postnatal';
  static const String familyPlanning = 'Family Planning';
  static const String reports        = 'Reports';
  static const String settings       = 'Settings';

  // Dashboard
  static const String recentAlerts        = 'Recent Alerts';
  static const String totalPatients       = 'Total Patients';
  static const String ancVisitsThisMonth  = 'ANC Visits This Month';
  static const String deliveriesThisMonth = 'Deliveries This Month';
  static const String highRiskCases       = 'High-Risk Cases';

  // Patient form
  static const String addPatient    = 'Add Patient';
  static const String patientAdded  = 'Patient added successfully';
  static const String dateOfBirth   = 'Date of Birth';
  static const String contactNumber = 'Contact Number';
  static const String address       = 'Address';
  static const String nextOfKin     = 'Next of Kin';
  static const String lmpDate       = 'Last Menstrual Period (LMP)';

  // ANC
  static const String addAncVisit   = 'Add ANC Visit';
  static const String visitRecorded = 'Visit recorded successfully';
  static const String visitDate     = 'Visit Date';
  static const String bloodPressure = 'Blood Pressure (mmHg)';
  static const String weight        = 'Weight (kg)';
  static const String fetalHeartRate = 'Fetal Heart Rate (bpm)';
  static const String fundalHeight  = 'Fundal Height (cm)';
  static const String hbLevel       = 'Haemoglobin Level (g/dL)';
  static const String notes         = 'Notes';
  static const String nextVisitDate = 'Next Visit Date';

  // Delivery
  static const String addDelivery  = 'Add Delivery';
  static const String recordSaved  = 'Record saved successfully';
  static const String deliveryDate = 'Delivery Date';
  static const String birthWeight  = 'Birth Weight (kg)';
  static const String attendant    = 'Birth Attendant';
  static const String complications = 'Complications';

  // Postnatal
  static const String addPostnatal = 'Add Postnatal Visit';

  // Family Planning
  static const String contraceptiveMethod = 'Contraceptive Method';
  static const String serviceDate         = 'Service Date';

  // Reports
  static const String selectDateRange = 'Select Date Range';

  // Errors
  static const String fieldRequired      = 'This field is required';
  static const String passwordMismatch   = 'Passwords do not match';
  static const String invalidCredentials = 'Invalid username or password';
  static const String unknownError       = 'An unexpected error occurred';
}