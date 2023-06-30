This folder contains code that can be used to replicate the figures shown in the response letter. 

# Table of Contents

* [Folder structure](#fstructure)
* [Figures](#fig)
* [Acknowledgments](#ack)


# <a name="fstructure"></a>Folder structure
To export the figures, edit *replicateanalysis.m* such that *bidsdir* and *sdir* points to the root of the BIDs data directory respectively the folder with the derived data. Once this is done, simply execute.

```
    README
    |__ review01                                   
                |__ fig01                          # Evaluating the goodness-of-fit in the two-talker condition of encoding- and decoding models trained on single-talker data. Weigths of decoders are shown (merely for illustrative purposes)
                    |__ r0101.pdf 
                |__ fig02                          # EEG-audio crosscorrelation analysis with "speech-onset envelopes"
                    |__ r0102.pdf 
                |__ fig03                          # scatter plots of self-report listening measures and entrainment measures
                    |__ r0103.pdf 
                |__ fig04                          # illustrating ITPC strength in each hemisphere
                    |__ r0104.pdf 
                |__ fig05                          # exporting numerous of the main figures in the study but with a smaller subset of 10 NH and 11 HI listeners with an age range between 51 years and 69 years old. The NH listeners all have audiometric thresholds <=20 dB HL
                    |__ r0105_age.pdf              # showing the age of each of the subjects in the two considered groups. each point show the age of each of the considered subjects
                    |__ r0105_agram.pdf            # audiograms of the two groups (top panel = NH, bottom = HI)
                    |__ r0105_attentionbehavior.pdf       # behavioral results from auditory attention experiment with the considered subset of listeners
                    |__ r0105_classificationaccuracy.pdf  # classification accuracies with 10-s long classification segments for the subset of listeners
                    |__ r0105_encoding.pdf         # encoding accuracies averaged over the same subset of fronto-central electrodes
                    |__ r0105_reconstructionaccuracy.pdf  # reconstruction accuracies
                    |__ r0105_itpc.pdf             # inter-trial phase coherence for the 4 Hz onset/offset EFR stimuli (top) and for the 40 Hz EFR stimuli (bottom)
                    |__ r0105_psychophysics.pdf    # results from the daHINT test (top-left), SSQ test (top-right), FT-test (bottom-left) and Digit span (bottom-right)
                |__ fig06                          # results from an encoding analysis in which the audio- and EEG data was bandpass filtered using constant-bandwidth filters with varying center frequencies
                    |__ r0106.pdf 
                |__ fig07                          # results from an encoding analysis operating on cochleograms extracted for each of the two audio channels
                    |__ r0107.pdf 
                |__ fig08                          # results ITPC analysis based on long-term DFT 
                    |__ r0108a.pdf 
                    |__ r0108b.pdf 
                    |__ r0108.eps 
                 |__ func                          # functions used to export the figures

```

# <a name="fig"></a>Figures
Figures shared with the reviewers.

Fig A
------

Evaluating the goodness-of-fit in the two-talker condition of encoding- and decoding models trained on single-talker data (left). Weigths of decoders are shown to the right (merely for illustrative purposes) at individual time-lags.

<br>
<br>
<img src="/reports/review/review01/fig01/r0101.png" height="500">
<br>
<br>


Fig B
------

EEG-audio crosscorrelation analysis with "speech-onset envelopes". This is based on a cross-correlation analysis on audio representations comparable to those reported in doi:10.1152/jn.00527.2016.; 
J Neurophysiol 117: 18-27, 2017. Here, we use the same elegant (and computationally fast) way of extracting speech-onset envelopes that put emphasis on onsets. Note that we focus on speech stimuli without CamEQ for hearing-impaired listeners as in the
aforementioned study. Also note that we take a few shortcuts for simplicity (DSS-based EOG denoising, averaging EEG data over a set of fronto-central electrodes). This approach is useful for highlighting stimulus-response relations without having to go into the computationally intensive modeling approach

<br>
<br>
<img src="/reports/review/review01/fig02/r0102.png" height="400">
<br>
<br>


Fig C
------

Scatter plots of self-report listening measures and entrainment measures. This figure plots reconstruction accuracies (as a measure of envelope entrainment) and classification accuracies (attended-unattended) against difficulty ratings (above) and SSQ scores (below, higher SSQ values indicate less listening difficulties). As reported in the paper, we found group effects of our entrainment measures and of difficulty ratings / SSQ scores. It is therefore not surprising that these measures are correlated when considering all subjects across groups (i.e. driven by the group differences). We did not find that they were consistently correlated within groups when considering the two groups separately. It is difficult to make valid conclusion here since we are statistically under-powered for exploratory correlation-studies within groups, where a larger sample size would be required. 

<br>
<br>
<img src="/reports/review/review01/fig03/r0103.png" height="300">
<br>
<br>


Fig D
------
4 Hz ITPC and 40 Hz ITPC across EEG responses to EFR stimuli, but averaged over EEG electrodes from each hemisphere. In the topographies, crosses show *left hemisphere electrodes*, squares show *right hemisphere electrodes*. The right panel shows group-mean ITPC in short time windows (errorbars reflect s.e.m.). 

<br>
<br>
<img src="/reports/review/review01/fig04/r0104.png" height="400">
<br>
<br>

Fig E
------
Some of the subjects that were considered to be normal-hearing subjects had audiograms that exceeded 20 dB HL. To better understand if these subjects may have affected the results, we analyzed data from a subset of the subjects using a stricter criterion for NH. We selected the NH listeners with hearing levels not exceeding 20 dB HL at all audiometric frequencies (10 of 22 NH subjects met this criterion, mean age: 59.6; max age: 69 years old). We also extracted a subgroup of HI listeners in the same age range, i.e. younger than 69 years old, effectively creating a HI subgroup matched in age to the NH group (11 of the 22 HI subjects; mean age: 61.1). We then computed the same main analysis, i.e. envelope encoding/decoding models and tone EFRs, in these two groups. In the figure shown below, we show the main results of this subgroup analysis. 

<br>
<br>
<img src="/reports/review/review01/fig05/r0105.png" height="300">
<br>
<br>


Fig F
------
Encoding accuracies obtained when bandpass filtering the EEG/audio data using constant-bandwidth 2 Hz wide filters before performing the encoding analysis. The encoding accuracies were here averaged over all scalp electrodes for illustrative purposes and to avoid any potential spatio-spectral biases.

<br>
<br>
<img src="/reports/review/review01/fig06/r0106.png" height="300">
<br>
<br>


Fig G
------
Results from an encoding analysis operating on cochleograms extracted for each of the two audio channels. Gammatone features (with ERB spaced centre frequencies between 100 Hz and 12000 Hz) were here extracted separately for each of the two audio channels and concatenated across dimensions. For computational purposes (due to the high dimensionality of the audio feature representation), we focus here on the FCz electrode response. Similar results were also obtained when first reducing the dimensionality of the audio representation with PCA (not shown here).

<br>
<br>
<img src="/reports/review/review01/fig07/r0107.png" height="300">
<br>
<br>


Fig H
------
ITPC computed based on Fourier-transformed EEG data (including a Hanning window and zero-padding) covering the entire stimulation period (ITPC computed over time window from -0.5 s to 2.5 s and averaged over all scalp electrodes).  

<br>
<br>
<img src="/reports/review/review01/fig08/r01f08.png" height="300">
<br>
<br>


# <a name="ack"></a>Acknowledgments 
This work was supported by the EU H2020-ICT grant number 644732 (COCOHA: Cognitive Control of a Hearing Aid) and by the Novo Nordisk Foundation synergy grant NNF17OC0027872 (UHeal).