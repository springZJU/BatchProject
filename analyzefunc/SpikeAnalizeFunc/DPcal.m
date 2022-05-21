function resDP = DPcal(data,iteration,varargin)
for i = 1:2:length(varargin)
    eval([ varargin{i} '=varargin{i+1};']);
end
labels = data(:,2);
scores = data(:,1);
try
[~, ~, ~, resDP.value] = perfcurve(labels, scores, 1);
for i = 1:iteration
    [~, ~, ~, AUC, ~] = perfcurve(labels(randperm(numel(labels))), scores(randperm(numel(scores))), 1);
    au(i) = AUC;
end
if resDP.value > 0.5
    resDP.p = length(find(au(1, :) > resDP.value)) / length(au);
else
    resDP.p = length(find(au(1, :) < resDP.value)) / length(au);
end
if exist('timePoint','var')
    resDP.timePoint = timePoint;
end
if exist('win','var')
    resDP.win = win;
end
catch
    resDP.value = [];
    resDP.p = [];
end
