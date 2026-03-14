"""Provider module for Apollo Health.

Responsibilities:
- Notify primary care providers about symptom-based cases
- Book appointments
- Cancel appointments
- Reschedule appointments
- Handle multiple providers
- Simulate reminders
- Approve or deny refill requests

Notes:
- This is hackathon-oriented prototype logic
- Notifications are simulated
- All patient-facing wording should be handled by client.jac / main.jac
"""


node AppointmentSlot {
    has date: str;
    has time: str;
    has appointment_type: str;   # "in_person" or "telehealth"
    has clinic_location: str;
    has is_booked: bool = False;
}


node Provider {
    has name: str;
    has specialty: str;
    has clinic_name: str;
    has phone_number: str;
    has fax: str;
    has email: str;
    has address: str;
    has available_appointment_slots: list = [];
    has accepted_insurance: list = [];
}


node Appointment {
    has confirmation_id: str;
    has patient_id: str;
    has patient_name: str;
    has patient_age: int;
    has patient_phone: str;
    has patient_email: str;
    has patient_address: str;
    has provider_name: str;
    has clinic_name: str;
    has date: str;
    has time: str;
    has appointment_type: str;
    has reason_for_visit: str;
    has urgency: str;
    has insurance: str;
    has status: str;   # pending, confirmed, canceled, rescheduled, completed
    has reminder_schedule: list = [];
}


node ProviderAlert {
    has patient_name: str;
    has patient_age: int;
    has symptoms: list = [];
    has duration: str;
    has severity: str;
    has triage_result: str;
    has recommendation: str;
    has callback_number: str;
    has timestamp: str;
    has risk_level: str;   # low, moderate, high
}


node RefillRequest {
    has patient_id: str;
    has patient_name: str;
    has provider_name: str;
    has medication_name: str;
    has dosage: str;
    has quantity: int;
}


walker ProviderService {
    has providers: list = [];
    has appointments: list = [];
    has patient_medication_records: dict = {};

    """Initialize sample providers and slots for hackathon demo."""
    def setup_demo_data() {
        if len(self.providers) > 0 {
            return;
        }

        smith_slots = [
            AppointmentSlot(
                date="2026-03-15",
                time="09:00 AM",
                appointment_type="in_person",
                clinic_location="Apollo Family Clinic - Main Office",
                is_booked=False
            ),
            AppointmentSlot(
                date="2026-03-15",
                time="02:00 PM",
                appointment_type="telehealth",
                clinic_location="Apollo Family Clinic - Virtual",
                is_booked=False
            ),
            AppointmentSlot(
                date="2026-03-16",
                time="11:00 AM",
                appointment_type="in_person",
                clinic_location="Apollo Family Clinic - Main Office",
                is_booked=False
            )
        ];

        lee_slots = [
            AppointmentSlot(
                date="2026-03-15",
                time="10:30 AM",
                appointment_type="in_person",
                clinic_location="Apollo Family Clinic - Main Office",
                is_booked=False
            ),
            AppointmentSlot(
                date="2026-03-16",
                time="01:30 PM",
                appointment_type="telehealth",
                clinic_location="Apollo Family Clinic - Virtual",
                is_booked=False
            )
        ];

        patel_slots = [
            AppointmentSlot(
                date="2026-03-15",
                time="03:00 PM",
                appointment_type="in_person",
                clinic_location="Downtown Primary Care",
                is_booked=False
            ),
            AppointmentSlot(
                date="2026-03-17",
                time="09:30 AM",
                appointment_type="telehealth",
                clinic_location="Downtown Primary Care - Virtual",
                is_booked=False
            )
        ];

        self.providers = [
            Provider(
                name="Dr. Smith",
                specialty="Primary Care",
                clinic_name="Apollo Family Clinic",
                phone_number="555-1000",
                fax="555-1001",
                email="drsmith@apollohealth.demo",
                address="101 Main St",
                available_appointment_slots=smith_slots,
                accepted_insurance=["Blue Cross", "Aetna", "Cigna", "United"]
            ),
            Provider(
                name="Dr. Lee",
                specialty="Primary Care",
                clinic_name="Apollo Family Clinic",
                phone_number="555-2000",
                fax="555-2001",
                email="drlee@apollohealth.demo",
                address="101 Main St",
                available_appointment_slots=lee_slots,
                accepted_insurance=["Blue Cross", "Cigna"]
            ),
            Provider(
                name="Dr. Patel",
                specialty="Primary Care",
                clinic_name="Downtown Primary Care",
                phone_number="555-3000",
                fax="555-3001",
                email="drpatel@apollohealth.demo",
                address="202 Oak Ave",
                available_appointment_slots=patel_slots,
                accepted_insurance=["Aetna", "United", "Humana"]
            )
        ];

        self.patient_medication_records = {
            "P001": [
                {"medication_name": "Lisinopril", "dosage": "10mg"},
                {"medication_name": "Metformin", "dosage": "500mg"}
            ],
            "P002": [
                {"medication_name": "Amoxicillin", "dosage": "500mg"}
            ]
        };
    }

    """Generate a simple fake appointment confirmation ID."""
    def generate_confirmation_id(patient_id: str, provider_name: str, date: str, time: str) -> str {
        provider_part = provider_name.replace("Dr. ", "").replace(" ", "").upper();
        date_part = date.replace("-", "");
        time_part = time.replace(":", "").replace(" ", "");
        return f"APT-{patient_id}-{provider_part}-{date_part}-{time_part}";
    }

    """Find a provider object by name."""
    def get_provider_by_name(provider_name: str) -> Provider | None {
        for provider in self.providers {
            if provider.name == provider_name {
                return provider;
            }
        }
        return None;
    }

    """Simulate notifying provider based on risk level.
    low -> no notification
    moderate -> email
    high -> text
    """
    def notify_provider(alert: ProviderAlert, provider_name: str) -> dict {
        self.setup_demo_data();

        provider = self.get_provider_by_name(provider_name);
        if provider is None {
            return {
                "success": False,
                "error": "Provider not found",
                "provider_name": provider_name
            };
        }

        if alert.risk_level == "low" {
            return {
                "success": True,
                "notification_sent": False,
                "method": "none",
                "provider_name": provider.name,
                "message": "Low-risk case does not require provider notification."
            };
        }

        method = "email";
        if alert.risk_level == "high" {
            method = "text";
        }

        simulated_message = (
            f"[SIMULATED {method.upper()}] "
            f"To: {provider.name} | Patient: {alert.patient_name} | "
            f"Symptoms: {alert.symptoms} | Severity: {alert.severity} | "
            f"Triage: {alert.triage_result} | Recommendation: {alert.recommendation}"
        );

        print(simulated_message);

        return {
            "success": True,
            "notification_sent": True,
            "method": method,
            "provider_name": provider.name,
            "provider_contact": {
                "phone": provider.phone_number,
                "email": provider.email,
                "fax": provider.fax
            },
            "message": simulated_message
        };
    }

    """Return matching open slots for a provider."""
    def get_matching_slots(provider: Provider, preferred_date: str, preferred_time: str, appointment_type: str) -> list {
        matches = [];

        for slot in provider.available_appointment_slots {
            if slot.is_booked == False {
                date_match = (preferred_date == "" or slot.date == preferred_date);
                time_match = (preferred_time == "" or slot.time == preferred_time);
                type_match = (appointment_type == "" or slot.appointment_type == appointment_type);

                if date_match and time_match and type_match {
                    matches.append(slot);
                }
            }
        }

        return matches;
    }

    """Fallback search: any open slot that matches type, even if date/time preference not exact."""
    def get_fallback_slots(provider: Provider, appointment_type: str) -> list {
        matches = [];

        for slot in provider.available_appointment_slots {
            if slot.is_booked == False {
                if appointment_type == "" or slot.appointment_type == appointment_type {
                    matches.append(slot);
                }
            }
        }

        return matches;
    }

    """Find available appointment slots.
    Order:
    1. Patient PCP
    2. Same clinic PCPs
    3. Providers accepting insurance
    """
    def find_available_slots(
        patient_primary_doctor: str,
        preferred_date: str,
        preferred_time: str,
        appointment_type: str,
        insurance: str
    ) -> dict {
        self.setup_demo_data();

        exact_matches = [];
        fallback_matches = [];
        warnings = [];

        primary_provider = self.get_provider_by_name(patient_primary_doctor);
        same_clinic_name = "";

        if primary_provider is not None {
            same_clinic_name = primary_provider.clinic_name;

            primary_exact = self.get_matching_slots(
                primary_provider,
                preferred_date,
                preferred_time,
                appointment_type
            );

            if len(primary_exact) > 0 {
                return {
                    "success": True,
                    "match_type": "primary_doctor_exact",
                    "slots": primary_exact,
                    "provider": primary_provider,
                    "warnings": warnings
                };
            }

            primary_fallback = self.get_fallback_slots(primary_provider, appointment_type);
            if len(primary_fallback) > 0 {
                fallback_matches = primary_fallback;
            }
        }

        for provider in self.providers {
            if provider.name != patient_primary_doctor and provider.clinic_name == same_clinic_name {
                clinic_exact = self.get_matching_slots(
                    provider,
                    preferred_date,
                    preferred_time,
                    appointment_type
                );

                if len(clinic_exact) > 0 {
                    if insurance not in provider.accepted_insurance {
                        warnings.append(
                            f"{provider.name} may not accept patient insurance ({insurance})."
                        );
                    }

                    return {
                        "success": True,
                        "match_type": "same_clinic_exact",
                        "slots": clinic_exact,
                        "provider": provider,
                        "warnings": warnings
                    };
                }
            }
        }

        for provider in self.providers {
            if insurance in provider.accepted_insurance {
                insurance_exact = self.get_matching_slots(
                    provider,
                    preferred_date,
                    preferred_time,
                    appointment_type
                );

                if len(insurance_exact) > 0 {
                    return {
                        "success": True,
                        "match_type": "insurance_exact",
                        "slots": insurance_exact,
                        "provider": provider,
                        "warnings": warnings
                    };
                }
            }
        }

        if len(fallback_matches) > 0 and primary_provider is not None {
            if insurance not in primary_provider.accepted_insurance {
                warnings.append(
                    f"{primary_provider.name} may not accept patient insurance ({insurance})."
                );
            }

            return {
                "success": True,
                "match_type": "primary_doctor_fallback",
                "slots": fallback_matches,
                "provider": primary_provider,
                "warnings": warnings
            };
        }

        for provider in self.providers {
            if provider.name != patient_primary_doctor and provider.clinic_name == same_clinic_name {
                clinic_fallback = self.get_fallback_slots(provider, appointment_type);

                if len(clinic_fallback) > 0 {
                    if insurance not in provider.accepted_insurance {
                        warnings.append(
                            f"{provider.name} may not accept patient insurance ({insurance})."
                        );
                    }

                    return {
                        "success": True,
                        "match_type": "same_clinic_fallback",
                        "slots": clinic_fallback,
                        "provider": provider,
                        "warnings": warnings
                    };
                }
            }
        }

        for provider in self.providers {
            insurance_fallback = self.get_fallback_slots(provider, appointment_type);

            if len(insurance_fallback) > 0 {
                if insurance not in provider.accepted_insurance {
                    warnings.append(
                        f"{provider.name} may not accept patient insurance ({insurance})."
                    );
                }

                return {
                    "success": True,
                    "match_type": "next_available_provider",
                    "slots": insurance_fallback,
                    "provider": provider,
                    "warnings": warnings
                };
            }
        }

        return {
            "success": False,
            "error": "No available appointments found",
            "slots": [],
            "warnings": warnings
        };
    }

    """Book the best available appointment based on preferences and provider order."""
    def book_appointment(request: dict) -> dict {
        self.setup_demo_data();

        required_fields = [
            "patient_id",
            "patient_name",
            "patient_age",
            "patient_phone",
            "patient_email",
            "patient_address",
            "primary_doctor",
            "insurance",
            "reason_for_visit",
            "urgency",
            "preferred_date",
            "preferred_time",
            "appointment_type"
        ];

        for field in required_fields {
            if field not in request {
                return {
                    "success": False,
                    "error": f"Missing required field: {field}"
                };
            }
        }

        slot_search = self.find_available_slots(
            request["primary_doctor"],
            request["preferred_date"],
            request["preferred_time"],
            request["appointment_type"],
            request["insurance"]
        );

        if slot_search["success"] == False {
            return {
                "success": False,
                "error": "No appointment slot available",
                "urgency": request["urgency"],
                "recommendation": (
                    "Suggest ER immediately."
                    if request["urgency"] == "high"
                    else "Offer next available provider or alternate care option."
                )
            };
        }

        provider = slot_search["provider"];
        chosen_slot = slot_search["slots"][0];
        chosen_slot.is_booked = True;

        confirmation_id = self.generate_confirmation_id(
            request["patient_id"],
            provider.name,
            chosen_slot.date,
            chosen_slot.time
        );

        reminder_schedule = [
            {
                "type": "booking_confirmation",
                "method": "text+email",
                "time": "immediately"
            },
            {
                "type": "appointment_reminder",
                "method": "text+email",
                "time": "24_hours_before"
            },
            {
                "type": "appointment_reminder",
                "method": "text+email",
                "time": "1_hour_before"
            }
        ];

        appointment = Appointment(
            confirmation_id=confirmation_id,
            patient_id=request["patient_id"],
            patient_name=request["patient_name"],
            patient_age=request["patient_age"],
            patient_phone=request["patient_phone"],
            patient_email=request["patient_email"],
            patient_address=request["patient_address"],
            provider_name=provider.name,
            clinic_name=provider.clinic_name,
            date=chosen_slot.date,
            time=chosen_slot.time,
            appointment_type=chosen_slot.appointment_type,
            reason_for_visit=request["reason_for_visit"],
            urgency=request["urgency"],
            insurance=request["insurance"],
            status="confirmed",
            reminder_schedule=reminder_schedule
        );

        self.appointments.append(appointment);

        return {
            "success": True,
            "appointment_booked": True,
            "confirmation_id": appointment.confirmation_id,
            "provider_name": appointment.provider_name,
            "clinic_name": appointment.clinic_name,
            "date": appointment.date,
            "time": appointment.time,
            "appointment_type": appointment.appointment_type,
            "status": appointment.status,
            "warnings": slot_search["warnings"],
            "reminders_created": reminder_schedule
        };
    }

    """Cancel an appointment and free the slot again."""
    def cancel_appointment(confirmation_id: str, cancel_reason: str) -> dict {
        self.setup_demo_data();

        if cancel_reason == "" {
            return {
                "success": False,
                "error": "Cancellation reason is required"
            };
        }

        for appointment in self.appointments {
            if appointment.confirmation_id == confirmation_id {
                if appointment.status == "canceled" {
                    return {
                        "success": False,
                        "error": "Appointment is already canceled"
                    };
                }

                appointment.status = "canceled";

                provider = self.get_provider_by_name(appointment.provider_name);
                if provider is not None {
                    for slot in provider.available_appointment_slots {
                        if slot.date == appointment.date and slot.time == appointment.time {
                            slot.is_booked = False;
                        }
                    }
                }

                simulated_cancel_message = (
                    f"[SIMULATED EMAIL] Appointment canceled for {appointment.patient_name} "
                    f"with {appointment.provider_name} on {appointment.date} at {appointment.time}. "
                    f"Reason: {cancel_reason}"
                );

                print(simulated_cancel_message);

                return {
                    "success": True,
                    "appointment_canceled": True,
                    "confirmation_id": confirmation_id,
                    "status": appointment.status,
                    "provider_name": appointment.provider_name,
                    "date": appointment.date,
                    "time": appointment.time,
                    "cancel_reason": cancel_reason,
                    "provider_notification": simulated_cancel_message
                };
            }
        }

        return {
            "success": False,
            "error": "Appointment not found"
        };
    }

    """Reschedule by canceling old appointment and booking a new one.
    Tries same provider first if possible.
    """
    def reschedule_appointment(
        confirmation_id: str,
        new_preferred_date: str,
        new_preferred_time: str,
        new_appointment_type: str,
        reschedule_reason: str
    ) -> dict {
        self.setup_demo_data();

        if reschedule_reason == "" {
            return {
                "success": False,
                "error": "Reschedule reason is required"
            };
        }

        original_appointment = None;

        for appointment in self.appointments {
            if appointment.confirmation_id == confirmation_id {
                original_appointment = appointment;
            }
        }

        if original_appointment is None {
            return {
                "success": False,
                "error": "Original appointment not found"
            };
        }

        if original_appointment.status == "canceled" {
            return {
                "success": False,
                "error": "Cannot reschedule a canceled appointment"
            };
        }

        old_provider_name = original_appointment.provider_name;
        old_provider = self.get_provider_by_name(old_provider_name);

        if old_provider is not None {
            same_provider_exact = self.get_matching_slots(
                old_provider,
                new_preferred_date,
                new_preferred_time,
                new_appointment_type
            );

            if len(same_provider_exact) > 0 {
                cancel_result = self.cancel_appointment(
                    confirmation_id,
                    f"Rescheduled: {reschedule_reason}"
                );

                if cancel_result["success"] == False {
                    return cancel_result;
                }

                new_request = {
                    "patient_id": original_appointment.patient_id,
                    "patient_name": original_appointment.patient_name,
                    "patient_age": original_appointment.patient_age,
                    "patient_phone": original_appointment.patient_phone,
                    "patient_email": original_appointment.patient_email,
                    "patient_address": original_appointment.patient_address,
                    "primary_doctor": old_provider_name,
                    "insurance": original_appointment.insurance,
                    "reason_for_visit": original_appointment.reason_for_visit,
                    "urgency": original_appointment.urgency,
                    "preferred_date": new_preferred_date,
                    "preferred_time": new_preferred_time,
                    "appointment_type": new_appointment_type
                };

                new_booking = self.book_appointment(new_request);

                if new_booking["success"] == True {
                    new_booking["rescheduled_from"] = confirmation_id;
                    new_booking["reschedule_reason"] = reschedule_reason;
                    return new_booking;
                }
            }
        }

        cancel_result = self.cancel_appointment(
            confirmation_id,
            f"Rescheduled: {reschedule_reason}"
        );

        if cancel_result["success"] == False {
            return cancel_result;
        }

        fallback_request = {
            "patient_id": original_appointment.patient_id,
            "patient_name": original_appointment.patient_name,
            "patient_age": original_appointment.patient_age,
            "patient_phone": original_appointment.patient_phone,
            "patient_email": original_appointment.patient_email,
            "patient_address": original_appointment.patient_address,
            "primary_doctor": old_provider_name,
            "insurance": original_appointment.insurance,
            "reason_for_visit": original_appointment.reason_for_visit,
            "urgency": original_appointment.urgency,
            "preferred_date": new_preferred_date,
            "preferred_time": new_preferred_time,
            "appointment_type": new_appointment_type
        };

        new_booking = self.book_appointment(fallback_request);

        if new_booking["success"] == True {
            new_booking["rescheduled_from"] = confirmation_id;
            new_booking["reschedule_reason"] = reschedule_reason;

            simulated_reschedule_notice = (
                f"[SIMULATED EMAIL+TEXT] Appointment for "
                f"{original_appointment.patient_name} was rescheduled."
            );
            print(simulated_reschedule_notice);

            new_booking["provider_patient_notification"] = simulated_reschedule_notice;
            return new_booking;
        }

        return {
            "success": False,
            "error": "Unable to reschedule appointment",
            "details": new_booking
        };
    }

    """Simulate reminder delivery."""
    def send_reminder(confirmation_id: str) -> dict {
        self.setup_demo_data();

        for appointment in self.appointments {
            if appointment.confirmation_id == confirmation_id {
                if appointment.status != "confirmed" and appointment.status != "rescheduled" {
                    return {
                        "success": False,
                        "error": "Reminders can only be sent for active appointments"
                    };
                }

                simulated_message = (
                    f"[SIMULATED TEXT+EMAIL] Reminder for {appointment.patient_name}: "
                    f"{appointment.provider_name} on {appointment.date} at {appointment.time} "
                    f"({appointment.appointment_type})."
                );

                print(simulated_message);

                return {
                    "success": True,
                    "confirmation_id": confirmation_id,
                    "reminder_sent": True,
                    "method": "text+email",
                    "message": simulated_message
                };
            }
        }

        return {
            "success": False,
            "error": "Appointment not found"
        };
    }

    """Approve or deny a medication refill request.
    Rules-based:
    - provider must exist
    - patient must have matching medication record
    """
    def approve_refill_request(refill_request: RefillRequest) -> dict {
        self.setup_demo_data();

        provider = self.get_provider_by_name(refill_request.provider_name);
        if provider is None {
            return {
                "success": False,
                "approved": False,
                "error": "Provider not found"
            };
        }

        if refill_request.patient_id not in self.patient_medication_records {
            return {
                "success": False,
                "approved": False,
                "error": "Patient medication record not found"
            };
        }

        patient_records = self.patient_medication_records[refill_request.patient_id];
        med_match = False;

        for med in patient_records {
            if (
                med["medication_name"] == refill_request.medication_name and
                med["dosage"] == refill_request.dosage
            ) {
                med_match = True;
            }
        }

        if med_match == True {
            simulated_approval = (
                f"[SIMULATED PROVIDER APPROVAL] {provider.name} approved refill for "
                f"{refill_request.patient_name}: {refill_request.medication_name} "
                f"{refill_request.dosage}"
            );
            print(simulated_approval);

            return {
                "success": True,
                "approved": True,
                "provider_name": provider.name,
                "medication_name": refill_request.medication_name,
                "dosage": refill_request.dosage,
                "quantity": refill_request.quantity,
                "message": simulated_approval
            };
        }

        simulated_denial = (
            f"[SIMULATED PROVIDER DENIAL] {provider.name} denied refill for "
            f"{refill_request.patient_name}: medication/dosage mismatch."
        );
        print(simulated_denial);

        return {
            "success": True,
            "approved": False,
            "provider_name": provider.name,
            "medication_name": refill_request.medication_name,
            "dosage": refill_request.dosage,
            "reason": "Medication does not match patient record",
            "message": simulated_denial
        };
    }
}
