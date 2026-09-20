# Seedance 2.5 API (seedance-2.5)

<!-- conv-kit:v1 -->

<p align="center">
  <img src="assets/badges/price.svg" alt="observed unit price"> <img src="assets/badges/billing.svg" alt="billing model"> <img src="assets/badges/compat.svg" alt="OpenAI-compatible endpoint">
</p>

<p align="center">
  <img src="assets/02-fashion-edit-extension-thumb.jpg" width="820" alt="Seedance 2.5 (seedance-2.5) output generated through APIMart">
</p>

> **from $0.0961 per second** at 480P — one OpenAI-compatible endpoint at `https://api.apimart.ai/v1`, no monthly plan required. *(observed 2026-09-17)*

**[Get an API key](https://go.apimart.ai/k-155ed4)** · **[Live pricing](https://go.apimart.ai/k-0fa1c2)** · **[Model page](https://go.apimart.ai/k-70b3b8)** · [⚡ 60-second quickstart](#quickstart)

**Why teams call Seedance 2.5 (`seedance-2.5`) through APIMart**

- **One key, entire catalog.** The same `https://api.apimart.ai/v1` base URL and `Authorization` header reach Seedance 2.5 (`seedance-2.5`) and 300+ other image, video and language models — switch the `model` field, not your client.
- **$1 minimum, pay as you go.** No subscription and no prepaid plan to size up front: top up from $1 and spend it on calls. There is no free quota to burn through first, so the price in this table is the price you pay.
- **The charge comes back in the response.** Every call reports the amount billed (`cost` / `credits_cost`), so a spend number is read per call instead of guessed at month end.
- **Async by design.** Submit, take the `task_id`, poll `GET /v1/tasks/{id}` — batching and retries are ordinary queue work, not a bespoke integration.

<!-- /conv-kit:v1 -->

Seedance 2.5 is the longer-form video route: up to 30 seconds per job, up to 30 images + 10 videos + 10 audios as references, 480p/720p/1080p, and `mp4` or higher-precision `mov` output.

## Model id and routes

| Route | `model` value | Billing | Notes |
| --- | --- | --- | --- |
| Per-image (default here) | `seedance-2.5` | per delivered image, by resolution | alias `` is documented as equivalent |
| Token-billed official | `` | per million tokens | no `official_fallback` on this id |

Endpoint: `POST https://api.apimart.ai/v1/videos/generations` (OpenAI-compatible), then poll `GET /v1/tasks/{task_id}`.
Result links are valid for 24 hours.

## Pricing

<!-- pricing:model:start -->
| Output | List price | Effective price |
| --- | --- | --- |
| default | $0.27 | $0.216 |
| 1080P | $0.4811 | $0.3849 |
| 1080P-input | $0.2874 | $0.2299 |
| 480P | $0.1201 | $0.0961 |
| 480P-input | $0.072 | $0.0576 |
| 720P | $0.27 | $0.216 |
| 720P-input | $0.162 | $0.1296 |

<!-- conv-kit:v1:scale -->
### What that costs at scale

| Spend | Cost |
| --- | --- |
| 1 minute video seconds | $5.77 |
| 10 minutes video seconds | $57.66 |
| 60 minutes video seconds | $345.96 |

Linear at the observed per-unit rate, no volume discount assumed. Snapshot 2026-09-17; re-check the live table before committing a budget.
<!-- /conv-kit:v1:scale -->


<!-- pricing:model:end -->

Prices are a snapshot; the [pricing page](https://go.apimart.ai/k-0fa1c2) and [`data/model.json`](data/model.json) are refreshed by
CI, and a completed task reports the exact amount in its `cost` field.

## Request parameters

| Field | Type | Default | Notes |
| --- | --- | --- | --- |
| `model` | string | required | `seedance-2.5` |
| `prompt` | string | required | reference media with `@图片1` / `@视频1` / `@音频1` (1-based, matching array order) |
| `duration` | integer | `5` | 4–30 seconds; `-1` lets the model choose (pre-charged at the 30s cap, settled after) |
| `resolution` | string | `720p` | **only** `480p`, `720p`, `1080p` — `2k`/`4k` return a synchronous 400 |
| `size` | string | `adaptive` | `16:9`, `4:3`, `1:1`, `3:4`, `9:16`, `21:9`, `adaptive` (`aspect_ratio` also accepted) |
| `generate_audio` | boolean | `true` | alias `audio`; per-second price is unchanged |
| `watermark` | boolean | `false` | adds an “AI generated” watermark |
| `output_format` | string | `mp4` | `mov` keeps higher colour precision — recommended for edit/extend |
| `omni_reference_task_type` | string | `auto` | `auto` / `reference` / `edit` / `extend`; explicit values validate at submit time |
| `image_urls` | string[] | — | reference images (up to 30); use `image_with_roles` for first/last frame |
| `video_urls` | string[] | — | reference videos (up to 10) |
| `audio_urls` | string[] | — | reference audio (up to 10, each 2–30s); audio-only reference is supported |
| `return_last_frame` | boolean | `false` | returns the last frame for chaining |
| `seed` | integer | — | same seed is similar, not guaranteed identical |

Supported aspect ratios: `16:9`, `4:3`, `1:1`, `3:4`, `9:16`, `21:9`, `adaptive`.

## Quickstart

```bash
curl --request POST --url https://api.apimart.ai/v1/images/generations \
  --header "Authorization: Bearer $APIMART_API_KEY" --header 'Content-Type: application/json' \
  -d '{"model":"seedance-2.5","prompt":"A bamboo forest path under moonlight","size":"1:1","resolution":"1K","n":1}'
```

```python
import os, time, requests

BASE = "https://api.apimart.ai/v1"
HEADERS = {"Authorization": f"Bearer {os.environ['APIMART_API_KEY']}", "Content-Type": "application/json"}

created = requests.post(f"{BASE}/images/generations", headers=HEADERS, timeout=60, json={
    "model": "seedance-2.5", "prompt": "A bamboo forest path under moonlight",
    "size": "1:1", "resolution": "1K", "n": 1,
}).json()
task_id = created["data"]["id"]

while True:
    task = requests.get(f"{BASE}/tasks/{task_id}", headers=HEADERS, timeout=60).json()["data"]
    if task["status"] in ("completed", "failed"):
        break
    time.sleep(5)
print(task.get("cost"), task.get("result", {}).get("images", [{}])[0].get("url"))
```

```javascript
const res = await fetch("https://api.apimart.ai/v1/images/generations", {
  method: "POST",
  headers: { Authorization: `Bearer ${process.env.APIMART_API_KEY}`, "Content-Type": "application/json" },
  body: JSON.stringify({ model: "seedance-2.5", prompt: "A bamboo forest path under moonlight",
                          size: "1:1", resolution: "1K", n: 1 }),
});
const { data } = await res.json();      // data.id is the task id — poll /v1/tasks/<id>
```

Runnable versions: [`examples/`](examples). The task lifecycle is `pending → processing → completed | failed`, and the
finished task carries `cost`, `credits_cost` and expiring result URLs.

## Sample outputs

Every render below came from a single call with the model id above, at the ratio shown; the cost column is what the task
reported.

| Preview | Recipe | Ratio | Duration | Cost | Prompt |
| --- | --- | --- | --- | --- | --- |
| <img src="assets/02-fashion-edit-extension-thumb.jpg" width="220" alt="Seedance 2.5 video preview"><br>[watch mp4](assets/02-fashion-edit-extension.mp4) | Fashion | 9:16 | 5s | $0.4844 | `Vertical fashion clip: model in an ivory trench coat turns slowly on a sunlit stone street, fabric moves in the breeze, camera orbits a quarter turn, natural light` |
| <img src="assets/03-audio-ready-talking-head-thumb.jpg" width="220" alt="Seedance 2.5 video preview"><br>[watch mp4](assets/03-audio-ready-talking-head.mp4) | Talking head | 16:9 | 5s | $0.4844 | `Studio talking-head setup of a presenter at a desk with a soft key light, subtle handheld motion, neutral background, natural skin tones, clean framing` |
| <img src="assets/01-steampunk-miniature-thumb.jpg" width="220" alt="Seedance 2.5 video preview"><br>[watch mp4](assets/01-steampunk-miniature.mp4) | Miniature world | 16:9 | 5s | $0.4844 | `Cinematic miniature steampunk landscape: tiny brass airships above a clockwork city, slow crane move revealing the valley, warm volumetric light, shallow depth of field` |

Recipes and measured costs are also in [`data/samples.json`](data/samples.json).

<!-- conv-kit:v1:fix -->
## First-call troubleshooting

| Symptom | Likely cause | Fix |
| --- | --- | --- |
| `401` / `invalid api key` | key missing, truncated, or a stray newline pasted into the header | Re-copy it from the console; the header is `Authorization: Bearer $APIMART_API_KEY` |
| balance / credit error | the account has no balance | Top up from $1 in the console — there is no free quota to fall back on |
| `429` | concurrent requests on one key | Back off, then retry the same request with the same `Idempotency-Key` |
| `400` / model not found | wrong route for the id: the per-unit alias needs its `version`, the official id must not send one | Copy the exact `model` value from the route table above |
| task ends `failed` | prompt rejected by the filter, or a reference image URL expired | Re-submit with a **new** `Idempotency-Key` and re-host the reference image |
| result URL stops working | result links expire | Download the file as soon as the task reports `completed` |
<!-- /conv-kit:v1:fix -->

## FAQ

**How is Seedance 2.5 billed?**

Per second of output, by resolution tier (see the table above). Longer clips and higher resolution tiers cost more per job; `duration: -1` pre-charges at the 30-second cap and settles to the actual length.

**What is different from Seedance 2.0?**

2.5 raises the ceiling: 30 seconds per job instead of 15, up to 30 image + 10 video + 10 audio references, and a higher-precision `mov` output. 2.0 is the model to use when you need 4K output.

**How do I reference the uploaded media in the prompt?**

Use one-based tokens (`@图片1`, `@视频1`, `@音频1`) that match the order of `image_urls`, `video_urls` and `audio_urls`. Mismatched indices are the most common cause of a confusing result.

**Can I edit or extend an existing video?**

Yes — set `omni_reference_task_type` to `edit` or `extend` (explicit values are validated at submit time) and pass the source clip through `video_urls`. `return_last_frame` chains consecutive generations.

## Related searches

- `seedance 2.5 api`
- `seedance 2.5 pricing`
- `long video generation api`
- `video editing api`
- `reference video api`
- `ai video generation cost`
- `text to video api`

<!-- conv-kit:v1:cta -->
---

**Start with $1.** [Get an API key](https://go.apimart.ai/k-155ed4) → [check live pricing](https://go.apimart.ai/k-0fa1c2) → [open Seedance 2.5 (`seedance-2.5`) in the model library](https://go.apimart.ai/k-70b3b8). The first call is three steps: submit, poll `task_id`, read the charged amount off the response.
<!-- /conv-kit:v1:cta -->

## Attributed links (how this repository is measured)

| Purpose | Attributed link | Target |
| --- | --- | --- |
| Open Seedance 2.5 on APIMart | <https://go.apimart.ai/k-70b3b8> | `docs.apimart.ai` model page |
| Current pricing page | <https://go.apimart.ai/k-0fa1c2> | `apimart.ai/pricing` |
| Get an API key | <https://go.apimart.ai/k-155ed4> | `apimart.ai/keys` |

Outbound APIMart links are minted through the promo link API; hand-made tracking parameters are rejected by
`tools/check_links.py` in CI.

## Disclosure

Seedance 2.5 is a third-party model served through APIMart; this repository documents how to call it and publishes
real outputs, model ids and prices, and does not claim official status. Model names, prices and documentation belong to
their respective owners. Endpoint reference: [https://docs.apimart.ai/en/api-reference/videos/seedance-2-5/generation](https://docs.apimart.ai/en/api-reference/videos/seedance-2-5/generation).

## Repository map

```text
README.md             model id, pricing, parameters, quickstart, samples, FAQ
data/model.json       the pricing record for this model (CI-refreshed)
data/samples.json     prompt recipes with measured cost
tools/snapshot.py     refresh this model's prices from the public pricing payload
tools/check_links.py  attribution guard
examples/             curl, Python and JavaScript clients
assets/               real sample renders (JPEG, resized for the README)
.github/workflows/    daily price refresh + validation
```

## License

MIT — see [LICENSE](LICENSE).
