# signal_processing_final
Final project for signal processing class

Ideas for improving accuracy:
1) For each subject's test data, use the other subjects training data to form a prior, and then update that prior with the training data for that specific subject. That way, we emphasize the subject's own training data over other subjects'.
2) Normalize EEG signals based on time before signal onset.
3) Remove blinks. Explore how to do this.
4) Use matlab package that tries all machine learning approaches.
