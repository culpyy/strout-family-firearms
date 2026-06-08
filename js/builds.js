// ─────────────────────────────────────────────
//  STROUT FAMILY FIREARMS — ACTIVE BUILD BOARD
//  Edit this file to update the In Shop page.
//
//  status options:
//    "intake"        — just received, being looked over
//    "parts-ordered" — waiting on parts to arrive
//    "in-progress"   — actively being worked on
//    "testing"       — on the range for function check
//    "ready"         — done, waiting for customer pickup
//
//  progress: 0–100 (percent complete, your best estimate)
//  eta: "YYYY-MM-DD" format, or "" to leave blank
//  notes: short public-facing note, or "" for none
// ─────────────────────────────────────────────

const builds = [
  {
    title: "HK21 Custom Build",
    type: "Light Machine Gun",
    caliber: "7.62×51 NATO",
    status: "ready",
    progress: 100,
    received: "2024-05-10",
    eta: "2024-06-05",
    notes: "Complete. Contact us to arrange pickup."
  },
  {
    title: "MP5 Build",
    type: "Submachine Gun",
    caliber: "9mm Parabellum",
    status: "ready",
    progress: 100,
    received: "2024-05-01",
    eta: "2024-04-18",
    notes: "Complete and function checked. Ready for pickup."
  },
  {
    title: "Custom AR-15",
    type: "Rifle",
    caliber: "5.56 NATO",
    status: "in-progress",
    progress: 60,
    received: "2024-05-28",
    eta: "2024-06-20",
    notes: "Upper assembled. Waiting on BCG."
  },
  {
    title: "Remington 870 Refurb",
    type: "Shotgun",
    caliber: "12 Gauge",
    status: "parts-ordered",
    progress: 20,
    received: "2024-06-01",
    eta: "2024-06-28",
    notes: "New stock and forend on order."
  },
  {
    title: "1911 Action Job",
    type: "Pistol",
    caliber: ".45 ACP",
    status: "intake",
    progress: 5,
    received: "2024-06-04",
    eta: "",
    notes: "Assessment in progress. Will call with quote."
  }
];
