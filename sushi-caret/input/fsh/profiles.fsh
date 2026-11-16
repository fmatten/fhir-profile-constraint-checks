// P1 Kontrolle: Binding-Abschwächung mit dedizierter Regel (erwartet: SUSHI-Fehler)
Profile: P1DedicatedWeakenBinding
Parent: Observation
Id: p1-dedicated-weaken-binding
* status from http://hl7.org/fhir/ValueSet/observation-status (example)

// P2 Messung: Binding-Abschwächung per Caret
Profile: P2CaretWeakenBinding
Parent: Observation
Id: p2-caret-weaken-binding
* status ^binding.strength = #example

// P3 Messung: Kardinalitätserweiterung per Caret
Profile: P3CaretWidenCardinality
Parent: Observation
Id: p3-caret-widen-cardinality
* code ^min = 0
* code ^max = "*"

// P4 Messung: meaningWhenMissing per Caret im Profil (FSH-Spec-Beispiel; R4 verbietet es in Profilen)
Profile: P4CaretMeaningWhenMissing
Parent: Observation
Id: p4-caret-meaningwhenmissing
* interpretation ^meaningWhenMissing = "Wenn fehlend: Befund unauffällig."

// P5 Kontrolle: Kardinalitätserweiterung mit dedizierter Regel (erwartet: SUSHI-Fehler)
Profile: P5DedicatedWidenCardinality
Parent: Observation
Id: p5-dedicated-widen-cardinality
* code 0..*

// P6 Messung: mustSupport true→false per Caret auf Kindprofil
Profile: P6aParentMS
Parent: Observation
Id: p6a-parent-ms
* code MS

Profile: P6bCaretUnsetMS
Parent: P6aParentMS
Id: p6b-caret-unset-ms
* code ^mustSupport = false
