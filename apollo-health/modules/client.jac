pip install jaseci

# main.jac
import from byllm.lib { Model }

glob llm = Model(model_name="openai/gpt-4o-mini");
# swap for featherless: Model(model_name="featherless/...")

node UserProfile {
    has name: str = "";
    has language: str = "";
    has cultural_background: str = "";
    has provider_id: str = "";
}

node LabReport {
    has pdf_text: str = "";
    has flagged_values: list = [];
    has suggestions: str = "";
    has alert_sent: bool = False;
}

node AppointmentCalendar {
    has upcoming: list = [];
    has requested: str = "";
}

node ProviderDashboard {
    has alerts: list = [];
}

node UserProfile {
    has name: str = "";
    has language: str = "";
    has cultural_background: str = "";
    has provider_id: str = "";

    can handle_onboarding with HealthBridgeWalker entry {
        # fires when walker arrives at this node
        self.name = visitor.input_data.get("name", "");
        self.language = visitor.input_data.get("language", "English");
        self.cultural_background = visitor.input_data.get("background", "");
        visitor.response = culturally_adapt_response(
            self.name,
            self.cultural_background,
            self.language
        );
    }
}

node LabReport {
    has pdf_text: str = "";
    has flagged_values: list = [];
    has suggestions: str = "";

    can handle_lab_report with HealthBridgeWalker entry {
        self.pdf_text = visitor.input_data.get("pdf_text", "");
        self.flagged_values = extract_flags(self.pdf_text);
        self.suggestions = generate_suggestions(
            self.flagged_values,
            visitor.user_language
        );
        # trigger provider alert
        visit [-->](?:ProviderDashboard);
    }
}

node AppointmentCalendar {
    has upcoming: list = [];

    can handle_appointments with HealthBridgeWalker entry {
        visitor.response = {
            "upcoming": self.upcoming,
            "status": "appointment_requested"
        };
    }
}

node ProviderDashboard {
    has alerts: list = [];

    can handle_notification with HealthBridgeWalker entry {
        alert = format_alert(
            visitor.patient_name,
            visitor.flagged_values
        );
        self.alerts.append(alert);
        visitor.response = alert;
    }
}
