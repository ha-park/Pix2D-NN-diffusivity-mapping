# NN diffusivity mapping
Code repository for Pix2D diffusivity mapping.
Requires matlab-storm published by Zhuanglab (https://github.com/ZhuangLab/matlab-storm)<br />
Codes are written to process images in .dax format and localization data from Insight3.
Localization with Insight3 can be replaced with Python: https://github.com/ZhuangLab/storm-analysis

## Training data generation
* Use codes under Matlab > Simulation
* Training sets with multiple single-molecule brightness and shot noise level can be generated with Batch_Training_set_generation.m
* Set exposure time, pixel length, gain factor and PSF size to match your imaging setup.
* Run localization analysis to generated Dax image files.
* Generate training input from .dax and .bin file with Training_set_extraction.m
* Generate augmented training input with training_set_combine.m
## Training CNN
* Use codes under Matlab > Training
* To sweep hyperparamters, run Batch_training_parameter_sweep.m
* Run Batch_training.m for to get trained CNN
## Processing Dax image files
* Run localization for single-molecule images
* Use Data sampling > Batch_ROI_extraction to extract single-molecule signals and positions
* Run Data processing > Batch_D_mapper_from_array.m to generate spatial diffusivity map in desired bin size
* Run Data processing > Dmap_rendering.m to plot 2D diffusivity map in color scale
