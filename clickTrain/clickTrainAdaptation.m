function varargout = clickTrainAdaptation(stimPara,params,varargin)
for i = 1:2:length(varargin)
    eval([ varargin{i} '=varargin{i+1};']);
end
eval([GetStructStr(params) '=ReadStructValue(params);']);

%%  classify based on ICI and process data
ICIs = unique([stimPara.ICI]');
params.ICIs = ICIs;
optPSTH.binsize = 20; optPSTH.binstep = 10; % for psth calculation
params.optPSTH = optPSTH;

for iciN = 1:length(ICIs)
    params.curICI = ICIs(iciN); % current ICI
    %% select certain trials
    buffer = stimPara([stimPara.ICI]' == ICIs(iciN) & [stimPara.error]' ~= 1);

    %% spike process for individual ICIs
    
    if contains(protocolName,'ClickTrain')
        [stimType.(['ICI' num2str(ICIs(iciN))] ) frate(:,iciN)  raster(:,iciN) psth(:,iciN) click(:,iciN) RS(:,iciN) percentAdapt(:,iciN) RRTF(:,iciN)] = clickTrianSpikeInICI(buffer,'analyseWin',[0 TrainDur+50],'params',params);
    else
        [stimType.(['ICI' num2str(ICIs(iciN))] ) frate(:,iciN)  raster(:,iciN) psth(:,iciN) click(:,iciN)  ] = clickTrianSpikeInICI(buffer,'analyseWin',[0 TrainDur+50],'params',params);
    end
end

%% integrate results
rez.raster = easyStruct(fields(stimType),raster); % save raster time  and trialNum
rez.frate = easyStruct(fields(stimType),frate); % save mean & SE of frate and individual frate for each trial
rez.psth = easyStruct(fields(stimType),psth); % save psth and bin params
rez.click = easyStruct(fields(stimType),click); % save all mean and mean along each click and rawdata
% 'RS', 'percentAdapt' and 'RRTF' only for clickTrain stimuli
if contains(protocolName,'ClickTrain')
    rez.RS = easyStruct(fields(stimType),RS); % save mean & SE of RS and p-value with 13.8 and individual RS for each trial
    rez.percentAdapt = easyStruct(fields(stimType),percentAdapt); % save percentAdapt  and click-frate array
    rez.RRTF = easyStruct(fields(stimType),RRTF); % save TTRF and rawdata
end

if contains(protocolName,'ClickTrain') % click train stimuli
    %% analyse through diffenrent ICIs, for click train sounds
    [rez.spearman rez.clickSlope] = clickTrianSpikeThroughICI(rez,'params',params);
elseif contains(protocolName,'ClickAdaptation')
    %% adaptation analysis for single click
    optPSTH.binsize = 5; optPSTH.binstep = 1; % for psth calculation
    params.optPSTH = optPSTH;

    rez = adaptationSpikeAnalysis(rez,'params',params,'stimPara',stimPara,'analyseWin',[0 50]);
end

varargout{1} = rez;
varargout{2} = stimType;
varargout{3} = stimPara;
end