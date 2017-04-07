clc; clear all; close all;

for subject = 1 %[1, 2, 3, 4, 5, 7, 8]
    clear X_EEG_TRAIN
    clear X_EEG_TEST
    clear Y_EEG_TRAIN
    clear n_TRAIN
    clear n_TEST
    clear n_TRAIN_CAR
    clear n_TRAIN_FACE
    clear nTrial
    
    % Load data and import into EEGlab format
    LOAD_PATH = fullfile('Data', ['Subject_', num2str(subject), '.mat']);
    load(LOAD_PATH);
    EEG = pop_importdata('data', 'X_EEG_TRAIN', 'srate', 1000, 'xmin', -.2);
    
    % Filter data
    % How should we handle filtering? Using fft because getting error for
    % short epochs when using fir
    EEG = pop_eegfilt(EEG, .1, 55, [], 0, 1, 0, [], 0);
    
    % CAR filter?
end

disp('done')