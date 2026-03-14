"""Apollo Health main orchestrator."""

import from modules.provider { ProviderService, ProviderAlert, RefillRequest }


obj ApolloOrchestrator {
    has provider_service: ProviderService by postinit;
    has high_risk_symptoms: list = [
        "chest pain",
        "shortness of breath",
        "trouble breathing",
        "stroke symptoms",
        "severe bleeding",
        "fainting",
        "confusion"
    ];
    has moderate_risk_symptoms: list = [
        "fever",
        "cough",
        "vomiting",
        "dizziness",
        "fatigue",
        "rash",
        "infection"
    ];

    def postinit() {
        self.provider_service = ProviderService();
        self.provider_service.setup_demo_data();
    }

    def contains_match(symptoms: list, target_list: list) -> bool {
        for symptom in symptoms {
            for target in target_list {
                if symptom.lower() == target.lower() {
                    return True;
                }
            }
        }
        return False;
    }

    def triage_symptoms(symptoms: list, severity: str) -> dict {
        risk_level = "low";
        recommendation = "Monitor symptoms and schedule a routine primary care appointment if needed.";

        if severity.lower() == "severe" or self.contains_match(symptoms, self.high_risk_symptoms) {
            risk_level = "high";
            recommendation = "Go to the ER immediately.";
        } elif severity.lower() == "moderate" or self.contains_match(symptoms, self.moderate_risk_symptoms) {
            risk_level = "moderate";
            recommendation = "Schedule a same-day or next-day appointment with your primary care provider.";
        }

        return {
            "risk_level": risk_level,
            "recommendation": recommendation
        };
    }

    def handle_symptom_intake(
        patient_name: str,
        patient_age: int,
        symptoms: list,
        duration: str,
        severity: str,
        callback_number: str,
        primary_doctor: str
    ) -> dict {
        triage = self.triage_symptoms(symptoms, severity);

        provider_result = "No provider notification sent.";

        if triage["risk_level"] == "moderate" or triage["risk_level"] == "high" {
            alert = ProviderAlert(
                patient_name=patient_name,
                patient_age=patient_age,
                duration=duration,
                severity=severity,
                triage_result=triage["risk_level"],
                recommendation=triage["recommendation"],
                callback_number=callback_number,
                timestamp="2026-03-14 2:30 PM",
                risk_level=triage["risk_level"],
                symptoms=symptoms
            );

            provider_result = self.provider_service.notify_provider(alert, primary_doctor);
        }

        return {
            "success": True,
            "request_type": "symptom_intake",
            "patient_name": patient_name,
            "symptoms": symptoms,
            "triage": triage,
            "provider_result": provider_result
        };
    }

    def handle_appointment_request(
        patient_name: str,
        insurance: str,
        preferred_time: str
    ) -> dict {
        booking_result = self.provider_service.book_appointment(
            patient_name,
            insurance,
            preferred_time
        );

        return {
            "success": True,
            "request_type": "appointment",
            "patient_name": patient_name,
            "preferred_time": preferred_time,
            "provider_result": booking_result
        };
    }

    def handle_cancel_request(
        patient_name: str,
        appointment_time: str,
        reason: str
    ) -> dict {
        cancel_result = self.provider_service.cancel_appointment(
            patient_name,
            appointment_time,
            reason
        );

        return {
            "success": True,
            "request_type": "cancel_appointment",
            "patient_name": patient_name,
            "appointment_time": appointment_time,
            "provider_result": cancel_result
        };
    }

    def handle_reschedule_request(
        patient_name: str,
        old_time: str,
        new_time: str
    ) -> dict {
        reschedule_result = self.provider_service.reschedule_appointment(
            patient_name,
            old_time,
            new_time
        );

        return {
            "success": True,
            "request_type": "reschedule_appointment",
            "patient_name": patient_name,
            "old_time": old_time,
            "new_time": new_time,
            "provider_result": reschedule_result
        };
    }

    def handle_refill_request(
        patient_name: str,
        medication: str,
        dosage: str,
        pharmacy: str
    ) -> dict {
        refill_request = RefillRequest(
            patient_name=patient_name,
            medication=medication,
            dosage=dosage,
            pharmacy=pharmacy,
            timestamp="2026-03-14 2:35 PM"
        );

        provider_result = self.provider_service.handle_refill(refill_request);

        pharmacy_result = "Pharmacy module placeholder: check stock and place medication order here.";

        return {
            "success": True,
            "request_type": "refill_request",
            "patient_name": patient_name,
            "medication": medication,
            "dosage": dosage,
            "provider_result": provider_result,
            "pharmacy_result": pharmacy_result
        };
    }

    def route_request(action: str, data: dict) -> dict {
        match action {
            case "symptoms":
                return self.handle_symptom_intake(
                    data["patient_name"],
                    data["patient_age"],
                    data["symptoms"],
                    data["duration"],
                    data["severity"],
                    data["callback_number"],
                    data["primary_doctor"]
                );
            case "appointment":
                return self.handle_appointment_request(
                    data["patient_name"],
                    data["insurance"],
                    data["preferred_time"]
                );
            case "cancel":
                return self.handle_cancel_request(
                    data["patient_name"],
                    data["appointment_time"],
                    data["reason"]
                );
            case "reschedule":
                return self.handle_reschedule_request(
                    data["patient_name"],
                    data["old_time"],
                    data["new_time"]
                );
            case "refill":
                return self.handle_refill_request(
                    data["patient_name"],
                    data["medication"],
                    data["dosage"],
                    data["pharmacy"]
                );
            case _:
                return {
                    "success": False,
                    "error": f"Unknown action: {action}"
                };
        }
    }
}


def print_divider(title: str) {
    print("\n==================================================");
    print(title);
    print("==================================================");
}


with entry {
    orchestrator = ApolloOrchestrator();

    print_divider("APOLLO HEALTH ORCHESTRATOR STARTED");
    print("Main orchestrator is running.");
    print("Supported actions: symptoms, appointment, cancel, reschedule, refill");

    symptom_result = orchestrator.route_request(
        "symptoms",
        {
            "patient_name": "Jane Doe",
            "patient_age": 42,
            "symptoms": ["chest pain", "shortness of breath"],
            "duration": "30 minutes",
            "severity": "severe",
            "callback_number": "555-7777",
            "primary_doctor": "Dr. Smith"
        }
    );
    print(symptom_result);

    appointment_result = orchestrator.route_request(
        "appointment",
        {
            "patient_name": "Jane Doe",
            "insurance": "Aetna",
            "preferred_time": "Mon 9AM"
        }
    );
    print(appointment_result);

    refill_result = orchestrator.route_request(
        "refill",
        {
            "patient_name": "Jane Doe",
            "medication": "Lisinopril",
            "dosage": "10mg",
            "pharmacy": "CVS"
        }
    );
    print(refill_result);

    print_divider("APOLLO HEALTH ORCHESTRATOR READY");
}
