function [Az,swaplabels] = plotROCCurve(truelabel,predictedlabel,plotROC,classifiername )


if ~exist('classifiername','var') || isempty(classifiername)
    classifiername = '';
end
if ~exist('plotROC','var') || isempty(plotROC)
    plotROC = 1;
end


[falsepos,truepos,~,Az] = perfcurve(truelabel,predictedlabel,1); % finds false and true positives, plus area under the curve
if Az>.5
    swaplabels = 0;
else
    swaplabels = 1;
end

% Plot ROC
if plotROC
    figure;
    plot(falsepos,truepos);
    xlabel('False Positive Rate'); ylabel('True Positive Rate');
    title(['Receiver Operator Curve; Az = ' num2str(Az)])
    suptitle(['Model Results for ' classifiername]);
end

end

