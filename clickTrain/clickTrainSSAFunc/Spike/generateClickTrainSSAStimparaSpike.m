function batchOpt = generateClickTrainSSAStimparaSpike(params,datapath)
eval([GetStructStr(params) '=ReadStructValue(params);']);
run('E:\clickTrain\defClickTrainStimStr.m');
%% generate stimPara
load(datapath);

ISI = data.epocs.tril.onset(2) - data.epocs.tril.onset(1);
if ~any(data.epocs.tril.data == 0)
    trialNum = data.epocs.tril.data;
else
    trialNum = data.epocs.Swep.data+ 1;
end

stimType = stimStr(SSAPairs);
stimType = cellfun(@(x) strrep(x,'S1',[num2str(clickICI(1)) 'ms']),stimType,'UniformOutput',false);
stimType = cellfun(@(x) strrep(x,'S2',[num2str(clickICI(2)) 'ms']),stimType,'UniformOutput',false);
savePath = erase(datapath,'\data.mat');


if isfield(data.epocs,'erro')
    errorTrial = unique(data.epocs.erro.data);
    errorInfo = data.epocs.erro.data;
else
    errorTrial = [];
    errorInfo = zeros(length(trialNum),1);
end

trialNum(ismember(trialNum,errorTrial)) = 0;
validIdx = trialNum>0;
trialNum = trialNum(validIdx);
if contains(protocolName,'ClickTrainSSA')
    fieldNames = {'trialNum','soundNum','trialOnset','trialOffset','order','clickDur','trainDur'};
    fieldVal = [num2cell(trialNum) num2cell(data.epocs.num0.data(validIdx))  num2cell(data.epocs.tril.onset(validIdx)) num2cell(data.epocs.tril.onset(validIdx) + ISI) num2cell(data.epocs.ordr.data(validIdx))...
        num2cell(ones(length(trialNum),1)) num2cell(TrainDur * ones(length(trialNum),1))];
end
% errorTrial = find(data.epocs.erro.data>0);

stimPara = easyStruct(fieldNames,fieldVal);
% ISI = stimPara(1).trialOffset - stimPara(1).trialOnset;

if isinf(stimPara(end).trialOffset)
    stimPara(end).trialOffset = stimPara(end).trialOnset+ISI;
end
sound_all = cell2mat((struct2cell(stimPara))');
soundN = sound_all(:,2);
std1Idx = find(soundN == 1);
devIdx = std1Idx - 1;
devIdx(1) = [];
devIdx = [devIdx; length(soundN)];
nToDev = soundN;
for i = 1:length(devIdx)
    nToDev(std1Idx(i):devIdx(i)) = soundN(devIdx(i)) - soundN(std1Idx(i):devIdx(i));
end
stimPara = addFieldToStruct(stimPara,num2cell(nToDev),'nToDev');


orders = [stimPara.order]';
try
    orders(devIdx) = orders(devIdx-1);
catch
end
stdOrd = orders;
stimPara = addFieldToStruct(stimPara,num2cell(stdOrd),'stdOrder');

[lfp,spike,sortdata,chs,lfpFs] = getRawdata(datapath,params);



for Paranum = 1:length(stimPara)

    if ~isempty(spike)
        stimPara(Paranum).Spikeraw = cellfun(@(x) x(x>stimPara(Paranum).trialOnset&x<stimPara(Paranum).trialOffset)-stimPara(Paranum).trialOnset,spike,'UniformOutput',false);
        stimPara(Paranum).SpikerawOrder = cellfun(@(x) x(x>stimPara(Paranum).trialOnset&x<stimPara(Paranum).trialOffset)-stimPara(Paranum).trialOnset,spike,'UniformOutput',false);

    end

    if ~isempty(sortdata)
        stimPara(Paranum).Spikesort = cellfun(@(x) x(x>stimPara(Paranum).trialOnset&x<stimPara(Paranum).trialOffset)-stimPara(Paranum).trialOnset,sortdata,'UniformOutput',false);
        stimPara(Paranum).SpikesortOrder = cellfun(@(x) x(x>stimPara(Paranum).trialOnset&x<stimPara(Paranum).trialOffset),sortdata,'UniformOutput',false);
    end
    lfpBuffer{Paranum} = lfp.rawdata(:,lfp.T>stimPara(Paranum).trialOnset*1000&lfp.T<stimPara(Paranum).trialOffset*1000);
    stimPara(Paranum).lfpFs = lfpFs;
end

minLength = min(cell2mat(cellfun(@(x) size(x,2),lfpBuffer,'uni',false)));
stimPara = addFieldToStruct(stimPara,cellfun(@(x) x(:,1:minLength),lfpBuffer,'uni',false)','lfpData');
spikeSort = {stimPara.Spikesort}';

%% spikeSort To firing rate
if contains(savePath,'SingleClick')
    frateWin = [0 stimPara(1).trainDur]/1000;
    frateWin0 = [0 30]/1000;
    frateWin1 = [30 stimPara(1).trainDur]/1000;
else
    frateWin = [0 stimPara(1).trainDur]/1000;
    frateWin0 = [0 50]/1000;
    frateWin1 = [50 stimPara(1).trainDur]/1000;
end
for N = 1:length(spikeSort)
    fRate{N} =  cell2mat(cellfun(@(x) length(findWithinInterval(x,frateWin)), spikeSort{N},'UniformOutput',false))/(frateWin(2)-frateWin(1));
    fRate0{N} =  cell2mat(cellfun(@(x) length(findWithinInterval(x,frateWin0)), spikeSort{N},'UniformOutput',false))/(frateWin0(2)-frateWin0(1));
    fRate1{N} =  cell2mat(cellfun(@(x) length(findWithinInterval(x,frateWin1)), spikeSort{N},'UniformOutput',false))/(frateWin1(2)-frateWin1(1));
end


stimPara = addFieldToStruct(stimPara,fRate','fRate');
stimPara = addFieldToStruct(stimPara,fRate0','fRate0');
stimPara = addFieldToStruct(stimPara,fRate1','fRate1');


%% save vars
batchOpt.frateWin = frateWin; batchOpt.frateWin0 = frateWin0;  batchOpt.frateWin1 = frateWin1;
batchOpt.stimType = stimType; % string of stimType
batchOpt.stimPara = stimPara; % sounds of oddball sequence
batchOpt.savePath = savePath; % path to save figure and processed results
batchOpt.ISI = ISI; % ISI
batchOpt.SSAPairs = SSAPairs; % order of oddball pairs
batchOpt.chs = chs; % all chs in sortdata
batchOpt.stimStr = stimStr;
if contains(savePath,'LongTerm')
    batchOpt.S1Duration = S1Duration;
end

end