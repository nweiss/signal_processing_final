clc; clear all; close all;


%% Aggregate the data
EEG_train = [];
EEG_test = [];
Y = [];
subject_key_train = [];
subject_key_test = [];
for i = 1:8
    LOAD_PATH = ['Subject_', num2str(i), '.mat'];
    load(LOAD_PATH);
    
    EEG_train = cat(3, EEG_train, X_EEG_TRAIN);
    EEG_test = cat(3, EEG_test, X_EEG_TEST);
    Y = cat(1, Y, Y_EEG_TRAIN);
    subject_key_train = cat(1, subject_key_train, i*ones(n_TEST, 1));
    subject_key_test = cat(1, subject_key_test, i*ones(n_TEST, 1));
end