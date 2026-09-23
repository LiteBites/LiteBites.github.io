---
layout: article
title: "GPT-6 Sol and Luna: Two Workloads, One API Choice"
short_title: "GPT-6 Sol & Luna"
date: 2026-09-23
type: "Article Bite"
read_time: "3 min read"
source_name: "OpenAI"
source_url: "https://openai.com/index/introducing-gpt-6-sol-and-luna/"
source_published: 2026-09-22
last_reviewed: 2026-09-23
tags:
  - AI Models
  - Developer Tools
summary: "OpenAI positions GPT-6 Sol for complex coding and agentic work and Luna for focused, high-volume tasks; their API price gap is large, but public docs do not establish a quality or speed trade-off."
additional_sources:
  - name: "GPT-6 Sol model documentation"
    url: "https://developers.openai.com/api/docs/models/gpt-6-sol"
  - name: "GPT-6 Luna model documentation"
    url: "https://developers.openai.com/api/docs/models/gpt-6-luna"
---

## Two models, not just two names

OpenAI’s GPT-6 API lineup puts two names on the menu: **Sol** for complex coding and agentic workflows, and **Luna** for focused, high-volume tasks. That is the company’s positioning, not a published rule that one model is “smart” and the other is “small.” The docs show both accept text and images, return text, support the same reasoning-effort settings, and advertise a 1,050,000-token context window with up to 128,000 output tokens.

The model cards also list different knowledge-cutoff dates—April 20, 2026 for Sol and May 18, 2026 for Luna. That is a detail worth checking for research-heavy tasks; it is not a benchmark of either model’s accuracy.

<figure class="article-ascii-figure">
  <div class="article-ascii-scroll" tabindex="0" role="region" aria-label="Scrollable ASCII illustration comparing GPT-6 Sol and Luna; scroll in both directions to view the full artwork">
<pre role="img" aria-label="Original LiteBites ASCII-style illustration with a shaded sun, star field, GPT-6 Sol and Luna lettering, and a shaded moon. Sol is labeled for complex coding and agentic workflows; Luna for focused, high-volume tasks.">                             .        *       .
       .         .        .        .        .

             ..::::---===++***++===---::::..
         .:-=+*##%%%%%%%%%%%%%%%%%%%%%%##*+=-:.
       :=*#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#*=:       .
      -*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%*-   .
     =#%%%%%%%%%%%%%%#####***####%%%%%%%%%%%%%%%%#=
    :#%%%%%%%%%%%##*+=-:..     ..:-=+*##%%%%%%%%%%#:
    +%%%%%%%%%%#*=-.                 .-=*#%%%%%%%%+
    #%%%%%%%%#*=.                       .=*#%%%%%%%#
    #%%%%%%%#*:       *       .             :*#%%%%%#
    #%%%%%%#*.    .       .        *         .*#%%%%#
    +%%%%%#*:          .       .               :*#%%+
    :#%%%#*:      .          .          .       :*#:
     =##*-.                                      .-*=
      .                 .          *                .
            .      .         .            .

                         G P T - 6

            ███████╗ ██████╗ ██╗      ███████╗
            ██╔════╝██╔═══██╗██║      ██╔════╝
            ███████╗██║   ██║██║      ███████╗
            ╚════██║██║   ██║██║      ╚════██║
            ███████║╚██████╔╝███████╗███████║
            ╚══════╝ ╚═════╝ ╚══════╝╚══════╝

                  S O L     +     L U N A

    .       *         .             .       *             .
          .       .           *             .       .
   *            .      .                .         *
        .              .       .              .
                           .
                                     .-======-.
                                .:=+*##%%%%%%%##*+=:.
                              :=*#%%%%%%%%%%%%%%%%%%#*:
                             -*#%%%%%%%%%%%%%%%%%%%%%%#*-
                            =#%%%%%%%%%%%%%%%%%%%%%%%%%%#=
                           :#%%%%%%%%%%%%%%%%%%%%%%%%%%%%#:
                           +%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%+
                           #%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#
                           #%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#
                           +%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%+
                           :#%%%%%%%%%%%%%%%%%%%%%%%%%%%%#:
                            =#%%%%%%%%%%%%%%%%%%%%%%%%%%#=
                             -*#%%%%%%%%%%%%%%%%%%%%%%#*-
                              :=*#%%%%%%%%%%%%%%%%%%#*:
                                .:=+*##%%%%%%%%##*+=:.
                                     .-======-.
                                           .

        SOL  /  complex coding & agentic workflows
        LUNA /  focused, high-volume tasks

       Original ASCII-style interpretation, not OpenAI artwork.</pre>
  </div>
  <figcaption>
    Original LiteBites text-art synthesis from OpenAI’s <a href="https://developers.openai.com/api/docs/models/gpt-6-sol">Sol</a> and <a href="https://developers.openai.com/api/docs/models/gpt-6-luna">Luna</a> model descriptions. Scroll horizontally and vertically on narrow screens.
  </figcaption>
</figure>

## Luna is dramatically cheaper on tokens

At standard API rates, Sol is listed at $2 per million input tokens and $10 per million output tokens. Luna is $0.10 and $0.50 respectively: a twenty-fold price difference on each token category. Cached input and cache writes keep the same ratio. If a workflow mostly runs many short, well-scoped tasks, Luna’s listed rates could change the economics substantially.

But long context has a pricing catch. OpenAI says prompts above 272,000 input tokens are charged at twice the input and cache rates and 1.5 times the output rate for the full request. Both models advertise a million-token context window, but that does not mean every million-token run costs at the headline rate. Tool-specific charges may also apply, so token prices are not always the whole bill.

## The docs don’t show the quality trade-off

Both model pages list the same reasoning-effort choices, from `none` through `max`, with `medium` as the default. OpenAI directs users to the Responses API for built-in tools and function calling; Chat Completions supports function calling only when reasoning effort is set to `none`.

What the public model pages do not provide is an apples-to-apples Sol-versus-Luna quality, latency, or throughput evaluation. “Most efficient” is OpenAI’s description of Luna, not independent evidence that it will meet a particular team’s quality bar. The model cards alone cannot show how often a cheaper run needs retries, extra tools, or human correction.

## A small test beats a naming guess

Give both models the same representative tasks and compare accepted-answer quality, total tokens, tool charges, wall-clock time, retries, and intervention rate. Match reasoning effort and endpoint settings; include the long-context price threshold if your prompts approach it. Choose by total cost per acceptable result, not by family name or token rate alone.

## Sources

- [Introducing GPT-6 Sol and Luna — OpenAI](https://openai.com/index/introducing-gpt-6-sol-and-luna/)
- [GPT-6 Sol model documentation — OpenAI](https://developers.openai.com/api/docs/models/gpt-6-sol)
- [GPT-6 Luna model documentation — OpenAI](https://developers.openai.com/api/docs/models/gpt-6-luna)
