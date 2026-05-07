---
title: "MedMNIST"
short_title: "MedMNIST"
domain: "Biomedical imaging"
task: "Classification benchmark"
summary: "A standardized collection of 2D and 3D biomedical image classification datasets with MNIST-like size options for fast medical imaging experiments."
use_for: "biomedical image classification, lightweight benchmarking, AutoML tests, 2D/3D model sanity checks"
scale: "About 708K 2D images and 10K 3D images across 18 datasets"
license: "CC BY 4.0 / CC BY-NC 4.0"
caveat: "Most subsets are CC BY 4.0, but DermaMNIST is CC BY-NC 4.0; the dataset is not intended for clinical use."
dataset_url: "https://medmnist.com/"
image: "/assets/images/datasets/medmnist.jpg"
image_alt: "MedMNIST overview thumbnail from the dataset website"
tags:
  - Biomedical Imaging
  - Classification
  - Benchmark
---

MedMNIST is a compact benchmark suite for biomedical image classification. It wraps multiple medical imaging tasks into standardized 2D and 3D datasets, making it useful for quick model checks and educational experiments before moving to larger clinical datasets.

The main value is consistency. Instead of spending time normalizing many unrelated biomedical datasets, you can start from a shared format, compare baselines, and test whether a method behaves reasonably across different medical modalities.
