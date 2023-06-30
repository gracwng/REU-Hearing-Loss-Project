# ds-snhl

This repository contains code for analysis of auditory EEG data as described in the paper: 

Fuglsang,S., Marcher-Rorsted, J Dau, T. and Hjortkjaer, J (2020). *Effects of sensorineural hearing loss on cortical synchronization to competing speech during selective attention*. Journal of Neuroscience

The data was collected by Jonatan Marcher-Rorsted at the Technical University of Denmark in the Hearing Systems Group in 2018. The data are availble at: http://doi.org/10.5281/zenodo.3618205

Please see ```src/examples/examplescript1.m``` and ```src/examples/examplescript2.m``` which demonstrates how to define a preprocessing pipeline, preprocess audio/EEG data and subsequently perform a stimulus-response analysis. 

To replicate the results from the study, define a variable ```bidsdir``` that points to the BIDs data directory and a variable ```sdir``` that points to the directory in which the derived data (e.g. audio envelopes) will be stored and execute ```for subid = 1 : 44; runall(subid,bidsdir,sdir); end```. Once this has been done, use ```export_summaries(sdir,bidsdir)``` to export figures and data summaries.


# Table of Contents

* [What is contained in this repository?](#Repo)
* [Requirements](#Requirements)
* [BIDs data](#BIDS)
* [Additional figures](#addfigure)
* [Acknowledgments](#ack)

# <a name="Repo"></a>What is contained in this repository?
To get an overview please see *docs>html>index.html* or *docs>html>files.html*. The overall structure of this repository is as follows:

```
    LICENSE
    README
    |__ tools                                      # General tools used for the analysis
                |__ _ext                           # External tools used for the analysis
                    |__ AM_toolbox 
                    |__ gramm-master 
                    |__ ltfat
                    |__ NoiseTools
                |__ private                       
    |__ docs                                       # Source code documentation
    |__ reports                                    # Data summaries in the form of figures and data tables
                |__ paper                           
                       |__ export_summaries.m      # Script used for exporting data summaries and figures
                       |__ fig1                    
                       |__ fig2                    
                       |__ fig3                    
                       |__ fig4                    
                       |__ fig5                    
                       |__ func                    # Functions used for extracting the data summaries and exporting figures
                       |__ additional              # Additional figures (reconstruction accuracies, classification accuracies, ERPs)    
                |__ review                         # Folder containing additional figures shared with the reviewers 
                       |__ review01 
                |__ dataset                        # This folder contains figures that describes the dataset 
 
    |__ src                           
                |__ features                       # General functions that can be used to derive audio and EEG features (later used for stimulus-response analysis)
                       |__ build_aud_features.m    # Function used for extracting audio features
                       |__ build_eeg_features.m    # Function used for extracting EEG features
                       |__ func                   
                           |__ modules            
                               |__ aud             # Individual subprocessing modules for audio processing
                               |__ eeg             # Individual subprocessing modules for EEG processing
                |__ paper                          # Scripts used for the analysis presented in the manuscript
                       |__ private                
                       |__ control       
                |__ examples                       # Scripts that illustrates ways of processing the data (either with- or without functions distributed in this repository)
     

         
```

# <a name="Requirements"></a>Requirements

* Matlab 9.4.0.813654 (R2018a) (see Matlab version information below)
* FieldTrip, revision 20190207
* NoiseTools, revision 24-Mar-2019  
* R version 3.6.0 (2019-04-26)
* LTFAT version 2.2.0 (distributed here)
* AM Toolbox version 0.9.7 (distributed here)
* Gramm Toolbox [DOI](https://doi.org/10.21105/joss.00568) (distributed here)



```
-----------------------------------------------------------------------------------------------------
MATLAB Version: 9.4.0.813654 (R2018a)
MATLAB License Number: 51651
Operating System: Linux 4.4.0-151-generic #178-Ubuntu SMP Tue Jun 11 08:30:22 UTC 2019 x86_64
Java Version: Java 1.8.0_144-b01 with Oracle Corporation Java HotSpot(TM) 64-Bit Server VM mixed mode
-----------------------------------------------------------------------------------------------------
MATLAB                                                Version 9.4         (R2018a)                
Simulink                                              Version 9.1         (R2018a)                
DSP System Toolbox                                    Version 9.6         (R2018a)                            
Statistics and Machine Learning Toolbox               Version 11.3        (R2018a)                
```


# <a name="BIDS"></a>BIDs data
All data are publicly available and described in more details at http://doi.org/10.5281/zenodo.3618205. The data directory is organized according to the BIDs format:

```
    README
    dataset_description.json 
    participants.tsv 
    participants.json
    task-selectiveattention_events.json
    task-tonestimuli_events.json
    task-rest_events.json
    sub-001
        |__ sub001_scans.tsv
        |__ eeg 
              |__ sub-001_task-rest_channels.tsv 
              |__ sub-001_task-rest_channels.json 
              |__ sub-001_task-rest_eeg.bdf 
              |__ sub-001_task-rest_eeg.json 
              |__ sub-001_task-rest_events.tsv 
              |__ sub-001_task-selectiveattention_channels.tsv 
              |__ sub-001_task-selectiveattention_channels.json 
              |__ sub-001_task-selectiveattention_eeg.bdf 
              |__ sub-001_task-selectiveattention_eeg.json 
              |__ sub-001_task-selectiveattention_events.tsv 
              |__ sub-001_task-tonestimuli_channels.tsv 
              |__ sub-001_task-tonestimuli_channels.json 
              |__ sub-001_task-tonestimuli_eeg.bdf 
              |__ sub-001_task-tonestimuli_eeg.json 
              |__ sub-001_task-tonestimuli_events.tsv 
    sub-002
    sub-003
    ...
    sub-048
    stimuli
        |__ sub001 
              |__ target
                |__ t001.wav
                |__ t001woa.wav
                |__ t001woacontrol.wav
                |__ t002.wav
                |__ t002woa.wav
                |__ t002woacontrol.wav
                |__ t003.wav
                |__ t003woa.wav
                |__ t003woacontrol.wav
                |__ t004.wav
                |__ t004woa.wav
                |__ t004woacontrol.wav
                ...
                |__ t048.wav
                |__ t048woa.wav
                |__ t048woacontrol.wav
              |__ masker
                |__ m004.wav
                |__ m004woa.wav
                |__ m004woacontrol.wav
                |__ m006.wav
                |__ m006woa.wav
                |__ m006woacontrol.wav
                |__ m007.wav
                |__ m007woa.wav
                |__ m007woacontrol.wav
                |__ m008.wav
                |__ m008woa.wav
                |__ m008woacontrol.wav
                ...
        |__ sub002 
        |__ sub003 
        ...
        |__ sub048 
    derivatives
```

Due to a break during the selective attention experiment, sub-024 has data organized in the following way:

```
    sub-024
        |__ sub024_scans.tsv
        |__ eeg 
              |__ sub-024_task-rest_channels.tsv 
              |__ sub-024_task-rest_channels.json 
              |__ sub-024_task-rest_eeg.bdf 
              |__ sub-024_task-rest_eeg.json 
              |__ sub-024_task-rest_events.tsv 
              |__ sub-024_task-selectiveattention_channels.tsv 
              |__ sub-024_task-selectiveattention_channels.json 
              |__ sub-024_task-selectiveattention_eeg.bdf 
              |__ sub-024_task-selectiveattention_eeg.json 
              |__ sub-024_task-selectiveattention_events.tsv 
              |__ sub-024_task-selectiveattention_run-2_channels.tsv 
              |__ sub-024_task-selectiveattention_run-2_channels.json 
              |__ sub-024_task-selectiveattention_run-2_eeg.bdf 
              |__ sub-024_task-selectiveattention_run-2_eeg.json 
              |__ sub-024_task-selectiveattention_run-2_events.tsv 
              |__ sub-024_task-tonestimuli_channels.tsv 
              |__ sub-024_task-tonestimuli_channels.json 
              |__ sub-024_task-tonestimuli_eeg.bdf 
              |__ sub-024_task-tonestimuli_eeg.json 
              |__ sub-024_task-tonestimuli_events.tsv 
```


# <a name="addfigure"></a>Additional figures
Additional figures can be found in [reports>paper>additional](/reports/paper/additional), [reports>dataset](/reports/dataset) and [reports>review](/reports/review/). The figures found in [reports>paper>additional](/reports/paper/additional) are also shown below:

Fig S1
------

**Left** Classification accuracies as a function of duration of decoding segments. Results have here been obtained with stimulus reconstruction models trained on single-talker data and evaluated on two-talker data. The spatial denoising filters were in this case optimized based on single-talker data. Decoding segments with durations of 1 s, 3 s, 5 s, 7 s, 10 s, 15 s, 20 s and 30 s (taking into account the 0.5 s long kernel of the stimulus reconstruction models) were considered. The decoding segments were non-overlapping, and each decoding segment was shifted by the decoding segment duration plus additional 5 s long time shifts. Data reflect group mean averages and standard deviations. Note that the errorbars for each group at a given duration of decoding segments have been shifted by 0.2 s around its actual decoding segment duration for visualization purposes. Dashed line shows chance level when assumed to follow a binomial distribution.

**Right** The ability to reconstruct envelopes of attended and unattended speech streams from EEG activity in the different listening conditions. Model performance was assessed by nested cross-validation procedures. Reconstruction accuracies reflect Pearson's correlation coefficient between neural reconstruction and target envelope over trials not used for model fitting. Points reflect averaged data for each individual subject. Errorbars represent s.e.m. Bar height reflect group-mean average. The estimated noise floor is here highlighted with a dashed line.

<br>
<br>
<img src="/reports/paper/additional/figure-classification_accuracy_time.png" height="300">
<img src="/reports/paper/additional/figure-reconstruction_accuracy.png" height="300">
<br>
<br>

Fig S2
------

Cortical event-related potentials (ERPs) to 1000 Hz ramped tones presented with jittered inter-onset intervals. First and second panel (from left): Individual traces of ERP data averaged over the same fronto-central electrode cluster that was used for the entrainment analysis. Thin lines reflect data from individual subjects. Thick lines reflect group-mean averages. Third panel: Mean amplitude of N1 ERPs averaged over a time interval from 75 ms to 130 ms. Errorbars show s.e.m. across listeners. Fourth (right) panel: Group-mean topographies of mean N1 amplitude.

<br>
<br>
<img src="/reports/paper/additional/figure-erp.png" height="300">
<br>
<br>






# <a name="ack"></a>Acknowledgments 
This work was supported by the EU H2020-ICT grant number 644732 (COCOHA: Cognitive Control of a Hearing Aid) and by the Novo Nordisk Foundation synergy grant NNF17OC0027872 (UHeal).