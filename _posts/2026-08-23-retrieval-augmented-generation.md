---
layout: post
title: "Retrieval-Augmented Generation for Knowledge-Intensive NLP Tasks"
short_title: "Retrieval-Augmented Generation"
date: 2026-08-23
type: "Paper brief"
read_time: "7 min read"
venue: "NeurIPS 2020"
tags:
  - Retrieval-Augmented Generation
  - Dense Retrieval
  - Open-Domain Question Answering
  - Language Models
summary: "The original RAG paper couples a trainable DPR query encoder with a fixed Wikipedia passage index and a BART generator, then marginalizes generation probabilities over retrieved latent documents."
card_image: "/assets/images/papers/retrieval-augmented-generation/method-01.png"
card_image_alt: "Architecture of the original retrieval-augmented generation model"
paper_url: "https://arxiv.org/abs/2005.11401v4"
code_url: "https://github.com/huggingface/transformers/tree/main/src/transformers/models/rag"
---

## Why this paper matters

A language model can store facts in its parameters, but that memory is hard to inspect and expensive to update. It may also produce a fluent answer without exposing where the answer came from. Earlier open-domain question-answering systems addressed this problem with retrieval, usually by finding passages and extracting an answer span. That pattern worked for extractive QA, but it did not provide a general recipe for free-form generation.

This 2020 paper introduced retrieval-augmented generation, or RAG, as a trainable combination of two kinds of memory. A pre-trained sequence-to-sequence model supplies parametric memory. A dense index of Wikipedia passages supplies non-parametric memory that can be searched, inspected, and replaced without retraining the generator.

The term "RAG" now covers many retrieve-then-prompt systems. The paper describes something narrower: a latent-variable model that fine-tunes a DPR query encoder and BART generator together, then marginalizes generation probabilities over retrieved passages. Reading the original design makes it easier to separate that contribution from later RAG pipelines built around instruction-tuned or proprietary models.

## The bite

Given an input \(x\), the retriever scores passages \(z\) and returns a top-\(k\) set. BART receives the input concatenated with each passage and assigns a probability to the output \(y\). The model does not select one passage as supervised gold evidence. Instead, it treats the retrieved passage as a latent variable and sums over passage-conditioned predictions, weighted by retrieval probability.

The paper proposes two formulations. **RAG-Sequence** assumes that one latent passage is responsible for an entire output sequence, though the final probability is marginalized across the top retrieved passages. **RAG-Token** performs that marginalization at every output position, so different passages can contribute more strongly to different generated tokens. The candidate passages are retrieved for the input; what changes token by token is their posterior contribution during generation.

This division matters. RAG-Sequence scores each sequence under one passage before marginalizing across the retrieved set, while RAG-Token can combine information across passages more flexibly. The experiments do not identify one universal winner: RAG-Sequence is usually stronger on open-domain QA, while RAG-Token performs better on the paper's Jeopardy question-generation task.

## How it works

The non-parametric memory is a December 2018 English Wikipedia snapshot split into 21 million disjoint, 100-word passages. DPR encodes each passage with a BERT-base document encoder and encodes the input with a separate BERT-base query encoder. Retrieval becomes maximum inner-product search over passage vectors, implemented with a FAISS HNSW index.

The generator is BART-large, a roughly 400-million-parameter encoder-decoder. For each retrieved passage, the model concatenates the passage with the original input before generation. Training minimizes the negative marginal log-likelihood of target outputs. The passage index and document encoder remain fixed; gradients update the query encoder and BART generator. There is no direct downstream label saying which passage should be retrieved, although the initial DPR retriever was already trained with retrieval supervision from Natural Questions and TriviaQA.

<figure>
  <img src="{{ '/assets/images/papers/retrieval-augmented-generation/method-01.png' | relative_url }}" alt="RAG architecture showing question, fact-verification, and Jeopardy inputs entering a query encoder; MIPS retrieves top passages from a document index; a generator marginalizes passage-conditioned predictions into answers, labels, or questions." />
  <figcaption>Paper Figure 1: a DPR query encoder searches the fixed passage index, BART generates against each retrieved passage, and the model marginalizes those passage-conditioned predictions.</figcaption>
</figure>

The decoding procedures differ. RAG-Token can use an ordinary autoregressive beam search after combining the per-passage token distributions. RAG-Sequence runs beam search for each passage and then combines sequence scores. The paper provides a thorough version that rescans missing hypotheses and a faster approximation for longer outputs.

Retrieval scale is part of the model, not a free constant. Training uses five or ten passages. For the reported QA tests, RAG-Token uses 15 and RAG-Sequence uses 50; the generation tasks use ten. The appendix reports that the full Wikipedia index initially required about 100 GB of CPU memory, reduced to 36 GB with FAISS compression. Retrieval therefore makes knowledge editable, but adds indexing, memory, and latency costs.

## What to look at in the results

The strongest evidence comes from open-domain QA. On Natural Questions, RAG-Sequence reaches 44.5 exact match, compared with 41.5 for DPR and 36.6 for the 11-billion-parameter T5+SSM closed-book model. It also reports 45.5 on WebQuestions with RAG-Token and 52.2 on CuratedTREC with RAG-Sequence.

TriviaQA needs a qualifier. DPR scores 57.9 on the conventional open-domain split, above RAG-Sequence's 56.8. On the separate TriviaQA-Wiki split used for comparison with T5, RAG-Sequence scores 68.0 versus 60.5 for T5+SSM. This split difference is why a broad claim that RAG beat every listed QA baseline would be misleading.

<figure>
  <img src="{{ '/assets/images/papers/retrieval-augmented-generation/results-01.png' | relative_url }}" alt="Three plots against the number of retrieved documents: Natural Questions exact match for RAG-Token and RAG-Sequence; answer recall comparing trained RAG retrieval, fixed DPR, and BM25; and MS MARCO BLEU-1 and ROUGE-L for both RAG variants." />
  <figcaption>Paper Figure 3: retrieving more passages has diminishing and model-dependent effects. Learned DPR retrieval improves answer recall over fixed DPR and BM25, but generation metrics do not all move in the same direction as k increases. <a href="{{ '/assets/images/papers/retrieval-augmented-generation/results-01.png' | relative_url }}">Open the full-resolution figure.</a></figcaption>
</figure>

The middle panel helps explain where gains come from: fine-tuning the DPR query encoder improves answer recall over both frozen DPR and BM25 on Natural Questions. Yet the ablation is not a blanket rejection of lexical retrieval. BM25 performs best for FEVER, whose claims are often entity-heavy, while learned retrieval is stronger on the other tasks.

For generation, RAG-Sequence improves over BART by 2.6 BLEU-1 and 2.6 ROUGE-L points on the paper's open MS MARCO setup, but systems given gold passages still score higher. In a human evaluation of 452 Jeopardy generation pairs, raters selected RAG-Token as more factual in 42.7% of cases versus 7.1% for BART, and as more specific in 37.4% versus 16.8%. These are pairwise judgments on one constructed task, not a general hallucination rate.

The paper also demonstrates index hot-swapping on 82 world-leader questions. A 2016 index answers 2016 leaders correctly 70% of the time, while a 2018 index scores 68% for 2018 leaders; mismatched index-year pairs fall to 12% and 4%. This is useful evidence that external memory can update behavior, but the experiment is small and templated. The appendix also reports retrieval collapse in preliminary story-generation experiments, where the retriever returned nearly the same passages and BART learned to ignore them.

## Practical takeaways

- Treat the original RAG model as a learned latent-retrieval architecture, not as a synonym for every pipeline that inserts search results into a prompt.
- Retrieval quality is a first-order model component. Evaluate it separately, then report the corpus snapshot, index, retriever initialization, benchmark split, and decoding setup.
- More passages are not automatically better. Tune \(k\) against answer quality, generation metrics, latency, and memory use.
- Editable external memory can update model behavior, but retrieved text is not a guarantee that every generated claim is supported by evidence.
- Keep lexical baselines. The paper's BM25 ablation loses on most tasks but wins on FEVER, showing that dense retrieval is not uniformly superior.

## Links

- [Paper on arXiv (v4)](https://arxiv.org/abs/2005.11401v4)
- [Versioned PDF](https://arxiv.org/pdf/2005.11401v4)
- [NeurIPS 2020 proceedings](https://proceedings.neurips.cc/paper/2020/hash/6b493230205f780e1bc26945df7481e5-Abstract.html)
- [RAG documentation in Hugging Face Transformers](https://huggingface.co/docs/transformers/model_doc/rag)
- [Current Transformers RAG implementation](https://github.com/huggingface/transformers/tree/main/src/transformers/models/rag)
