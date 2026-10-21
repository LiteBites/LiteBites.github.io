---
layout: article
title: "Wabi's Pivot: The AI Assistant Makes the App"
short_title: "Wabi: Apps Inside the Chat"
date: 2026-10-21
type: "Article Bite"
read_time: "3 min read"
source_name: "TechCrunch"
source_url: "https://techcrunch.com/2026/10/19/replikas-founder-built-the-ai-assistant-she-pitched-at-disrupt-12-years-ago/"
source_published: 2026-10-19
last_reviewed: 2026-10-21
tags:
  - AI Agents
  - Generative UI
summary: "Wabi has shifted from sharing user-made mini-apps to an assistant that puts task-specific interfaces in group chats; its actions and data boundaries matter more than the demo."
additional_sources:
  - name: "Wabi product page"
    url: "https://wabi.ai/"
  - name: "Wabi terms and action permissions"
    url: "https://wabi.ai/terms"
  - name: "Wabi privacy notice and model-provider disclosures"
    url: "https://wabi.ai/privacy"
  - name: "TechCrunch's original mini-app platform coverage"
    url: "https://techcrunch.com/2025/11/05/replika-founder-raises-20m-pre-seed-for-wabi-the-youtube-of-apps/"
---
**The quick take:** Wabi has moved from asking people to make and share mini-apps to offering an AI assistant that can put app-like interfaces inside shared conversations. That is a change in *who does the building* and *where the result lives*—not proof that the assistant can reliably complete the task behind the interface.

[TechCrunch reported](https://techcrunch.com/2026/10/19/replikas-founder-built-the-ai-assistant-she-pitched-at-disrupt-12-years-ago/) Wabi's public launch in this form on October 19, 2026. Founder Eugenia Kuyda calls the change an evolution. The older [mini-app pitch](https://techcrunch.com/2025/11/05/replika-founder-raises-20m-pre-seed-for-wabi-the-youtube-of-apps/) was closer to a social platform for prompting, sharing, and remixing small apps. The current [homepage](https://wabi.ai/) leads with “the AI assistant you use together.”

## From an app feed to a group thread

This is a **source-grounded comparison of two product descriptions**, not a test of either version:

<div class="paper-results-scroll" role="region" aria-label="Wabi's earlier mini-app pitch compared with its October 2026 assistant" tabindex="0">
  <table class="paper-results-table">
    <caption>What changed in Wabi's pitch; swipe horizontally on small screens.</caption>
    <thead><tr><th scope="col">Question</th><th scope="col">Earlier mini-app pitch</th><th scope="col">October 2026 product</th></tr></thead>
    <tbody>
      <tr><th scope="row">Who initiates an app?</th><td>A person prompts a mini-app to create and share.</td><td>The assistant can decide when a task needs an interface.</td></tr>
      <tr><th scope="row">Where is it used?</th><td>A social platform organized around apps and remixing.</td><td>Within a task thread that can also be a group chat.</td></tr>
      <tr><th scope="row">What is the broader job?</th><td>Make personal software people want to use.</td><td>Help people coordinate and act through connected services.</td></tr>
    </tbody>
  </table>
</div>

That last row is the important expansion. Wabi's [terms](https://wabi.ai/terms) describe scheduling, research, purchases, and other requested tasks; a response *may* arrive as an interactive “Mini-App.” Its [download page](https://wabi.ai/download) links iOS, Android, and Mac versions. The app-like response is a way to work with the assistant, not necessarily a separately published product in a browsable marketplace. The public materials reviewed here do not establish a current creator-to-consumer app catalog.

## The interface is not the completed task

Imagine planning a trip in a group chat: a card with flights or a shared itinerary is easier to use than a wall of suggestions. Wabi's [press-kit stills](https://wabi.ai/presskit) illustrate that idea, but they are promotional examples, not evidence that a booking completed or that every participant saw only permitted information. We did **not** install the app or run a booking, group-permission, or mini-app persistence test for this Article.

Nor is the design an architectural specification. [Google Opal](https://developers.google.com/opal) shows that prompting and sharing small AI workflows is a broader product pattern; [generative UI](https://ai-sdk.dev/docs/ai-sdk-ui/generative-user-interfaces) can also mean rendering an interface around a model's tool call. Neither source explains Wabi's implementation. The reviewed Wabi materials do not specify how its interfaces are generated, isolated, tested, or kept accurate over time.

## The shared data boundary

Wabi's [privacy notice](https://wabi.ai/privacy) describes optional access to connected accounts and device data, and names Google, Anthropic, and OpenAI as model providers. Wabi says conversations and connected-account content are not used to train AI models; that is **its policy statement**, not an independent audit. In [TechCrunch's launch interview](https://techcrunch.com/2026/10/19/replikas-founder-built-the-ai-assistant-she-pitched-at-disrupt-12-years-ago/), Kuyda said sharing is scoped to individual chats and members can see when someone's personal information is requested. We have not tested those controls. Wabi's [terms](https://wabi.ai/terms) also warn that content posted to a group may remain visible to its members after you leave or delete your account.

The [terms' action language](https://wabi.ai/terms) is worth reading closely: Wabi may act on a user's behalf for purchases, travel, browsing, and messages. *Where the service asks* for review and confirmation, confirming authorizes it to proceed. That is not a blanket promise that every important action has an approval step. The terms also warn that AI output and Mini-Apps are not guaranteed accurate. A polished card can still carry stale data or lead to a mistaken action.

## Four checks before trusting a shared assistant

- Try one low-stakes group task and note who can see each message, generated interface, and connected-account result.
- Verify a mini-app's data against its source, then check whether edits and corrections persist.
- Inspect connector permissions and confirmation screens before allowing messages, bookings, or purchases.
- Keep sensitive accounts disconnected until retention, deletion, and group access meet your needs.

Wabi's most interesting bet is that people want an assistant to **make the right little interface at the right moment**, rather than spend their time building it. Whether that bet works depends on the less photogenic parts: correct data, scoped sharing, and dependable action controls.

## Sources

- [Wabi public-launch interview — TechCrunch, October 19, 2026](https://techcrunch.com/2026/10/19/replikas-founder-built-the-ai-assistant-she-pitched-at-disrupt-12-years-ago/)
- [Wabi's original mini-app platform and pre-seed coverage — TechCrunch, November 5, 2025](https://techcrunch.com/2025/11/05/replika-founder-raises-20m-pre-seed-for-wabi-the-youtube-of-apps/)
- [Wabi current product page](https://wabi.ai/)
- [Wabi download page](https://wabi.ai/download)
- [Wabi press kit and promotional stills](https://wabi.ai/presskit)
- [Wabi terms and conditions](https://wabi.ai/terms)
- [Wabi privacy notice](https://wabi.ai/privacy)
- [Google Opal documentation (related product pattern)](https://developers.google.com/opal)
- [Vercel AI SDK generative-UI documentation (technical context, not Wabi's implementation)](https://ai-sdk.dev/docs/ai-sdk-ui/generative-user-interfaces)
