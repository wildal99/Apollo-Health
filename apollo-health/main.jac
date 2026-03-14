import:jac from modules.alissaAIAgent {
    HealthBridgeAgent,
    UserProfile,
    LabReport,
    MedicalRecordUpload,
    AppointmentCalendar,
    ProviderDashboard
}
import:jac from api {
    onboard_patient,
    analyze_lab_report,
    upload_medical_record,
    get_appointments,
    get_provider_alerts
}

with entry {
    profile = [-->](?:UserProfile);
    if not profile {
        root ++> UserProfile();
        lab     = root ++> LabReport();
        records = root ++> MedicalRecordUpload();
        root ++> AppointmentCalendar();
        dashboard = root ++> ProviderDashboard();
        lab ++> dashboard;
        records ++> dashboard;
    }
    print("========================================");
    print("  HealthBridge Backend is LIVE");
    print("  Endpoints ready:");
    print("  POST /walker/onboard_patient");
    print("  POST /walker/analyze_lab_report");
    print("  POST /walker/upload_medical_record");
    print("  POST /walker/get_appointments");
    print("  POST /walker/get_provider_alerts");
    print("========================================");
}