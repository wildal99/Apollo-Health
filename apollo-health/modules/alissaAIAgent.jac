
import from byllm.lib { Model }

glob llm = Model(model_name="gpt-4o-mini");

node UserProfile {
    has name: str = "";
    has language: str = "English";
    has cultural_background: str = "";
    has provider_id: str = "";
}

node LabReport {
    has raw_text: str = "";
    has flagged_values: list = [];
    has suggestions: str = "";
    has patient_name: str = "";
    has patient_language: str = "English";
}

node AppointmentCalendar {
    has upcoming: list = [];
    has pending_request: str = "";
}

node ProviderDashboard {
    has alerts: list = [];
}

"""
You are onboarding a new patient onto a healthcare platform.
Given their name, preferred language, and cultural background,
return a warm personalized welcome message written entirely
in their preferred language. Be friendly and reassuring.
"""
def adapt_onboarding_message(name: str, language: str, background: str) -> str by llm();

"""
You are a medical data extraction assistant.
Given raw bloodwork text, extract ONLY the values that fall
outside the listed normal range.
Return a plain list of strings, one per abnormal value.
Format each as: "Test Name: value unit — HIGH" or "Test Name: value unit — LOW"
If all values are normal return an empty list.
"""
def extract_flagged_values(bloodwork_text: str) -> list by llm();

"""
You are a compassionate health advisor.
Given a list of flagged lab values and a language,
write a short plain-language explanation and supportive
suggestions for the patient. Write entirely in the specified language.
Avoid scary medical jargon. Keep it under 100 words.
"""
def generate_health_suggestions(flagged: list, language: str) -> str by llm();

"""
You are a clinical notification system.
Given a patient name and list of flagged lab values,
write a single concise alert for the provider dashboard.
Format: ALERT — [Name]: [flagged values summary]. Uploaded [time].
Use current time for the timestamp.
"""
def format_provider_alert(patient_name: str, flagged: list) -> str by llm();

"""
You are a scheduling assistant.
Given a list of upcoming appointments and a new appointment request,
confirm the request in a friendly one-sentence response
and include what was scheduled.
"""
def handle_appointment_request(upcoming: list, request: str) -> str by llm();

walker HealthBridgeAgent {
    has screen: str;
    has input_data: dict = {};
    has response: any = None;
    has _flagged: list = [];
    has _patient_name: str = "";
    has _patient_language: str = "English";

    can route with `root entry {
        if self.screen == "onboarding" {
            visit [-->](?:UserProfile);
        } elif self.screen == "lab_report" {
            visit [-->](?:LabReport);
        } elif self.screen == "appointment" {
            visit [-->](?:AppointmentCalendar);
        } elif self.screen == "provider" {
            visit [-->](?:ProviderDashboard);
        } else {
            self.response = "Unknown screen: " + self.screen;
        }
    }

    can handle_onboarding with UserProfile entry {
        here.name = self.input_data.get("name", "Friend");
        here.language = self.input_data.get("language", "English");
        here.cultural_background = self.input_data.get("background", "");
        here.provider_id = self.input_data.get("provider_id", "");
        self._patient_name = here.name;
        self._patient_language = here.language;

        self.response = adapt_onboarding_message(
            here.name,
            here.language,
            here.cultural_background
        );

        print("\n=============================");
        print("SCREEN 1 — PATIENT ONBOARDING");
        print("=============================");
        print("Name: " + here.name);
        print("Language: " + here.language);
        print("Background: " + here.cultural_background);
        print("Linked Provider: " + here.provider_id);
        print("\nAgent Welcome Message:");
        print(self.response);
    }

    can handle_lab_report with LabReport entry {
        here.raw_text = self.input_data.get("pdf_text", "");
        here.patient_name = self.input_data.get("patient_name", "Patient");
        here.patient_language = self.input_data.get("language", "English");
        self._patient_name = here.patient_name;
        self._patient_language = here.patient_language;

        here.flagged_values = extract_flagged_values(here.raw_text);
        self._flagged = here.flagged_values;

        here.suggestions = generate_health_suggestions(
            here.flagged_values,
            here.patient_language
        );

        self.response = {
            "flagged": here.flagged_values,
            "suggestions": here.suggestions
        };

        print("\n=====================================");
        print("SCREEN 2 — LAB REPORT ANALYSIS");
        print("=====================================");
        print("Patient: " + here.patient_name);
        print("\nFlagged Values:");
        for flag in here.flagged_values {
            print("  RED FLAG -> " + flag);
        }
        print("\nAI Suggestions (" + here.patient_language + "):");
        print(here.suggestions);
        print("\n[Auto-triggering provider notification...]");

        visit [-->](?:ProviderDashboard);
    }

    can handle_appointments with AppointmentCalendar entry {
        here.upcoming = self.input_data.get("upcoming", [
            "Tuesday Mar 18 — Dr. Patel 10:00 AM",
            "Friday Mar 21 — Lab Follow-up 2:00 PM"
        ]);
        here.pending_request = self.input_data.get("request", "");

        if here.pending_request != "" {
            self.response = handle_appointment_request(
                here.upcoming,
                here.pending_request
            );
        } else {
            self.response = "Your upcoming appointments are loaded.";
        }

        print("\n=============================");
        print("SCREEN 3 — APPOINTMENTS");
        print("=============================");
        print("Upcoming Appointments:");
        for appt in here.upcoming {
            print("  -> " + appt);
        }
        if here.pending_request != "" {
            print("\nAppointment Request: " + here.pending_request);
            print("Agent Response: " + self.response);
        }
    }

    can handle_provider with ProviderDashboard entry {
        patient = self._patient_name
            if self._patient_name != ""
            else self.input_data.get("patient_name", "Unknown Patient");

        flagged = self._flagged
            if len(self._flagged) > 0
            else self.input_data.get("flagged", []);

        alert = format_provider_alert(patient, flagged);
        here.alerts.append(alert);

        print("\n=============================");
        print("SCREEN 4 — PROVIDER DASHBOARD");
        print("=============================");
        print("NEW NOTIFICATION:");
        print(alert);
        print("Total alerts: " + str(len(here.alerts)));

        if self.screen == "provider" {
            self.response = alert;
        }
    }
}

with entry {
    profile   = root ++> UserProfile();
    lab       = root ++> LabReport();
    calendar  = root ++> AppointmentCalendar();
    dashboard = root ++> ProviderDashboard();
    lab ++> dashboard;

    print("\n#############################################");
    print("#     HEALTHBRIDGE AGENT — FULL DEMO        #");
    print("#############################################");

    root spawn HealthBridgeAgent(
        screen="onboarding",
        input_data={
            "name": "Maria Santos",
            "language": "Portuguese",
            "background": "Brazilian student, prefers warm direct communication",
            "provider_id": "DR_PATEL_001"
        }
    );

    root spawn HealthBridgeAgent(
        screen="lab_report",
        input_data={
            "pdf_text": "Patient: Maria Santos\nHemoglobin: 9.2 g/dL (Normal: 12.0-16.0)\nWBC: 11500 /uL (Normal: 4500-11000)\nGlucose: 58 mg/dL (Normal: 70-100)\nPlatelets: 215000 (Normal: 150000-400000)",
            "patient_name": "Maria Santos",
            "language": "Portuguese"
        }
    );

    root spawn HealthBridgeAgent(
        screen="appointment",
        input_data={
            "request": "I need to see Dr. Patel this Thursday morning"
        }
    );

    print("\n#############################################");
    print("#         ALL 4 SCREENS COMPLETED           #");
    print("#############################################\n");
}
EOF
echo "✅ agent.jac created. Now set your API key and run it."