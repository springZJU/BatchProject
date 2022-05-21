function varargout = clickTrainAdaptationGenFunc(params,datapath,varargin)
if nargin<2
    disp('Please input datapath information')
    return
else

    for i = 1:2:length(varargin)
        eval([ varargin{i} '=varargin{i+1};']);
    end

eval([GetStructStr(params) '=ReadStructValue(params);']);

%% generate stimPara
load(datapath);
trialNum = data.epocs.tril.data;
errorTrial = unique(data.epocs.erro.data);
trialNum(ismember(trialNum,errorTrial)) = 0;
validIdx = trialNum>0;
trialNum = trialNum(validIdx);
if strcmp(protocolName,{'clickTrain','clickAdaptation','clickTrainAdaptation'})
fieldNames = {'trialNum','soundNum','trialOnset','trialOffset','ICI','error','clickDur','trainDur'};
fieldVal = [num2cell(trialNum) num2cell(data.epocs.num0.data(validIdx))  num2cell(data.epocs.tril.onset(validIdx)) num2cell(data.epocs.tril.offset(validIdx)) num2cell(data.epocs.ICIs.data(validIdx))...
    num2cell(data.epocs.erro.data(validIdx)) num2cell(ones(length(trialNum),1)) num2cell(TrainDur * ones(length(trialNum),1))];
end
% errorTrial = find(data.epocs.erro.data>0);

stimPara = easyStruct(fieldNames,fieldVal);

if isinf(stimPara(end).trialOffset)
    if contains(protocolName,'ClickTrain')
        stimPara(end).trialOffset = stimPara(end).trialOnset+ISI;
    else
        stimPara(end).trialOffset = stimPara(end).trialOnset+stimPara(end).ICI/1000;
    end
end
%% split spikes and LFP, add them into stimPara
[lfp,spike,sortdata] = getRawdata(datapath,params);

for Paranum = 1:length(stimPara)
    lfpBuffer{Paranum,1} = lfp.rawdata(:,lfp.T>stimPara(Paranum).trialOnset*1000&lfp.T<stimPara(Paranum).trialOffset*1000);
    if ~isempty(spike)
    stimPara(Paranum).Spikeraw = cellfun(@(x) x(x>stimPara(Paranum).trialOnset&x<stimPara(Paranum).trialOffset)-stimPara(Paranum).trialOnset,spike,'UniformOutput',false);
    end
    if ~isempty(sortdata)
        stimPara(Paranum).Spikesort = cellfun(@(x) x(x>stimPara(Paranum).trialOnset&x<stimPara(Paranum).trialOffset)-stimPara(Paranum).trialOnset,sortdata,'UniformOutput',false);
    end
end


%% reshape LFPdata to same length

minLength = min(cellfun(@length,lfpBuffer));
lfpSameL = cellfun(@(x) x(:,1:minLength),lfpBuffer,'UniformOutput',false);
stimPara = addFieldToStruct(stimPara,lfpSameL,'Lfpdata');

if strcmp(protocolName,{'clickTrain','clickAdaptation','clickTrainAdaptation'})
varargout = clickTrainAdaptation(stimPara,params);
end


% %% create figures for certain channels
% for ch = 1:size(spike,1)
%     Figs{ch} = figure;
%     maximizeFig(Figs{ch});
% end

end
