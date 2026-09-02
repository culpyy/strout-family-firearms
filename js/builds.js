// ─────────────────────────────────────────────
//  STROUT FAMILY FIREARMS — ACTIVE BUILD BOARD
//  Edit this file to update the In Shop page.
//
//  status options (in order):
//    "intake"        — just received, being assessed
//    "parts-ordered" — waiting on parts to arrive
//    "in-progress"   — actively being worked on
//    "testing"       — on the range for function check
//    "atf-filed"     — build done, ATF transfer paperwork submitted
//    "atf-approved"  — ATF approved, cleared to transfer
//    "ready"         — ready for pickup or shipping to customer FFL
//
//  atf_form: "Form 3", "Form 4", "Form 1", etc. — leave "" if not an NFA item
//  atf_filed: "YYYY-MM-DD" — date ATF paperwork was submitted, or "" if not filed yet
//
//  progress: 0–100 (percent complete, your best estimate)
//  eta: "YYYY-MM-DD" format, or "" to leave blank
//  notes: short public-facing note, or "" for none
// ─────────────────────────────────────────────

const builds = [
  {
    title: "Vickers Mk.I Restoration",
    type: "Water-Cooled HMG",
    caliber: ".303 British",
    status: "atf-filed",
    progress: 95,
    received: "2026-04-15",
    eta: "2026-07-15",
    atf_form: "Form 3",
    atf_filed: "2026-06-05",
    notes: "Build complete. Range session done, timing and headspace verified. ATF Form 3 submitted. Awaiting approval to transfer."
  },
  {
    title: "SBR Form 1 Build",
    type: "Short-Barreled Rifle",
    caliber: ".300 Blackout",
    status: "in-progress",
    progress: 65,
    received: "2026-05-02",
    eta: "2026-06-28",
    atf_form: "Form 1",
    atf_filed: "",
    notes: "Form 1 pre-approved by ATF. Upper build in progress."
  },
  {
    title: "HK MP5 Parts Kit Build",
    type: "Submachine Gun",
    caliber: "9mm Parabellum",
    status: "in-progress",
    progress: 45,
    received: "2026-05-10",
    eta: "2026-07-10",
    atf_form: "",
    atf_filed: "",
    notes: "Receiver work done. Parts kit fitting in progress."
  },
  {
    title: "Custom 1911 Full Build",
    type: "Pistol",
    caliber: ".45 ACP",
    status: "parts-ordered",
    progress: 20,
    received: "2026-05-20",
    eta: "2026-07-18",
    atf_form: "",
    atf_filed: "",
    notes: "Barrel, slide, and frame on order. Will call when parts arrive."
  },
  {
    title: "Remington 700 Precision Build",
    type: "Bolt-Action Rifle",
    caliber: ".308 Winchester",
    status: "intake",
    progress: 5,
    received: "2026-06-05",
    eta: "",
    atf_form: "",
    atf_filed: "",
    notes: "Assessment in progress. Quote within 48 hours."
  }
];
