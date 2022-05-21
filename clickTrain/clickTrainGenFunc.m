function [stimPara,res] = clickTrainGenFunc(params)
eval([GetStructStr(params) '=ReadStructValue(params);']);

%% generate stimPara
TrainDur = 1600; % ms
interval = 6; % sec.
params.FsNew  = 1200;
params.TrainDur = TrainDur;
ISI = TrainDur/1000 + interval % sec.
params.ISI = ISI;
datapath = 'F:\zdata\rootpath\LinearArrayLfp\AC\20220312\M1_A53L21\ClickTrain\data.mat';
trialNum = num2cell(data.epocs.tril.data);
fieldNames = {'trialNum','trialOnset','trialOffset','ICI','error','clickDur','trainDur'};
fieldVal = [trialNum num2cell(data.epocs.tril.onset) num2cell(data.epocs.tril.offset) num2cell(data.epocs.ICIs.data)...
      num2cell(data.epocs.erro.data) num2cell(ones(length(trialNum),1)) num2cell(TrainDur * ones(length(trialNum),1))];

stimPara = easyStruct(fieldNames,fieldVal);

if isinf(stimPara(end).trialOffset)
    stimPara(end).trialOffset = stimPara(end).trialOnset+ISI;
end
%% split spikes and LFP, add them into stimPara
[lfp,spike,sortdata] = getRawdata(datapath,params)

for Paranum = 1:length(stimPara)
    lfpBuffer{Paranum,1} = lfp.rawdata(:,lfp.T>stimPara(Paranum).trialOnset*1000&lfp.T<stimPara(Paranum).trialOffset*1000);
    stimPara(Paranum).Spikeraw = cellfun(@(x) x(x>stimPara(Paranum).trialOnset&x<stimPara(Paranum).trialOffset)-stimPara(Paranum).trialOnset,spike,'UniformOutput',false);
    if ~isempty(sortdata)
        stimPara(Paranum).Spikesort = cellfun(@(x) x(x>stimPara(Paranum).trialOnset&x<stimPara(Paranum).trialOffset)-stimPara(Paranum).trialOnset,sortdata,'UniformOutput',false);
    end
end

%% reshape LFPdata to same length

minLength = min(cellfun(@length,lfpBuffer));
lfpSameL = cellfun(@(x) x(:,1:minLength),lfpBuffer,'UniformOutput',false);
stimPara = addFieldToStruct(stimPara,lfpSameL,'Lfpdata');

%%  classify based on ICI
ICIs = unique([stimPara.ICI]');
params.ICIs = ICIs;
for iciN = 1:length(ICIs)
    params.curICI = ICIs(iciN); % current ICI
    %% select certain trials
    buffer = stimPara([stimPara.ICI]' == ICIs(iciN) & [stimPara.error]' ~= 1);
    stimType.(['ICI' num2str(ICIs(iciN))] ) = buffer;
    %% spike process & plot
    % calculate raster, firing rate ,psth, where output has < chs > rows and < length(ISIs) > columns
    [buffer frate(:,iciN)  raster(:,iciN) psth(:,iciN) RS(:,iciN) percentAdapt(:,iciN) RRTF(:,iciN)] = clickTrianSpikeInICI(buffer,'analyseWin',[0 TrainDur+50],'params',params);
end

%% integrate results
rez.raster = easyStruct(fields(stimType),raster); % save raster time  and trialNum
rez.frate = easyStruct(fields(stimType),frate); % save mean & SE of frate and individual frate for each trial
rez.psth = easyStruct(fields(stimType),psth); % save psth and bin params
rez.RS = easyStruct(fields(stimType),RS); % save mean & SE of RS and p-value with 13.8 and individual RS for each trial
rez.percentAdapt = easyStruct(fields(stimType),percentAdapt); % save percentAdapt  and click-frate array
rez.RRTF = easyStruct(fields(stimType),RRTF); % save TTRF and rawdata


%% analyse through diffenrent ICIs
[rez.spearman rez.slope] = clickTrianSpikeThroughICI(rez,'params',params);

%% create figures for certain channels
for ch = 1:size(spike,1)
    Figs{ch} = figure;
    maximizeFig(Figs{ch});
end

end
