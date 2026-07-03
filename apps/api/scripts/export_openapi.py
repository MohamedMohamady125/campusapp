"""Export the OpenAPI contract to contracts/openapi.json (spec §2.3, §4.3)."""

import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from app.main import create_app


def main() -> None:
    out = Path(__file__).resolve().parents[3] / "contracts" / "openapi.json"
    spec = create_app().openapi()
    out.write_text(json.dumps(spec, indent=2, sort_keys=True) + "\n")
    print(f"wrote {out}")


if __name__ == "__main__":
    main()
