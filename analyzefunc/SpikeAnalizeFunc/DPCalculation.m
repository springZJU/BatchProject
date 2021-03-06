function resDP = DPCalculation(TrialParas,DPPlotPara,varargin)
eval([GetStructStr(DPPlotPara) '=ReadStructValue(DPPlotPara);']);
singleTrial = true;
for i = 1:2:length(varargin)
    eval([ varargin{i} '=varargin{i+1};']);
end

%% choose spikes according to existence of spike type
if isfield(TrialParas,'AlignmentSpikeSort') & all(cellfun(@isempty,{TrialParas.Spikesort}))
    AlignSpikeBuffer = {TrialParas.AlignmentSpikeSort}';
else
    AlignSpikeBuffer = {TrialParas.AlignmentSpikeRaw}';
end
if ~exist('alignment','var')
    alignment = fields(AlignSpikeBuffer{1});
end

%% Firing rate of different bins for single trials
if singleTrial
    for aligNum = 1:length(alignment) %Alignment methods
        psthDP = [];
        for Paranum = 1:size(TrialParas,1) %Trialnum
            spikeBuffer = AlignSpikeBuffer{Paranum}.(alignment);
            if exist('Edge','var')
                resBuffer = calPsth(spikeBuffer,PsthSet,scaleFactor,'Edge',Edge);
                psthDP = [psthDP [resBuffer.y]']; % row: binN, column:trialN
            elseif exist('win','var')
                resBuffer = FRcal(spikeBuffer,win);
                psthDP = [psthDP cell2mat(struct2cell(resBuffer))];
            end
        end
    end
end

psthDP = psthDP';% row: trialN, column: binN
if size(psthDP,1) < length(TrialParas)
    gap = length(TrialParas)-size(psthDP,1);
    psthDP(end+1:end+gap,:) = psthDP(end-gap+1:end,:);
end
%% zscore for diffs individually
IsControl = strcmp({TrialParas.CueType},'control');
IsDiff = ~IsControl;
cue_types = unique({TrialParas(IsDiff).CueType});
for cueN = 1:length(cue_types) % CueType
    zBuffer.(cue_types{cueN}) = []; zBehav.(cue_types{cueN}) = [];
    for devDiff = unique([TrialParas.Diff]) %Diff num
        if devDiff == 1
%             Idx = find([TrialParas.Diff]==devDiff);
        continue
        else
            Idx = find([TrialParas.Diff]==devDiff & strcmp({TrialParas.CueType},cue_types{cueN}));
        end
        dataBuffer = psthDP(Idx,:);
        behavBuffer = [TrialParas(Idx).PushTime]';
        behavBuffer(behavBuffer>0)=1;
        zBuffer.(cue_types{cueN}) = [zBuffer.(cue_types{cueN}); zscore(dataBuffer)];
        zBehav.(cue_types{cueN}) = [zBehav.(cue_types{cueN}); behavBuffer];
    end
end

%% calculate DP for different bins
for cueN = 1:length(cue_types) % CueType
    cueZBuffer = zBuffer.(cue_types{cueN});
    cueZBehav = zBehav.(cue_types{cueN});
    for binN = 1:size(cueZBuffer,2)
        DPzBuffer = [cueZBuffer(:,binN) cueZBehav];
        if exist('Edge','var')
            resDP.(cue_types{cueN})(1,binN) = DPcal(DPzBuffer,1000,'timePoint', resBuffer(binN).edges(3));
        elseif exist('win','var')
            resDP.(cue_types{cueN})(1,binN) = DPcal(DPzBuffer,1000,'win', win(binN,:));
        end
    end
end
        

