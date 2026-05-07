---
title: "MVTec AD"
short_title: "MVTec AD"
domain: "Industrial inspection"
task: "Unsupervised anomaly detection"
summary: "A real-world industrial anomaly detection dataset with defect-free training images, anomalous test images, and pixel-level annotations."
use_for: "unsupervised anomaly detection, anomaly localization, industrial visual inspection baselines"
scale: "Over 5,000 high-resolution images across 15 object and texture categories"
license: "CC BY-NC-SA 4.0"
caveat: "Commercial use is not allowed under the standard dataset license; contact MVTec if the use case may be commercial."
dataset_url: "https://www.mvtec.com/research-teaching/datasets/mvtec-ad"
image: "/assets/images/datasets/mvtec-ad.webp"
image_alt: "MVTec AD teaser image from the dataset website"
tags:
  - Anomaly Detection
  - Industrial Inspection
  - Localization
---

MVTec AD is one of the standard datasets for industrial visual anomaly detection. It includes normal training images and test images with different defect types, plus pixel-precise anomaly masks for localization evaluation.

It is especially useful when you want to test whether a model can learn normal appearance from defect-free data and then detect unusual regions at test time. The object and texture categories also make it a practical starting point for comparing anomaly detection methods.
