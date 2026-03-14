node UserProfile {
    has name: str = "";
    has language: str = "English";
    has cultural_background: str = "";
    has provider_id: str = "";
    has onboarded: bool = False;
}

node LabReport {
    has raw_text: str = "";
    has flagged_values: list = [];
    has suggestions: str = "";
    has patient_name: str = "";
    has patient_language: str = "English";
}

node AppointmentCalendar {
    has upcoming: list = [
        "Tuesday Mar 18 — Dr. Patel 10:00 AM",
        "Friday Mar 21 — Lab Follow-up 2:00 PM"
    ];
    has pending_request: str = "";
}

node ProviderDashboard {
    has alerts: list = [];
}