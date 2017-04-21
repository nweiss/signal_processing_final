clear all; close all; clc;

%% SETTINGS
% Load Settings
PROCESSED_DATA_VERSION = 1;

%% Load data and build classifier
AUCs = zeros(8,1);
for subject = 5 %1:8
    clear EEG
    clear EEG_test
    clear Y_EEG_TRAIN
    
    LOAD_PATH = fullfile('data', ['data_v' num2str(PROCESSED_DATA_VERSION)], ['Subject_', num2str(subject), '.mat']);
    load(LOAD_PATH);
    
    %% PCA DIMENSIONALITY REDUCTION
    % only use data from the times indicated in the sajda paper
    tmp1 = EEG.data(:,380:650,:);
    
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
    X_flattened = X_flattened(:,1:10);
    
    %% Adaboost 
    y_hat = zeros(EEG.trials, 1);
    for i = 1:EEG.trials
        
        %leave out the validation trial
        X = X_flattened;
        X(i,:) = [];
        Y = Y_EEG_TRAIN;
        Y(i,:) = [];
        Y = Y+1;
        
        [estimateclass, model] = adaboost('train', X, Y, 1000);
        Y_hat(i) = adaboost('apply', X_flattened(i,:), model);
        
    end
    
    [x_roc, y_roc, T, AUC] = perfcurve((Y_EEG_TRAIN+1), Y_hat, 1);
    disp(['AUC: ', num2str(AUC)])
    AUCs(subject) = AUC;
end

disp('done')

figure
plot(AUCs)
title('AUCs for logistic regression on PCA data')
xlabel('subject')
ylabel('AUC')
ylim([0,1])