clear all; close all; clc;

%% SETTINGS
% Load Settings
PROCESSED_DATA_VERSION = 1;

%% Load data and build classifier
AUCs = zeros(8,1);
for subject = 1:8
    clear EEG
    clear EEG_test
    clear Y_EEG_TRAIN
    
    LOAD_PATH = fullfile('data', ['data_v' num2str(PROCESSED_DATA_VERSION)], ['Subject_', num2str(subject), '.mat']);
    load(LOAD_PATH);

%     %% DIMENSIONALITY REDUCTION V1
%     % Find which channels carry the most discrimitory information
%     disc_times = [380:460, 530:650]; % these are the frames in the eeg data that correspond to the maximal discriminitory times
%     chan_mean_0 = mean(EEG.data(:,disc_times,Y_EEG_TRAIN==0),3);
%     chan_mean_1 = mean(EEG.data(:,disc_times,Y_EEG_TRAIN==1),3);
%     chan_diff = chan_mean_1 - chan_mean_0;
%     chan_disc = sum(abs(chan_diff), 2);
%     
%     [chan, ind] = sort(chan_disc, 'descend');
%     chan_ind = ind(1:6);
%     
%     figure
%     plot(chan, '.')
%     title('relative discrimintory information in a given channel')
%     xlabel('channels (sorted)')
%     ylabel('sum of difference between trial types during discrimintory times')
%     
%     time_windows = 10;
%     window_size = 200/time_windows;
%     window_starts = [380:window_size:460-window_size, 530:window_size:650-window_size];
%     window_stops = window_starts+window_size-1;
%     
%     X_flattened = zeros(EEG.trials, time_windows * length(chan_ind));
%     
%     for i = 1:EEG.trials
%         counter = 1;
%         for j = 1:length(window_starts)
%             X_flattened(i, counter:counter+5) = mean(EEG.data(chan_ind, window_starts(j):window_stops(j), i),2);
%             counter = counter+6;
%         end
%     end
    
    %% DIMENSIONALITY REDUCTION V2
    % only use data from the times indicated in the sajda paper (180-250ms, 330-450ms)
    tmp1 = EEG.data(:,[380:650],:);
    
    % downsample the data
    tmp2 = zeros(size(tmp1,1), ceil(size(tmp1,2)/4), size(tmp1, 3));
    for i = 1:EEG.trials
        for j = 1:EEG.nbchan
            tmp2(j,:,i) = downsample(tmp1(j,:,i), 4); 
        end
    end
    
    % reshape the data to be trials by (channels*samples)
    X = zeros(EEG.trials, size(tmp2,1)*size(tmp2,2));
    for i = 1:EEG.trials
        X(i,:) = reshape(tmp2(:,:,i), 1, size(tmp2,1)*size(tmp2,2));
    end
    
    [coeff,score,latent,tsquared,explained,mu] = pca(X);
    X_flattened = score;
    X_flattened = X_flattened(:,1:8); % empirically found that 1:8 worked best
    
    %% LR
    pi_hat = zeros(EEG.trials, 2);
    for i = 1:EEG.trials
        
        %leave out the validation trial
        X = X_flattened;
        X(i,:) = [];
        Y = Y_EEG_TRAIN;
        Y(i,:) = [];
        Y = Y+1;

        B = mnrfit(X,Y);
        pi_hat(i,:) = mnrval(B, X_flattened(i,:));
        
    end
    
    Y_hat = zeros(EEG.trials, 1);
    for i = 1:length(pi_hat)
        if pi_hat(i,1)<pi_hat(i,2)
            Y_hat(i) = 1;
        else
            Y_hat(i) = 2;
        end
    end
    
    [x_roc, y_roc, T, AUC] = perfcurve((Y_EEG_TRAIN+1), Y_hat, 1);
    disp(['AUC: ', num2str(AUC)])
    AUCs(subject) = AUC;
end
disp(['mean of AUCs: ', num2str(mean(AUCs))])
disp(['mean of AUCs(2:8): ', num2str(mean(AUCs(2:8)))])

disp('done')

figure
plot(AUCs)
title('AUCs for logistic regression on PCA data')
xlabel('subject')
ylabel('AUC')
ylim([0,1])