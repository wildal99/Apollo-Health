
import from byllm.lib { Model }
import:py from datetime { datetime }

glob llm = Model(model_name="gpt-4o-mini");

node UserProfile {
    has id: str = "";
    has name: str = "";
    has date_of_birth: str = "";
    has email: str = "";
    has phone: str = "";
    has language: str = "English";
    has insurance_type: str = "";
    has provider_name: str = "";
    has patient_type: str = "";
    has onboarded: bool = False;
    has created_at: str = "";
}

node LabReport {
    has raw_text: str = "";
    has flagged_values: list = [];
    has suggestions: str = "";
    has patient_name: str = "";
    has patient_language: str = "";
}

node MedicalRecordUpload {
    has file_name: str = "";
    has raw_text: str = "";
    has redacted_text: str = "";
    has summary: str = "";
    has storage_id: str = "";
    has patient_name: str = "";
    has language: str = "";
}

node AppointmentCalendar {
    has upcoming: list = [];
    has pending_request: str = "";
}

node UserPreferences {
    has prefs: dict = {};
}

node ProviderDashboard {
    has alerts: list = [];
    has reports: list = [];
}

node UserAccount {
    has account_id: str = "";
    has name: str = "";
    has language: str = "";
    has age: int = 0;
    has gender: str = "";
    has birthday: str = "";
    has insurance: str = "";
    has email: str = "";
    has phone: str = "";
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
def format_provider_alert(patient_name: str, flagged: list, timestamp: str) -> str by llm();

"""
You are a scheduling assistant.
Given a list of upcoming appointments and a new appointment request,
confirm the request in a friendly one-sentence response
and include what was scheduled.
"""
def handle_appointment_request(upcoming: list, request: str) -> str by llm();

"""
Given the raw medical record text, produce a short patient-facing
summary in the requested language, and return a redacted version
safe to store/display in non-secure logs. Also return a simulated
storage identifier for the securely stored record.
"""
def redact_medical_record(raw_text: str) -> str by llm();

def summarize_medical_record(raw_text: str, language: str) -> str by llm();

def store_medical_record(raw_text: str, patient_name: str) -> str by llm();

"""
Generate a concise provider-facing report combining flagged values,
patient-facing suggestions, and a timestamp. Return a short report string.
"""
def generate_provider_report(patient_name: str, flagged: list, suggestions: str, language: str, timestamp: str) -> str by llm();

def get_effective_setting(preferences: dict, input_data: dict, key: str, default: str) -> any {
    v = input_data.get(key, None);
    if v != None {
        if v != "" {
            return v;
        }
    }
    p = preferences.get(key, None);
    if p != None {
        return p;
    }
    return default;
}

def validate_email(email: str) -> bool {
    if email == None || email == "" {
        return false;
    }
    if !email.contains("@") { return false; }
    if !email.contains(".") { return false; }
    return true;
}

def validate_phone(phone: str) -> bool {
    if phone == None || phone == "" { return false; }
    digits = "";
    for ch in phone {
        if ch >= "0" && ch <= "9" {
            digits = digits + ch;
        }
    }
    return len(digits) >= 10;
}

def mask_email(email: str) -> str {
    if email == None || email == "" { return ""; }
    parts = email.split("@");
    if len(parts) != 2 { return ""; }
    name = parts[0];
    domain = parts[1];
    if len(name) <= 2 { masked = name[0] + "*"; }
    else { masked = name[0] + "*" * (len(name)-2) + name[-1]; }
    return masked + "@" + domain;
}

def mask_phone(phone: str) -> str {
    if phone == None || phone == "" { return ""; }
    digits = "";
    for ch in phone {
        if ch >= "0" && ch <= "9" { digits = digits + ch; }
    }
    if len(digits) <= 4 { return "****"; }
    visible = digits[-4:];
    return "***-***-" + visible;
}

def calculate_age_from_birthday(birthday: str) -> int {
    # Expect ISO date YYYY-MM-DD; return 0 on parse failure
    try {
        parts = birthday.split("-");
        if len(parts) != 3 { return 0; }
        y = int(parts[0]); m = int(parts[1]); d = int(parts[2]);
        now = datetime.datetime.now();
        age = now.year - y;
        if (now.month < m) || (now.month == m && now.day < d) { age = age - 1; }
        return age;
    } catch {
        return 0;
    }
}

def create_user_account_stub(profile: dict) -> str {
    # Placeholder: implement server-side account creation for production.
    ts = datetime.datetime.now().strftime("%Y%m%d%H%M%S");
    name = profile.get("name", "user");
    safe = name.replace(" ", "_").lower();
    return "acct-" + safe + "-" + ts;
}

walker HealthBridgeAgent {
    has screen: str;
    has input_data: dict = {};
    has response: any = None;
    has _flagged: list = [];
    has _patient_name: str = "";
    has _patient_language: str = "";
    has preferences: dict = {};

    can route with `root entry {
        if self.screen == "onboarding" {
            visit [-->](?:UserProfile);
        } elif self.screen == "records" {
            visit [-->](?:MedicalRecordUpload);
        } elif self.screen == "prefs" {
            visit [-->](?:UserPreferences);
        } elif self.screen == "lab_report" {
            visit [-->](?:LabReport);
        } elif self.screen == "appointment" {
            visit [-->](?:AppointmentCalendar);
        } elif self.screen == "provider" {
            visit [-->](?:ProviderDashboard);
        } else {
            report self.response = "Unknown screen: " + self.screen;
        }
    }

    can handle_onboarding with UserProfile entry {
        here.name = self.input_data.get("name", "");
        here.language = self.input_data.get("language", "");
        here.cultural_background = self.input_data.get("background", "");
        here.provider_id = self.input_data.get("provider_id", "");
        # additional intake fields
        here.age = int(self.input_data.get("age", 0));
        here.gender = self.input_data.get("gender", "");
        here.birthday = self.input_data.get("birthday", "");
        here.insurance = self.input_data.get("insurance", "");
        here.email = self.input_data.get("email", "");
        here.phone = self.input_data.get("phone", "");
        # Require patient to provide name and preferred language explicitly
        self._patient_name = here.name;
        self._patient_language = here.language;

        if here.name == "" {
            self.response = {"error": "onboarding requires patient 'name' in input_data"};
            print("ERROR: onboarding requires patient 'name'");
            return;
        }
        if here.language == "" {
            self.response = {"error": "onboarding requires patient 'language' in input_data"};
            print("ERROR: onboarding requires patient 'language'");
            return;
        }
        # validate required fields
        if here.name == "" {
            self.response = {"error": "onboarding requires patient 'name' in input_data"};
            print("ERROR: onboarding requires patient 'name'");
            return;
        }
        if here.language == "" {
            self.response = {"error": "onboarding requires patient 'language' in input_data"};
            print("ERROR: onboarding requires patient 'language'");
            return;
        }

        # compute age if birthday provided
        if here.age == 0 && here.birthday != "" {
            here.age = calculate_age_from_birthday(here.birthday);
        }

        # validate contact info if provided
        if here.email != "" && !validate_email(here.email) {
            self.response = {"error": "invalid email format"};
            print("ERROR: invalid email format");
            return;
        }
        if here.phone != "" && !validate_phone(here.phone) {
            self.response = {"error": "invalid phone format"};
            print("ERROR: invalid phone format");
            return;
        }

        # store a simple per-patient preferences dict so all screens
        # can default to the patient's chosen settings
        self.preferences = {
            "language": here.language,
            "cultural_background": here.cultural_background,
            "provider_id": here.provider_id,
            "timezone": self.input_data.get("timezone", "UTC"),
            "communication_style": self.input_data.get("communication_style", "warm"),
            "pronouns": self.input_data.get("pronouns", "they/them"),
            "accessibility": self.input_data.get("accessibility", "")
        };

        # create account (stub) and save account id
        acct_profile = {
            "name": here.name,
            "language": here.language,
            "age": here.age,
            "gender": here.gender,
            "birthday": here.birthday,
            "insurance": here.insurance,
            "email": here.email,
            "phone": here.phone
        };
        acct_id = create_user_account_stub(acct_profile);
        self.preferences["account_id"] = acct_id;
        # store a minimal user node (non-PHI safe to log)
        acct_node = root ++> UserAccount();
        acct_node.account_id = acct_id;
        acct_node.name = here.name;
        acct_node.language = here.language;
        acct_node.age = here.age;
        acct_node.gender = here.gender;
        acct_node.birthday = here.birthday;
        acct_node.insurance = here.insurance;
        acct_node.email = here.email;
        acct_node.phone = here.phone;

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
        print("Account ID: " + acct_id);
        masked_email = mask_email(here.email);
        masked_phone = mask_phone(here.phone);
        if masked_email != "" { print("Contact (email): " + masked_email); }
        if masked_phone != "" { print("Contact (phone): " + masked_phone); }
        print("\nAgent Welcome Message:");
        print(self.response);
    }

    can handle_lab_report with LabReport entry {
        here.raw_text = self.input_data.get("pdf_text", "");
        here.patient_name = self.input_data.get("patient_name", "");
        here.patient_language = get_effective_setting(self.preferences, self.input_data, "language", "");
        self._patient_name = here.patient_name;
        self._patient_language = here.patient_language;

        if here.patient_name == "" {
            self.response = {"error": "lab_report requires 'patient_name' in input_data"};
            print("ERROR: lab_report requires 'patient_name'");
            return;
        }
        if here.raw_text == "" {
            self.response = {"error": "lab_report requires 'pdf_text' in input_data"};
            print("ERROR: lab_report requires 'pdf_text'");
            return;
        }

        here.flagged_values = safe_extract_flagged_values(here.raw_text);
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

    can handle_records with MedicalRecordUpload entry {
        here.file_name = self.input_data.get("file_name", "");
        here.raw_text = self.input_data.get("pdf_text", "");
        here.patient_name = self.input_data.get("patient_name", "");
        here.language = get_effective_setting(self.preferences, self.input_data, "language", "");

        if here.patient_name == "" {
            self.response = {"error": "records upload requires 'patient_name' in input_data"};
            print("ERROR: records upload requires 'patient_name'");
            return;
        }
        if here.raw_text == "" {
            self.response = {"error": "records upload requires 'pdf_text' in input_data"};
            print("ERROR: records upload requires 'pdf_text'");
            return;
        }

        here.redacted_text = redact_medical_record(here.raw_text);
        here.summary = safe_summarize_medical_record(here.raw_text, here.language);
        here.storage_id = store_medical_record(here.raw_text, here.patient_name);

        self.response = {
            "file_name": here.file_name,
            "summary": here.summary,
            "storage_id": here.storage_id
        };

        print("\n=====================================");
        print("SCREEN 2B — MEDICAL RECORDS UPLOAD");
        print("=====================================");
        print("Patient: " + here.patient_name);
        print("File: " + here.file_name);
        print("Storage ID: " + here.storage_id);
        print("Patient Summary (" + here.language + "):");
        print(here.summary);
        print("\n[Record redacted for logs:]\n" + here.redacted_text);

        visit [-->](?:ProviderDashboard);
    }

    can handle_appointments with AppointmentCalendar entry {
        here.upcoming = self.input_data.get("upcoming", []);
        here.pending_request = self.input_data.get("request", "");
        here.preferred_provider = get_effective_setting(self.preferences, self.input_data, "provider", self.preferences.get("provider_id", ""));
        here.timezone = get_effective_setting(self.preferences, self.input_data, "timezone", self.preferences.get("timezone", "UTC"));

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

        now_ts = datetime.datetime.now().isoformat();

        alert = format_provider_alert(patient, flagged, now_ts);
        here.alerts.append(alert);

        # Generate a short provider report and store it in the dashboard
        suggestions = self.input_data.get("suggestions", "");
        report = generate_provider_report(patient, flagged, suggestions, self._patient_language, now_ts);
        here.reports.append(report);

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
"""
Server-friendly helpers: build demo inputs or call the walker
from your server runtime. The original `with entry` demo block
was removed because it spawns walkers directly — for a server
you should create a `HealthBridgeAgent` instance per request
and call the appropriate screen handler.

Example usage (pseudocode):

  agent = HealthBridgeAgent(screen="onboarding", input_data={...})
  // run the walker in your Jac runtime environment

Use `demo_inputs()` to get example payloads for testing.
"""

def demo_inputs() -> dict {
    # Return empty templates so callers must provide actual patient data.
    return {
        "onboarding": {"name": "", "language": "", "background": "", "provider_id": ""},
        "lab_report": {"pdf_text": "", "patient_name": "", "language": ""},
        "appointment": {"request": "", "provider": "", "timezone": ""},
        "records": {"file_name": "", "pdf_text": "", "patient_name": "", "language": ""}
    };
}
