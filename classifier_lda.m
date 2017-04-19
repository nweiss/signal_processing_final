clear all; clc;
classifiername = 'kmeans';
disp('running kmeans');

%% SETTINGS
% Load Settings
PROCESSED_DATA_VERSION = 0; % which data to load (currently only works with version 0; needs the X_EEG_TRAIN variable to be intact as chanxtimexepoch)
subjects = 1:8; % which subjects to run
savedata = 0; % will save data to results folder
ploteachsubject = 0; % will plot ROC for every subject

%% Load data and build classifier
Azs = zeros(1,length(subjects));
trainpredictions = cell(1,length(subjects));
for i = 1:length(subjects); %[1, 2, 3, 4, 5, 7, 8]
    clear EEG
    clear X_EEG_TRAIN
    clear X_EEG_TEST
    clear Y_EEG_TRAIN
    
    % Load data
    LOAD_PATH = fullfile('data', ['data_v' num2str(PROCESSED_DATA_VERSION)], ['Subject_', num2str(subjects(i)), '.mat']);
    load(LOAD_PATH);
    
    neworder = randperm(length(Y_EEG_TRAIN));
    truelabels = Y_EEG_TRAIN(neworder);
    reordertrain = X_EEG_TRAIN(:,:,neworder);
    
    % Average over time 
    x = squeeze(mean(X_EEG_TRAIN(:,250:500,neworder),2));
    x = x';
    % possible ways to improve: reduce to only relevant channels?
    
    %         x = reshape(x,[size(x,3), size(x,2)*size(x,1)]);

    
    % Run SVM
    lineardiscriminator = fitcdiscr(traindata,trainlabels);
    
    % Find ROC curve; sometimes the clustering will pick the wrong label
    % for the classes; if this is the case (Az<.5), swap them and replot
    [Az,swaplabels] = plotROCCurve(truelabels,idx,ploteachsubject,classifiername);
    if swaplabels
        idx = logical(idx);
        idx = ~idx;
        idx = double(idx);
        [Az,swaplabels] = plotROCCurve(truelabels,idx,ploteachsubject,classifiername);
    end
    
    % Store each subject's data
    Azs(i) = Az;
    trainpredictions{i} = idx; 
    
end

figure; 
plot(Azs);
title(['Az by Subject for ' classifiername]);
ylim([0 1]);
xlabel('subject'); ylabel('Az');

if savedata
    resultpath = fullfile('results',['kmeans_' num2str(PROCESSED_DATA_VERSION)]);
    save(resultpath,'Azs','trainpredictions');
end

disp('done')