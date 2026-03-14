import:jac from modules.alissaAIAgent {
    HealthBridgeAgent,
    UserProfile,
    LabReport,
    MedicalRecordUpload,
    AppointmentCalendar,
    ProviderDashboard
}

# Builds the graph the very first time the server starts
def setup_graph() -> None {
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
}

# ─────────────────────────────────────────
# ENDPOINT 1 — Screen 1: Patient Onboarding
# Frontend sends: name, language, background, provider_id
# Frontend gets back: welcome_message, patient info
# ─────────────────────────────────────────
walker onboard_patient {
    has name: str;
    has language: str = "English";
    has cultural_background: str = "";
    has provider_id: str = "";

    obj __specs__ {
        static has auth: bool = False;
    }

    can run with `root entry {
        setup_graph();
        res = root spawn HealthBridgeAgent(
            screen="onboarding",
            input_data={
                "name": self.name,
                "language": self.language,
                "background": self.cultural_background,
                "provider_id": self.provider_id
            }
        );
        report res.response;
    }
}

# ─────────────────────────────────────────
# ENDPOINT 2 — Screen 2: Lab Report Analysis
# Frontend sends: pdf_text, patient_name, language
# Frontend gets back: flagged_values, suggestions, uploaded_at
# ─────────────────────────────────────────
walker analyze_lab_report {
    has pdf_text: str;
    has patient_name: str;
    has language: str = "English";

    obj __specs__ {
        static has auth: bool = False;
    }

    can run with `root entry {
        setup_graph();
        res = root spawn HealthBridgeAgent(
            screen="lab_report",
            input_data={
                "pdf_text": self.pdf_text,
                "patient_name": self.patient_name,
                "language": self.language
            }
        );
        report res.response;
    }
}

# ─────────────────────────────────────────
# ENDPOINT 3 — Screen 2B: Medical Record Upload
# Frontend sends: pdf_text, file_name, patient_name, language
# Frontend gets back: summary, storage_id, redacted_preview
# ─────────────────────────────────────────
walker upload_medical_record {
    has pdf_text: str;
    has file_name: str = "record.pdf";
    has patient_name: str;
    has language: str = "English";

    obj __specs__ {
        static has auth: bool = False;
    }

    can run with `root entry {
        setup_graph();
        res = root spawn HealthBridgeAgent(
            screen="records",
            input_data={
                "pdf_text": self.pdf_text,
                "file_name": self.file_name,
                "patient_name": self.patient_name,
                "language": self.language
            }
        );
        report res.response;
    }
}

# ─────────────────────────────────────────
# ENDPOINT 4 — Screen 3: Appointments
# Frontend sends: request (optional)
# Frontend gets back: upcoming list, confirmation if request made
# ─────────────────────────────────────────
walker get_appointments {
    has request: str = "";

    obj __specs__ {
        static has auth: bool = False;
    }

    can run with `root entry {
        setup_graph();
        res = root spawn HealthBridgeAgent(
            screen="appointment",
            input_data={"request": self.request}
        );
        report res.response;
    }
}

# ─────────────────────────────────────────
# ENDPOINT 5 — Screen 4: Provider Dashboard
# Frontend sends: nothing
# Frontend gets back: all alerts, total count
# ─────────────────────────────────────────
walker get_provider_alerts {
    obj __specs__ {
        static has auth: bool = False;
    }

    can run with `root entry {
        setup_graph();
        res = root spawn HealthBridgeAgent(
            screen="provider",
            input_data={}
        );
        report res.response;
    }
}