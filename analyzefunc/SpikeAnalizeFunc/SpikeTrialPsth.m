function Psth = SpikeTrialPsth(TrialParas,PSTHPlotPara,varargin)
eval([GetStructStr(PSTHPlotPara) '=ReadStructValue(PSTHPlotPara);']);
singleTrial = false;
for i = 1:2:length(varargin)
    eval([ varargin{i} '=varargin{i+1};']);
end
% choose spikes according to existence of
if isfield(TrialParas,'AlignmentSpikeSort') & all(cellfun(@isempty,{TrialParas.Spikesort}))

    AlignSpikeBuffer = {TrialParas.AlignmentSpikeSort}';
else
    AlignSpikeBuffer = {TrialParas.AlignmentSpikeRaw}';
end
pushBuffer = [TrialParas.PushTime]';
alignment = fields(AlignSpikeBuffer{1});
%% Psth for single trials
if singleTrial
    for Paranum = 1:size(TrialParas,1) %Trialnum
        for aligNum = 1:length(alignment) %Alignment methods
            spikeBuffer = AlignSpikeBuffer{Paranum}.(alignment{aligNum});
            Psth.singleTrial(Paranum).(alignment{aligNum}) = calPsth(spikeBuffer,PsthSet,1,'Edge',Edge.(alignment{aligNum}));
        end
    end
end
%% Psth for diff groups
behavResType = {'Correct','Wrong','All'};
IsControl = strcmp({TrialParas.CueType},'control');
IsDiff = ~IsControl;
cue_types = unique({TrialParas(IsDiff).CueType});
for dev_diff = unique([TrialParas.Diff]) %Diff num
    for cueN = 1:length(cue_types) % CueType
            if dev_diff == 1
                Idx.All = find([TrialParas.Diff]==dev_diff);
                Idx.Correct = find([TrialParas.Diff]==dev_diff & {TrialParas.CorrectWrong} == "Correct");
                Idx.Wrong = find([TrialParas.Diff]==dev_diff & {TrialParas.CorrectWrong} == "Wrong");
                pushGroup = pushBuffer(Idx.Wrong);
            else
                Idx.All = find([TrialParas.Diff]==dev_diff & strcmp({TrialParas.CueType},cue_types{cueN}));
                Idx.Correct = find([TrialParas.Diff]==dev_diff & strcmp({TrialParas.CueType},cue_types{cueN}) & {TrialParas.CorrectWrong} == "Correct");
                Idx.Wrong = find([TrialParas.Diff]==dev_diff & strcmp({TrialParas.CueType},cue_types{cueN}) & {TrialParas.CorrectWrong} == "Wrong");
                pushGroup = pushBuffer(Idx.Correct);
            end
            Psth.(cue_types{cueN})(dev_diff).behavRes = calPsth(pushGroup,PsthSet,scaleFactor,'Edge',[0 1000]);
            for CWType = 1:length(behavResType) %correct/wrong/all
                for aligNum = 1:length(alignment) %Alignment methods
                    spikeGroup = [];
                    for trialN = 1:length(Idx.(behavResType{CWType}))
                        spikeGroup = [spikeGroup AlignSpikeBuffer{Idx.(behavResType{CWType})(trialN)}.(alignment{aligNum})];
                    end                  
                    Psth.(cue_types{cueN})(dev_diff).(alignment{aligNum}).(behavResType{CWType}) = calPsth(spikeGroup,PsthSet,scaleFactor,'Edge',Edge.(alignment{aligNum}),'nTrial',trialN);
                end
            end
    end
end

