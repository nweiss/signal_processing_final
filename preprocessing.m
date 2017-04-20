clc; clear all; close all;

%% SETTINGS
% Save settings
SAVE_DATA = false;
PROCESSED_DATA_VERSION = 2; % which folder the data will save to (ie data_v1)

% EEG filter
low_cut_off = .1;
hi_cut_off = 55;

%% Load and Preprocess data
for subject = 3 %1:8
    clear EEG
    clear X_EEG_TRAIN
    clear X_EEG_TEST
    clear Y_EEG_TRAIN
    clear n_TRAIN
    clear n_TEST
    clear n_TRAIN_CAR
    clear n_TRAIN_FACE
    clear nTrial
    
    % Load data and import into EEGlab format
    LOAD_PATH = fullfile('data', 'data_raw', ['Subject_', num2str(subject), '.mat']);
    load(LOAD_PATH);
    EEG = pop_importdata('data', 'X_EEG_TRAIN', 'srate', 1000, 'xmin', -.2, 'chanlocs', 'standard60.loc');

    % remove channel baseline means from each channel 
    EEG = pop_rmbase(EEG, (1:200));
    
    % remove bad channels
    [EEG, indelec, measure, com] = pop_rejchan(EEG, 'elec', (1:EEG.nbchan), 'threshold', 3, 'measure', 'kurt', 'norm', 'on');
    
    % remove eye-blinks
%     ICA = pop_runica(EEG, 'concatenate', 'off');
%     ICA = pop_selectcomps(ICA, (1:20));
    
    if SAVE_DATA
        SAVE_PATH = fullfile('data', ['data_v' num2str(PROCESSED_DATA_VERSION)], ['Subject_', num2str(subject), '.mat']);
        save(SAVE_PATH, 'EEG', 'Y_EEG_TRAIN', 'X_EEG_TEST');
        disp(['Data saved for subject: ' num2str(subject)]);
    end
end
 
disp('done')