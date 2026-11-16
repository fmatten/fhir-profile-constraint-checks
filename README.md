# FHIR profile constraint checks: measured gaps

Reproduction material for three measurements on FHIR R4 profiling tools, taken on 16 November 2026 with SUSHI 3.21.0 and the HL7 FHIR Validator 6.10.4. Everything here is synthetic: example profiles on `Observation`, example instances, no patient data, no production profiles.

Reported as:

- SUSHI issue: https://github.com/FHIR/sushi/issues/1663 (caret value rules bypass constraining checks)
- HL7 Jira FHIR-59871: FHIR Shorthand Language Reference, Caret Paths section
- HL7 Jira FHIR-59872: FHIR Core, binding-to-ConceptMap links carry no conformance meaning
- HL7 Jira FHIR-59873: FHIR Core, extensible bindings and the "no applicable concept" decision
- HL7 Jira FHIR-59874: FHIR Extensions Pack, a derivation obligation

## 1. `sushi-caret/`: SUSHI does not apply constraining rules to caret assignments

Seven profiles on `Observation` in `input/fsh/profiles.fsh`. Two of them use the dedicated FSH rules to weaken the parent (controls), four do the same thing through caret value rules.

| Profile | Rule | SUSHI 3.21.0 | Validator 6.10.4 on the SUSHI output |
|---|---|---|---|
| P1 | `* status from … (example)` on a required binding | error (control) | – |
| P5 | `* code 0..*` on 1..1 | error (control) | – |
| P2 | `* status ^binding.strength = #example` | exported, no error, no warning | error: illegal attempt to change the binding from required to example |
| P3 | `* code ^min = 0`, `* code ^max = "*"` | exported, no error | error: derived min/max outside the base |
| P4 | `* interpretation ^meaningWhenMissing = "…"` | exported, no error | error: meaningWhenMissing is not allowed in a profile |
| P6b | `* code ^mustSupport = false` against a parent profile with `* code MS` | exported, no error | error: must-support = false when true in the base profile |

Reproduce:

```
cd sushi-caret
sushi .                 # SUSHI 3.21.0; FSHOnly: true, so no snapshot is generated
java -jar validator_cli.jar fsh-generated/resources/StructureDefinition-p2-caret-weaken-binding.json -version 4.0.1
```

`expected-output/` holds the StructureDefinitions SUSHI produced. `sushi-run.log` and `validator-on-sushi-output.log` are the raw logs (paths shortened, validator messages in German locale).

Where SUSHI runs together with the IG Publisher or the validator, the invalid profiles are caught there. Where SUSHI runs alone, they are shipped silently.

## 2. `validator-derived-profiles/`: what the validator catches in a hand-written differential

Three StructureDefinitions written by hand (not through SUSHI), each derived from `Observation`:

| File | Change | Validator 6.10.4 |
|---|---|---|
| `sd-weaken-binding.json` | status binding required → example | error |
| `sd-widen-card.json` | code 1..1 → 0..* | error |
| `sd-meaningwhenmissing.json` | meaningWhenMissing set in a profile | error |

`validator-run-meaningwhenmissing.log` is one full run. These are the positive controls for section 1: the validator does have the checks that SUSHI skips for caret rules.

## 3. `validator-extensible-binding/`: an outside code under an extensible binding

`Observation.interpretation` is bound extensibly in R4. Three instances:

| File | Code | Validator 6.10.4 |
|---|---|---|
| `obs-code-in-valueset.json` | `H` from the bound value set | success, no binding message |
| `obs-outside-code.json` | local code `XY` from `http://fhir.hospital-x.test/CodeSystem/interpretation` | success, one warning: none of the codes are in the value set, and a code should come from it unless it has no suitable code |
| `obs-outside-code-with-text.json` | same local code plus `text` | success, the identical warning |

The validator cannot tell a justified alternate concept from an unjustified one, because nothing in the instance lets it. That is the point of FHIR-59873.

Reproduce:

```
cd validator-extensible-binding
java -jar validator_cli.jar obs-outside-code.json -version 4.0.1 -tx n/a
```

## What is not claimed

- No statement about how often this occurs in published implementation guides; nothing was counted.
- Validation is meant to cover only the computable aspects of conformance (validation.html). The tickets propose making one more aspect computable where a mapping is declared; they do not devalue validators.
- Measured versions only: SUSHI 3.21.0 (FSH spec 3.0.0), validator 6.10.4 with `-version 4.0.1`. Other versions were not measured.

## Author and licence

Friedhelm Matten, ISCaD GmbH, Wedemark. Licence: MIT (see `LICENSE`). Measurements and texts may be reused with attribution.
