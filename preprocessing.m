clc; clear all; close all;

%% SETTINGS
% Save settings
SAVE_DATA = true;
PROCESSED_DATA_VERSION = 1; % which folder the data will save to (ie data_v1)

% EEG filter
low_cut_off = .1;
hi_cut_off = 55;

%% Load and Preprocess data
for subject = 1:8
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
    EEG_test = pop_importdata('data', 'X_EEG_TEST', 'srate', 1000, 'xmin', -.2, 'chanlocs', 'standard60.loc');
    
    % remove channel baseline means from each channel 
    EEG = pop_rmbase(EEG, (1:199));
    EEG_test = pop_rmbase(EEG_test, (1:199));
    
    % remove bad channels
    [EEG, indelec, measure, com] = pop_rejchan(EEG, 'elec', (1:EEG.nbchan), 'threshold', 3, 'measure', 'kurt', 'norm', 'on');
    % remove the same bad chanels from the test data
    EEG_test.data(indelec,:,:) = [];
    EEG_test.nbchan = EEG.nbchan;
    if subject ~= 6 %exclude subject 6 for whom we dont have chanloc info
        EEG_test.chanlocs(indelec) = [];
    end
    
    % remove eye-blinks
%     ICA = pop_runica(EEG, 'concatenate', 'off');
%     ICA = pop_selectcomps(ICA, (1:20));

%     % apply filter
%     EEG = pop_eegfilt(EEG, 1, 50, 50);

    % normalize features of training data
    chan_data = reshape(EEG.data, [size(EEG.data, 1), size(EEG.data, 2) * size(EEG.data, 3)]);
    chan_means = mean(chan_data, 2);
    chan_means_train = repmat(chan_means, 1, EEG.pnts, EEG.trials);
    chan_std = std(chan_data, [], 2);
    chan_std_train = repmat(chan_std, 1, EEG.pnts, EEG.trials);
    EEG.data = (EEG.data - chan_means_train)./chan_std_train;
    
    % normalize features of testing data
    chan_means_test = repmat(chan_means, 1, EEG_test.pnts, EEG_test.trials);
    chan_std_test = repmat(chan_std, 1, EEG_test.pnts, EEG_test.trials);
    EEG_test.data = (EEG_test.data - chan_means_test)./chan_std_test;
    
    if SAVE_DATA
        SAVE_PATH = fullfile('data', ['data_v' num2str(PROCESSED_DATA_VERSION)], ['Subject_', num2str(subject), '.mat']);
        save(SAVE_PATH, 'EEG', 'Y_EEG_TRAIN', 'EEG_test');
        disp(['Data saved for subject: ' num2str(subject)]);
    end
end
 
disp('done')