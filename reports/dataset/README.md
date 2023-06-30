# Dataset descriptors

# Table of Contents

* [Figures](#fig)
* [Envelopes contained in derivatives folder](#derivedenvelopes)
* [Acknowledgments](#ack)

# <a name="fig"></a>Figures
A few additional figures that summarize the dataset are stored in the *reports>dataset>* folder. These are as follows:


Fig A
------

Effects of spatial filtering on EEG data. Top left panel show topographies of the EEG variance ratio before/after denoising. Top right panels show topographies of Pearson's correlation coefficient between EEG data with and without denoising. A high correlation indicates that the denoised data to a great extend resembles the data that was not denoised. Bottom panel show traces of EEG electrode responses in a single trial with- and without denoising.

<br>
<br>
<img src="/reports/dataset/figure_effect_of_denoising/figure-effect_of_denoising-sub-01.png" height="600">
<br>
<br>

Fig B
------

Events stored in the .bdf files from the EFR/ERP experiment. Horizontal lines indicate time periods with relevant events. Red lines reflect EEG segments where the subjects were presented with 40 Hz amplitude modulated EFR stimuli arranged in 4 Hz onset/offset patterns. Blue lines reflect EEG segments where the subjects were presented with 40 Hz amplitude modulated EFR stimuli in sustained 2 s intervals. Green lines reflect EEG segments where subjects were presented with tone beeps with randomized inter-stimulus-intervals. Thick black lines show periods where the EEG system reported CMS/DRL errors. Thick gray lines show time periods with CMS/DRL errors, but arbritrarily extended with 20 s on each side for visualization purposes. Note that the relevant data segments for the analysis did not overlap with the gray areas. A CMS/DRL error only occured for *sub003*.  Due to technicalities, there were additional triggers in the ERP/EFR EEG data recorded from *sub005*, *sub008*, *sub009* and *sub011*. These triggers were not included in the analysis.

<br>
<br>
<img src="/reports/dataset/figure_illustrate_bdf_events/figure-bdf_events-sub-003_task-tonestimuli.png" height="300">
<br>
<br>

The below figure show similar events for data recorded from *sub-001* in the EEG experiment with tone stimuli:

<br>
<br>
<img src="/reports/dataset/figure_illustrate_bdf_events/figure-bdf_events-sub-001_task-tonestimuli.png" height="300">
<br>
<br>

Fig C
------

Events stored in the .bdf files from the selective attention experiment. Horizontal lines indicate time periods with relevant events. Red lines reflect EEG segments where the subjects were presented with single-talker stimuli. Blue and green lines reflect EEG segments where subjects were presented with two-talker stimuli (blue = attended stimulus, green = ignored stimulus). Thick black lines show periods where the EEG system reported CMS/DRL errors. Thick gray lines show time periods with CMS/DRL errors, but arbritrarily extended with 15 s on each side for visualization purposes. Note that the relevant data segments for the stimulus-response analysis did not overlap with the gray areas as CMS/DRL errors only occured during experimental breaks. BioSemi reported CMS/DRL errors for 5 subjects (*sub015*, *sub033*, *sub037*, *sub038*, *sub039*).

<br>
<br>
<img src="/reports/dataset/figure_illustrate_bdf_events/figure-bdf_events-sub-037_task-selectiveattention.png" height="300">
<br>
<br>


The below figure show similar events for data recorded from *sub-001* in the selective attention experiment

<br>
<br>
<img src="/reports/dataset/figure_illustrate_bdf_events/figure-bdf_events-sub-001_task-selectiveattention.png" height="300">
<br>
<br>


Fig C
------

The below figure shows the absolute difference in pure-tone audiograms across ears for each subject and each audiometric frequency. The right panel depicts absolute difference in pure-tone average (over fc=500 Hz, fc=1000 Hz, fc=2000 Hz, fc=4000 Hz) across ears.
<br>
<br>
<img src="/reports/dataset/figure_degree_of_audiogram_asymmetry/figure_degree_of_audiogram_asymmetry.png" height="600">
<br>
<br>


Fig D
------

This figure plots results from encoding analysis (top row) and stimulus-reconstruction analysis (bottom row) obtained with models trained on envelopes with- and without CamEQ equalization for each subject. We found that the results obtained with models trained on the different representations yielded highly similar results. 

One important consideration that we want to highlight is that the premise for using the frequency-dependent CamEQ equalization is that the hearing-impaired listeners have a loss of sensitivity to certain frequencies and that this equalization up to some extend accounts for that. A similar approach has been taken in a number of recent studies. However, we must stress that one should be careful with testing for statistical stimulus-response dependencies between envelopes of the actual stimuli (with CamEQ) for envelope representaitons that are highly sensitive to CamEQ amplification. This can be important for univariate envelope representations. What can happen is that the different representations themself will drive group-differences in the stimulus-response dependencies.

<br>
<br>
<img src="/reports/dataset/figure_regression_accuracies_cameq/figure_regression_accuracies_cameq.png" height="400">
<br>
<br>



# <a name="derivedenvelopes"></a>Envelopes contained in derivatives folder
Audio envelope features are contained in the derivatives folder for each subject in the BIDs directory. These features were extracted using the following preprocessing pipeline:

 
```
clc; clear
initdir


bidsdir     = '.... /bids_directory

% loop over subjects
subid = 1;



pp =   {'pp_aud_average',...
        'pp_aud_lowpass6000_44100',...
        'pp_aud_resample12000_44100',...
        'pp_aud_gammatone',...
        'pp_aud_fullwave_rectify',...
        'pp_aud_powerlaw03',...
        'pp_aud_average',...
        'pp_aud_lowpass256_12000',...
        'pp_aud_resample512_12000'};

pipeline = struct;
pipeline.pp = pp;
pipeline.sname = '';
pipeline.task = 'selectiveattention';

feat = build_aud_features(subid,pipeline,bidsdir,[],[],0);
```


# <a name="ack"></a>Acknowledgments 
This work was supported by the EU H2020-ICT grant number 644732 (COCOHA: Cognitive Control of a Hearing Aid) and by the Novo Nordisk Foundation synergy grant NNF17OC0027872 (UHeal).