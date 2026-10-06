/// Client-side input patterns (QA M-01/M-08): catch obvious typos before a
/// server round-trip. The API stays the source of truth for real validation.
library;

/// Plausible email: non-empty local part, at least one non-empty domain
/// label before the TLD. Rejects `ben1@` and `sharif@.edu`.
final kEmailPattern = RegExp(r'^[\w.%+-]+@(?:[\w-]+\.)+[A-Za-z]{2,}$');
