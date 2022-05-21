function resAUC = AUCcal(data,devDiff)
labels = data(:,2);
scores = data(:,1);
if devDiff ==1
    randIdx=randperm(length(labels));
    labels(randIdx(1:floor(length(randIdx)/2)))=1;
end
[~,~,~,resAUC]=perfcurve(labels,scores,1);
end