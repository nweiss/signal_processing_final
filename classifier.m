clear all; close all; clc;

%% SETTINGS
% Load Settings
PROCESSED_DATA_VERSION = 2;

%% Load data and build classifier
for subject = 1 %[1, 2, 3, 4, 5, 7, 8]
    clear EEG
    clear X_EEG_TEST
    clear Y_EEG_TRAIN
    
    LOAD_PATH = fullfile('data', ['data_v' num2str(PROCESSED_DATA_VERSION)], ['Subject_', num2str(subject), '.mat']);


end

disp('done')