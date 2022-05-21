function res = clickTrainRaster(trialBuffer)
%% if sorted, use sorted data
if isfield(trialBuffer,'sortdata')
    spikeBuffer = trialBuffer.sortdata;
else
    spikeBuffer = trialBuffer.Spikeraw;
end

chAll = size(trialBuffer(1).Lfpdata,1);
for ch = 1:chAll
    res{ch,1} = [];
for trialN = 1:length(trialBuffer)
    buffer = trialBuffer(trialN).Spikeraw;
    res{ch,1} = [res{ch,1} ; buffer{ch} ones(length(buffer{ch}),1)*trialN];
end
end