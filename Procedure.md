# How to Replicate This Project

**Before replicating this project**, it's recommended to read the associated paper for a comprehensive understanding located in the `documents` folder.

## Obtaining Scalp Map Images

1. Obtain scalp map images for each patient's ERP waveform. This involves generating 40 images per patient, resulting in a total of 1,670 images for 44 patients.

2. Follow the steps outlined in the repository: [sfugl/snhl](https://gitlab.com/sfugl/snhl/-/tree/master).
   To ensure the functionality of the extraction process, test running the `extract_erp.m` file on your local machine.

## Processing EEG Data in MATLAB

1. Open the `matlab` folder in this repository using MATLAB. This folder contains scripts for managing EEG data related to ERPs.

2. Start by running the `mainScript.m` file (`matlab/mainScript.m`). This script serves as the entry point and orchestrates the data processing.

3. The `mainScript.m` script calls the `export_summaries.m` file (`matlab/reports/paper/export_summaries.m`), which is responsible for generating summaries.

4. The lines under 'workflows_paper' (line 27) in the `mainScript.m` script contain calls to various experimental scripts.

5. Specifically, the script `extract_erp_10ms_interval.m` (`matlab/reports/paper/func/extract_erp_10ms_interval.m`) was used to obtain the 1,670 images.

6. Note that the file paths in the scripts might be tailored to the original author's computer. Adjust the file paths according to your local environment.

## CNN Model Experimentation

1. Experimentation with the CNN model was conducted using VSCode as the integrated development environment (IDE) for the Python notebook.

2. Access the machine learning-related files in the `machine learning` folder of this repository.

3. The Python notebook `ResNet_50.ipynb` (`machine learning/ResNet_50.ipynb`) contains the details of the CNN model experimentation.

With these steps, you should be able to replicate the project and explore the EEG data processing, image extraction, and CNN model experimentation involved. Adjust the file paths and configurations as needed for your setup.
