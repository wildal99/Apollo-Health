"""Temporary main.jac for testing the provider module."""

import:jac .modules.provider {
    ProviderService,
    ProviderAlert,
    RefillRequest
}


walker RunProviderDemo {
    can run_provider_demo;

    def print_divider(title: str) {
        print("\n==================================================");
        print(title);
        print("==================================================");
    }

    def run_provider_demo {
        provider_service = ProviderService();
        provider_service.setup_demo_data();

        # -------------------------------------------------
        # 1. High-risk provider notification
        # -------------------------------------------------
        self.print_divider("1. HIGH-RISK PROVIDER NOTIFICATION");

        high_risk_alert = ProviderAlert(
            patient_name="Jane Doe",
            patient_age=42,
            symptoms=["chest pain", "shortness of breath"],
            duration="30 minutes",
            severity="severe",
            triage_result="high",
            recommendation="Go to the ER immediately.",
            callback_number="555-7777",
            timestamp="2026-03-14 1:30 PM",
            risk_level="high"
        );

        high_risk_result = provider_service.notify_provider(high_risk_alert, "Dr. Smith");
        print(high_risk_result);

        # -------------------------------------------------
        # 2. Moderate-risk provider notification
        # -------------------------------------------------
        self.print_divider("2. MODERATE-RISK PROVIDER NOTIFICATION");

        moderate_alert = ProviderAlert(
            patient_name="John Carter",
            patient_age=29,
            symptoms=["fever", "cough", "fatigue"],
            duration="3 days",
            severity="moderate",
            triage_result="moderate",
            recommendation="Schedule an appointment soon.",
            callback_number="555-8888",
            timestamp="2026-03-14 1:35 PM",
            risk_level="moderate"
        );

        moderate_result = provider_service.notify_provider(moderate_alert, "Dr. Smith");
        print(moderate_result);

        # -------------------------------------------------
        # 3. Book an appointment
        # -------------------------------------------------
        self.print_divider("3. BOOK APPOINTMENT");

        booking_request = {
            "patient_id": "P001",
            "patient_name": "Jane Doe",
            "patient_age": 42,
            "patient_phone": "555-7777",
            "patient_email": "janedoe@email.com",
            "patient_address": "123 Maple St",
            "primary_doctor": "Dr. Smith",
            "insurance": "Blue Cross",
            "reason_for_visit": "Chest pain follow-up",
            "urgency": "high",
            "preferred_date": "2026-03-15",
            "preferred_time": "09:00 AM",
            "appointment_type": "in_person"
        };

        booking_result = provider_service.book_appointment(booking_request);
        print(booking_result);

        confirmation_id = "";
        if booking_result["success"] == True {
            confirmation_id = booking_result["confirmation_id"];
            print("Saved confirmation ID: " + confirmation_id);
        }

        # -------------------------------------------------
        # 4. Send reminder for booked appointment
        # -------------------------------------------------
        self.print_divider("4. SEND REMINDER");

        if confirmation_id != "" {
            reminder_result = provider_service.send_reminder(confirmation_id);
            print(reminder_result);
        } else {
            print("Skipping reminder test because booking failed.");
        }

        # -------------------------------------------------
        # 5. Reschedule appointment
        # -------------------------------------------------
        self.print_divider("5. RESCHEDULE APPOINTMENT");

        new_confirmation_id = "";
        if confirmation_id != "" {
            reschedule_result = provider_service.reschedule_appointment(
                confirmation_id,
                "2026-03-16",
                "11:00 AM",
                "in_person",
                "Patient needs a different time"
            );
            print(reschedule_result);

            if reschedule_result["success"] == True {
                new_confirmation_id = reschedule_result["confirmation_id"];
                print("New confirmation ID: " + new_confirmation_id);
            }
        } else {
            print("Skipping reschedule test because booking failed.");
        }

        # -------------------------------------------------
        # 6. Cancel appointment
        # -------------------------------------------------
        self.print_divider("6. CANCEL APPOINTMENT");

        cancel_target = "";
        if new_confirmation_id != "" {
            cancel_target = new_confirmation_id;
        } elif confirmation_id != "" {
            cancel_target = confirmation_id;
        }

        if cancel_target != "" {
            cancel_result = provider_service.cancel_appointment(
                cancel_target,
                "Patient no longer needs this appointment"
            );
            print(cancel_result);
        } else {
            print("Skipping cancel test because no appointment exists.");
        }

        # -------------------------------------------------
        # 7. Approve refill request - should approve
        # -------------------------------------------------
        self.print_divider("7. REFILL APPROVAL - SHOULD APPROVE");

        refill_request_approved = RefillRequest(
            patient_id="P001",
            patient_name="Jane Doe",
            provider_name="Dr. Smith",
            medication_name="Lisinopril",
            dosage="10mg",
            quantity=30
        );

        refill_result_approved = provider_service.approve_refill_request(refill_request_approved);
        print(refill_result_approved);

        # -------------------------------------------------
        # 8. Approve refill request - should deny
        # -------------------------------------------------
        self.print_divider("8. REFILL APPROVAL - SHOULD DENY");

        refill_request_denied = RefillRequest(
            patient_id="P001",
            patient_name="Jane Doe",
            provider_name="Dr. Smith",
            medication_name="Lisinopril",
            dosage="40mg",
            quantity=30
        );

        refill_result_denied = provider_service.approve_refill_request(refill_request_denied);
        print(refill_result_denied);

        # -------------------------------------------------
        # 9. Booking fallback demo
        # -------------------------------------------------
        self.print_divider("9. FALLBACK BOOKING DEMO");

        fallback_booking_request = {
            "patient_id": "P002",
            "patient_name": "John Carter",
            "patient_age": 29,
            "patient_phone": "555-8888",
            "patient_email": "johncarter@email.com",
            "patient_address": "456 Oak St",
            "primary_doctor": "Dr. Smith",
            "insurance": "Cigna",
            "reason_for_visit": "Fever and cough",
            "urgency": "moderate",
            "preferred_date": "2026-03-15",
            "preferred_time": "01:00 PM",
            "appointment_type": "telehealth"
        };

        fallback_booking_result = provider_service.book_appointment(fallback_booking_request);
        print(fallback_booking_result);

        self.print_divider("PROVIDER MODULE DEMO COMPLETE");
    }
}
