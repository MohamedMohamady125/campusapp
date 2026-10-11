// k6 smoke test (spec §14 M8): quick perf gate against a running API.
// Usage: make k6-smoke   (or: k6 run infra/k6/smoke.js -e BASE_URL=http://localhost:8000)
// Pass LOGIN_EMAIL/LOGIN_PASSWORD to also exercise the authenticated runs
// hot path (feed + catalogs) — the endpoints thousands of clients poll.
import http from "k6/http";
import { check, sleep } from "k6";

const BASE = __ENV.BASE_URL || "http://localhost:8000";
const EMAIL = __ENV.LOGIN_EMAIL || "";
const PASSWORD = __ENV.LOGIN_PASSWORD || "";

export const options = {
  vus: 5,
  duration: "30s",
  thresholds: {
    http_req_failed: ["rate<0.01"],
    http_req_duration: ["p(95)<250"], // spec §7: p95 API < 250ms
  },
};

export function setup() {
  if (!EMAIL) return { token: null };
  const resp = http.post(
    `${BASE}/api/v1/auth/login`,
    JSON.stringify({ email: EMAIL, password: PASSWORD }),
    { headers: { "Content-Type": "application/json" } },
  );
  check(resp, { "login 200": (r) => r.status === 200 });
  return { token: resp.json("access_token") };
}

export default function (data) {
  const health = http.get(`${BASE}/api/v1/health`);
  check(health, { "health 200": (r) => r.status === 200 });

  const ready = http.get(`${BASE}/api/v1/health/ready`);
  check(ready, { "ready 200": (r) => r.status === 200 });

  const flags = http.get(`${BASE}/api/v1/flags`);
  check(flags, { "flags 200": (r) => r.status === 200 });

  // Unauthenticated listing browse must 401 fast (authz cost, not a crash).
  // The 401 is the expected outcome — don't count it against req_failed.
  const listings = http.get(`${BASE}/api/v1/listings`, {
    responseCallback: http.expectedStatuses(401),
  });
  check(listings, { "listings gated": (r) => r.status === 401 });

  if (data.token) {
    const auth = { headers: { Authorization: `Bearer ${data.token}` } };

    // The feed every client polls on a 10s interval.
    const feed = http.get(`${BASE}/api/v1/runs`, auth);
    check(feed, { "runs feed 200": (r) => r.status === 200 });

    // Redis-cached catalogs behind the create/request sheets.
    const spots = http.get(`${BASE}/api/v1/runs/spots`, auth);
    check(spots, { "spots 200": (r) => r.status === 200 });
    const dropoffs = http.get(`${BASE}/api/v1/runs/dropoffs`, auth);
    check(dropoffs, { "dropoffs 200": (r) => r.status === 200 });

    const mine = http.get(`${BASE}/api/v1/runs/mine`, auth);
    check(mine, { "my runs 200": (r) => r.status === 200 });
  }

  sleep(1);
}
