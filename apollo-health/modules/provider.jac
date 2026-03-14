"""Provider module for Apollo Health.
Handles scheduling, alerts, reminders, and refill approvals (simulated).
"""


# ============================================================
# Provider Node
# ============================================================

node Provider {
    has name: str;
    has specialty: str;
    has clinic_name: str;
    has phone_number: str;
    has fax: str;
    has email: str;
    has address: str;
    has accepted_insurance: list;
    has available_slots: list = [];
}


# ============================================================
# Provider Alert Node (FIXED ORDER)
# ============================================================

node ProviderAlert {
    has patient_name: str;
    has patient_age: int;
    has duration: str;
    has severity: str;
    has triage_result: str;
    has recommendation: str;
    has callback_number: str;
    has timestamp: str;
    has risk_level: str;
    has symptoms: list = [];
}


# ============================================================
# Refill Request Node
# ============================================================

node RefillRequest {
    has patient_name: str;
    has medication: str;
    has dosage: str;
    has pharmacy: str;
    has timestamp: str;
    has approved: bool = False;
}


# ============================================================
# Provider Service (Core Logic Object)
# ============================================================

obj ProviderService {

    has providers: list = [];

    # -------------------------
    # Setup Demo Data
    # -------------------------
    def setup_demo_data() {
        p1 = Provider(
            name="Dr. Smith",
            specialty="Primary Care",
            clinic_name="Apollo Clinic",
            phone_number="555-1111",
            fax="555-1112",
            email="drsmith@apollo.com",
            address="123 Health St",
            accepted_insurance=["Aetna", "BlueCross"]
        );

        p1.available_slots = ["Mon 9AM", "Mon 2PM", "Tue 11AM"];

        p2 = Provider(
            name="Dr. Patel",
            specialty="Primary Care",
            clinic_name="Apollo Clinic",
            phone_number="555-2222",
            fax="555-2223",
            email="drpatel@apollo.com",
            address="123 Health St",
            accepted_insurance=["Aetna", "Cigna"]
        );

        p2.available_slots = ["Wed 1PM", "Thu 10AM"];

        self.providers = [p1, p2];
    }


    # -------------------------
    # Notify Provider (Simulated Text)
    # -------------------------
    def notify_provider(alert: ProviderAlert, provider_name: str) -> str {
        print("\n[TEXT SENT TO PROVIDER]");
        print(f"Provider: {provider_name}");
        print(f"Patient: {alert.patient_name} ({alert.patient_age})");
        print(f"Symptoms: {alert.symptoms}");
        print(f"Severity: {alert.severity}");
        print(f"Recommendation: {alert.recommendation}");
        return "Provider notified successfully.";
    }


    # -------------------------
    # Book Appointment
    # -------------------------
    def book_appointment(patient_name: str, insurance: str, preferred_time: str) -> str {

        # Try PCP first
        for p in self.providers {
            if preferred_time in p.available_slots {

                if insurance not in p.accepted_insurance {
                    print("[WARNING] Insurance not accepted, booking anyway.");
                }

                p.available_slots.remove(preferred_time);

                print(f"[TEXT TO PATIENT] Appointment confirmed with {p.name} at {preferred_time}");
                print("[REMINDER] Sent immediately");
                print("[REMINDER] Scheduled for 24hr before");
                print("[REMINDER] Scheduled for 1hr before");

                return f"Booked with {p.name}";
            }
        }

        return "No PCP slots available. Offer fallback provider.";
    }


    # -------------------------
    # Cancel Appointment
    # -------------------------
    def cancel_appointment(patient_name: str, time: str, reason: str) -> str {
        print(f"[TEXT TO PATIENT] Appointment at {time} canceled.");
        print(f"Reason: {reason}");
        return "Canceled successfully.";
    }


    # -------------------------
    # Reschedule Appointment
    # -------------------------
    def reschedule_appointment(patient_name: str, old_time: str, new_time: str) -> str {
        print(f"[TEXT TO PATIENT] Appointment moved from {old_time} to {new_time}");
        return "Rescheduled successfully.";
    }


    # -------------------------
    # Refill Approval Logic (Rules-Based)
    # -------------------------
    def handle_refill(req: RefillRequest) -> str {

        if req.medication != "" {
            req.approved = True;
            print(f"[TEXT TO PATIENT] Refill approved for {req.medication}");
            return "Approved";
        }

        print("[TEXT TO PATIENT] Refill denied.");
        return "Denied";
    }
}
