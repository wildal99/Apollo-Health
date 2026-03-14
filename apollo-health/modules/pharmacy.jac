"""Pharmacy module for Apollo Infrastructure."""

node Pharmacy {
    has name: str;
    has phone_number: str;
    has address: str;
    has distance_miles: float;
    has insurance_accepted: list[str] = [];
    has inventory: dict = {};
}

node Medication {
    has name: str;
    has dosage: str;
    has form: str = "unknown";
}

obj PharmacyResult {
    has pharmacy_name: str;
    has phone_number: str;
    has address: str;
    has distance_miles: float;
    has stock_status: str;
    has quantity_available: int;
    has hold_available: bool;
    has notes: str;
}

obj BestPharmacySummary {
    has found: bool;
    has best_option: PharmacyResult;
    has all_results: list[PharmacyResult];
    has recommended_next_step: str;
}

walker PharmacyService {
    has pharmacies: list[Pharmacy] = [];
    has medication: Medication;
    has patient_insurance: str = "";

    """Check stock at one pharmacy for the requested medication and dosage."""
    def check_single_pharmacy(pharmacy: Pharmacy) -> PharmacyResult {
        med_key = f"{self.medication.name}|{self.medication.dosage}";
        inventory_info = pharmacy.inventory[med_key] if med_key in pharmacy.inventory else null;

        if inventory_info == null {
            return PharmacyResult(
                pharmacy_name=pharmacy.name,
                phone_number=pharmacy.phone_number,
                address=pharmacy.address,
                distance_miles=pharmacy.distance_miles,
                stock_status="out of stock",
                quantity_available=0,
                hold_available=False,
                notes="Medication/dosage not currently available at this location."
            );
        }

        qty = inventory_info["quantity"] if "quantity" in inventory_info else 0;
        hold_ok = inventory_info["hold_available"] if "hold_available" in inventory_info else False;

        if qty <= 0 {
            return PharmacyResult(
                pharmacy_name=pharmacy.name,
                phone_number=pharmacy.phone_number,
                address=pharmacy.address,
                distance_miles=pharmacy.distance_miles,
                stock_status="out of stock",
                quantity_available=0,
                hold_available=hold_ok,
                notes="Currently unavailable. Ask pharmacy about restock timing."
            );
        }

        if qty < 5 {
            return PharmacyResult(
                pharmacy_name=pharmacy.name,
                phone_number=pharmacy.phone_number,
                address=pharmacy.address,
                distance_miles=pharmacy.distance_miles,
                stock_status="low stock",
                quantity_available=qty,
                hold_available=hold_ok,
                notes="Limited quantity available. Call ahead before pickup."
            );
        }

        return PharmacyResult(
            pharmacy_name=pharmacy.name,
            phone_number=pharmacy.phone_number,
            address=pharmacy.address,
            distance_miles=pharmacy.distance_miles,
            stock_status="in stock",
            quantity_available=qty,
            hold_available=hold_ok,
            notes="Medication is available now."
        );
    }

    """Sort results so the best options appear first."""
    def score_result(result: PharmacyResult) -> int {
        if result.stock_status == "in stock" {
            return 3;
        }
        if result.stock_status == "low stock" {
            return 2;
        }
        return 1;
    }

    """Pick the best pharmacy result based on stock and distance."""
    def choose_best(results: list[PharmacyResult]) -> PharmacyResult {
        best = results[0];

        for r in results {
            current_score = self.score_result(r);
            best_score = self.score_result(best);

            if current_score > best_score {
                best = r;
            }
            elif current_score == best_score and r.distance_miles < best.distance_miles {
                best = r;
            }
        }

        return best;
    }

    """Check all pharmacies and return a patient-friendly summary."""
    def check_stock_all() -> BestPharmacySummary {
        results = [];

        for pharmacy in self.pharmacies {
            result = self.check_single_pharmacy(pharmacy);
            results.append(result);
        }

        if len(results) == 0 {
            return BestPharmacySummary(
                found=False,
                best_option=PharmacyResult(
                    pharmacy_name="None",
                    phone_number="",
                    address="",
                    distance_miles=0.0,
                    stock_status="out of stock",
                    quantity_available=0,
                    hold_available=False,
                    notes="No pharmacies were provided."
                ),
                all_results=[],
                recommended_next_step="Add pharmacy data and try again."
            );
        }

        best = self.choose_best(results);

        if self.score_result(best) == 1 {
            return BestPharmacySummary(
                found=False,
                best_option=best,
                all_results=results,
                recommended_next_step="No nearby pharmacy currently has this medication and dosage in stock. Suggest checking restock timing or expanding the search radius."
            );
        }

        return BestPharmacySummary(
            found=True,
            best_option=best,
            all_results=results,
            recommended_next_step="Recommend the best pharmacy to the patient and offer to call ahead or place a hold if available."
        );
    }
}
