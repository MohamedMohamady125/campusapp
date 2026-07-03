// k6 smoke test (spec §14 M8): quick perf gate against a running API.
// Usage: make k6-smoke   (or: k6 run infra/k6/smoke.js -e BASE_URL=http://localhost:8000)
import http from "k6/http";
import { check, sleep } from "k6";

const BASE = __ENV.BASE_URL || "http://localhost:8000";

export const options = {
  vus: 5,
  duration: "30s",
  thresholds: {
    http_req_failed: ["rate<0.01"],
    http_req_duration: ["p(95)<250"], // spec §7: p95 API < 250ms
  },
};

export default function () {
  const health = http.get(`${BASE}/api/v1/health`);
  check(health, { "health 200": (r) => r.status === 200 });

  const ready = http.get(`${BASE}/api/v1/health/ready`);
  check(ready, { "ready 200": (r) => r.status === 200 });

  const flags = http.get(`${BASE}/api/v1/flags`);
  check(flags, { "flags 200": (r) => r.status === 200 });

  // Unauthenticated listing browse must 401 fast (authz cost, not a crash).
  const listings = http.get(`${BASE}/api/v1/listings`);
  check(listings, { "listings gated": (r) => r.status === 401 });

  sleep(1);
}
