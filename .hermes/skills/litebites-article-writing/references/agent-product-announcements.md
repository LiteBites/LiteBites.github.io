# Agent Product Announcement Review

Use this checklist for workplace agents, coding agents, computer-use agents, and other products that combine models with tools, connectors, memory, execution, and user interfaces.

## Separate the layers

Do not treat the product as a model release. Record each layer independently:

| Layer | Questions |
|---|---|
| Model | Which models or tiers are named? Is routing disclosed? Can models change during a task? |
| Orchestration | How are tasks, context, memory, retries, supervision, and failure recovery handled? |
| Tools and actions | What can the system read, write, execute, publish, or send? Which actions require approval? |
| Extensions | How are skills, plugins, MCP servers, repositories, or templates installed and triggered? |
| Connectors | Which business systems and messaging channels exchange data? What permissions and isolation rules apply? |
| Artifacts | Are outputs editable files, code, web apps, database-backed services, messages, or only text? |
| Governance | What data residency, retention, deletion, logging, administrator access, and audit claims are documented? |
| Economics | What pricing, credits, quotas, latency, and task-level cost are disclosed? |

A product capability does not establish model capability. Likewise, a model benchmark does not establish end-to-end product reliability.

## Preserve the timeline

Keep four dates distinct:

1. **Source publication date** — when the announcement was published.
2. **Article review date** — when the current product and documentation were inspected.
3. **Available-at-launch capability** — explicitly delivered in the announcement's stated geography and surface.
4. **Roadmap capability** — described as forthcoming, planned, or future.

Current documentation may contain features added after the announcement. Introduce those as “current documentation states” and do not back-project them into the launch. Conversely, do not continue calling a capability “forthcoming” when current official documentation shows that some or all of it has shipped. When rollout is partial, name the delivered surface and the still-unverified remainder precisely—for example, desktop collaboration access may be current while mobile embedding remains roadmap. Avoid vague catchalls such as “deeper integration.”

Reconcile enumerations rather than silently selecting one snapshot:

- If the announcement names four model tiers but current workflow documentation exposes only two, report both scopes and the unresolved discrepancy.
- Preserve exact connector/channel rows; do not collapse separately listed products or regional variants into a slash-combined label.
- Distinguish a mobile application from a client for a desktop-class operating system, even when the operating-system family also appears on mobile devices.
- Scope privacy, residency, retention, and security statements to the surfaces and audiences named by the policy. A web- or collaboration-specific policy does not automatically cover desktop clients, third-party connectors, or installed extensions.

When the user says they read an older source “today,” use today's date for `date` and `last_reviewed`, while preserving the source's original date in `source_published`.

## Classify provider evidence

Provider announcements, product pages, help centers, privacy pages, and security pages are primary sources for what the provider states—not independent verification of reliability, safety, market leadership, or control effectiveness.

Use explicit language:

- “The announcement says…” for launch scope.
- “Current documentation lists…” for present product behavior.
- “The provider describes…” for security controls.
- “This review did not identify an independent audit/benchmark…” when corroboration is unavailable.

Do not imply absence everywhere from a bounded source review. Prefer: “The reviewed public materials do not disclose…”

## Permission and data-flow audit

For every connector, desktop action, extension, and collaboration channel, ask:

- What can it read, write, transmit, install, execute, or publish?
- Is access opt-in, organization-controlled, or open by default?
- Are contexts isolated across users, chats, organizations, and connectors?
- Can a remote message trigger local or cloud actions?
- Are third-party extensions reviewed, signed, sandboxed, or automatically triggered?
- Where are user content and logs stored, and how are deletion and retention handled?
- Does the provider itself warn against sensitive inputs or require human review?

Treat documentation of encryption, access control, logging, or penetration testing as provider claims unless an independently inspectable audit or certification is verified.

## Minimum evidence for the Article Bite

Before drafting, capture:

- canonical announcement title, publisher, URL, and exact date;
- official product page and current technical documentation;
- launch geography and interfaces;
- delivered versus planned features;
- model names/tiers and any boundary between hosted product and model;
- action surfaces, connectors, skills/extensions, and artifacts;
- data handling and governance statements;
- benchmarks, traces, reliability measurements, and cost evidence—or their documented absence;
- independent corroboration where available.

## Practical framing

A strong Article Bite usually centers on one of these questions:

- Is the novelty the model, the orchestration layer, or integration breadth?
- What changes when the assistant can create artifacts and execute actions?
- Which permission and governance boundaries expand with connectors and skills?
- What evidence would establish reliability beyond a feature list?

End with deployment checks: representative workflow tests, approval gates, retry behavior, artifact accuracy, latency and credits, connector permissions, data residency, retention, administrator access, and audit logs.
