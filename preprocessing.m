clc; clear all; close all;

%% SETTINGS
% Save settings
SAVE_DATA = true;
PROCESSED_DATA_VERSION = 4; % which folder the data will save to (ie data_v1)

RM_EYEBLINKS = false;
FILTER = false;
RM_BASELINE = true;
RM_BAD_CHAN = true;
NORMALIZE = true;
DIM_REDUC = true;

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
    if RM_BASELINE
        EEG = pop_rmbase(EEG, (1:199));
        EEG_test = pop_rmbase(EEG_test, (1:199));
    end
    
    % remove bad channels
    if RM_BAD_CHAN
        [EEG, indelec, measure, com] = pop_rejchan(EEG, 'elec', (1:EEG.nbchan), 'threshold', 3, 'measure', 'kurt', 'norm', 'on');
        % remove the same bad chanels from the test data
        EEG_test.data(indelec,:,:) = [];
        EEG_test.nbchan = EEG.nbchan;
        if subject ~= 6 %exclude subject 6 for whom we dont have chanloc info
            EEG_test.chanlocs(indelec) = [];
        end
    end
    
    % remove eye-blinks
    if RM_EYEBLINKS
        ICA = pop_runica(EEG, 'concatenate', 'off');
        ICA = pop_selectcomps(ICA, (1:20));
    end
    
    % apply filter
    if FILTER
        EEG = pop_eegfilt(EEG, 1, 50, 50);
    end

    % normalize features of training data
    if NORMALIZE
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
    end
    
    %% PCA DIMENSIONALITY REDUCTION
    if DIM_REDUC
        % only use data from the times indicated in the sajda paper (180-250ms, 330-450ms)
        X_windowed_train = EEG.data(:,[380:650],:);
        X_windowed_test = EEG_test.data(:,[380:650],:);
        
        % combine the training set and test set so that you can break them
        % both down with the same principle components
        X_windowed_all = cat(3, X_windowed_train, X_windowed_test);
        
        % downsample the data
        X_dsampled = zeros(size(X_windowed_all,1), ceil(size(X_windowed_all,2)/4), size(X_windowed_all, 3));
        for i = 1:size(X_windowed_all, 3)
            for j = 1:EEG.nbchan
                X_dsampled(j,:,i) = downsample(X_windowed_all(j,:,i), 4); 
            end
        end

        % reshape the data to be trials by (channels*samples)
        X_reshaped = zeros(size(X_dsampled,3), size(X_dsampled,1)*size(X_dsampled,2));
        for i = 1:size(X_reshaped,1)
            X_reshaped(i,:) = reshape(X_dsampled(:,:,i), 1, size(X_dsampled,1)*size(X_dsampled,2));
        end

        [coeff,score,latent,tsquared,explained,mu] = pca(X_reshaped);
        X_reduced = score;
        %X_reduced = X_reduced(:,1:8); % empirically found that 1:8 worked best
        
        X_train = X_reduced(1:EEG.trials,:);
        X_test = X_reduced(EEG.trials+1:end,:);
    end
    
    if SAVE_DATA
        SAVE_PATH = fullfile('data', ['data_v' num2str(PROCESSED_DATA_VERSION)], ['Subject_', num2str(subject), '.mat']);
        save(SAVE_PATH, 'EEG', 'Y_EEG_TRAIN', 'EEG_test', 'X_train', 'X_test');
        disp(['Data saved for subject: ' num2str(subject)]);
    end
end
 
disp('done')