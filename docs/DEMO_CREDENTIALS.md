# Demo login credentials (local seed data only)

All 20 seeded demo users share the same password and are already
email-verified — sign in directly, no verification code needed.

**Password for every account:** `Password123!`

| # | Email | Display name |
|---|-------|--------------|
| 1 | ava0@campus.edu | Ava A. |
| 2 | ben1@campus.edu | Ben B. |
| 3 | chloe2@campus.edu | Chloe C. |
| 4 | dan3@campus.edu | Dan D. |
| 5 | ella4@campus.edu | Ella E. |
| 6 | finn5@campus.edu | Finn F. |
| 7 | grace6@campus.edu | Grace G. |
| 8 | hugo7@campus.edu | Hugo H. |
| 9 | iris8@campus.edu | Iris I. |
| 10 | jack9@campus.edu | Jack J. |
| 11 | kara10@campus.edu | Kara K. |
| 12 | liam11@campus.edu | Liam L. |
| 13 | maya12@campus.edu | Maya M. |
| 14 | noah13@campus.edu | Noah N. |
| 15 | olive14@campus.edu | Olive O. |
| 16 | pete15@campus.edu | Pete P. |
| 17 | quinn16@campus.edu | Quinn Q. |
| 18 | rosa17@campus.edu | Rosa R. |
| 19 | sam18@campus.edu | Sam S. |
| 20 | tess19@campus.edu | Tess T. |

## Notes

- Source of truth: `apps/api/app/seed.py` (`_FIRST` list +
  `hash_password("Password123!")`). Re-running the seed recreates these.
- Backend must be running: `make infra-up`, then uvicorn on `:8000`.
- Simulator/desktop uses `http://localhost:8000`; the Android emulator
  needs `API_BASE_URL=http://10.0.2.2:8000`.
- These are local development fixtures only — never reuse this password
  or these accounts outside your machine.
