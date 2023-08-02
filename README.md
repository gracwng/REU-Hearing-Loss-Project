# REU-Hearing-Loss-Project

## Topographical Scalp Maps for Hearing Impairment Detection: A CNN Approach

**Authors:** Grace Wang, Dr. Beiyu Lin  
**Date:** July 2023

---

## Abstract

This project focuses on utilizing scalp maps derived from spatial and temporal electroencephalography (EEG) data to distinguish between individuals with hearing impairment and healthy individuals. 
A Convolutional Neural Network (CNN) model is trained to recognize patterns in the EEG data, achieving an accuracy of 85%-95%. This advanced approach has the potential to improve hearing impairment 
detection methods, benefiting both individuals and healthcare professionals.

---

## Introduction

Hearing impairment is a prevalent issue affecting a significant portion of the population. This study explores the use of scalp maps derived from EEG data to detect hearing impairment, offering a 
non-invasive and affordable alternative to existing diagnostic methods. The study employs CNNs due to their suitability for image-based data, aiming to provide earlier intervention and cost savings in healthcare.

---

## Terminologies

- EEG (Electroencephalography)
- ERPs (Event-Related Potentials)
- Scalp Maps
- Spatial EEG Data
- Temporal EEG Data
- EEG Preprocessing
- Feature Extraction

---

## Database

The dataset consists of EEG data from both hearing-impaired and normal hearing individuals. The study focuses on ERPs recorded during passive listening to tone stimuli. Each subject underwent 
180 repetitions of the tone stimuli, resulting in a total of 1,760 images for the CNN model.

---

## Methods

1. EEG Preprocessing: Signal cleaning and ERP extraction.
2. ERP Extraction: Calculating event-related potential averages.
3. Topographic Brain Maps: Extracting scalp maps from ERPs.
4. CNN Architecture: A 3-layer CNN model for image classification.

---

## Results

### Experiments

- **Experiment 1**: 70% Training, 30% Testing
  - Accuracy: 86%

- **Experiment 2**: 80% Training, 10% Validation, 10% Testing
  - Accuracy: 95%
 
- **Experiment 3**: 70% Training, 15% Validation, 15% Testing
  - Accuracy: 89%

**Experiments Summary:**

| Experiment | Training Data | Validation Data | Testing Data | Test Loss | Test Accuracy |
|------------|---------------|-----------------|--------------|-----------|--------------|
| 1          | 70%           | --              | 30%          | 0.38      | 0.87         |
| 2          | 80%           | 10%             | 10%          | 0.23      | 0.95         |
| 3          | 70%           | 15%             | 15%          | 0.47      | 0.89         |

---

## Conclusions

The CNN model achieves an accuracy of approximately 85%-95% in detecting hearing impairment based on scalp maps from EEG data.

---

## Future Work

Future investigations could involve:
- Using a larger and more diverse dataset.
- Exploring alternative machine learning methods.
- Fine-tuning model parameters and conducting optimizations.

