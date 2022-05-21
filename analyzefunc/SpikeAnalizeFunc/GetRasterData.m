function rasterPlot = GetRasterData(TrialParas)
% choose spikes according to existence of
if isfield(TrialParas,'AlignmentSpikeSort') & all(cellfun(@isempty,{TrialParas.Spikesort}))
    AlignSpikeBuffer = {TrialParas.AlignmentSpikeSort}';
else
    AlignSpikeBuffer = {TrialParas.AlignmentSpikeRaw}';
end
alignment = fields(AlignSpikeBuffer{1});
behavResType = {'Correct','Wrong','All'};
IsControl = strcmp({TrialParas.CueType},'control');
IsDiff = ~IsControl;
cue_types = unique({TrialParas(IsDiff).CueType});
for devDiff = unique([TrialParas.Diff]) %Diff num
    for cueN = 1:length(cue_types) % CueType
            if devDiff == 1
                Idx.All = find([TrialParas.Diff]==devDiff);
                Idx.Correct = find([TrialParas.Diff]==devDiff & {TrialParas.CorrectWrong} == "Correct");
                Idx.Wrong = find([TrialParas.Diff]==devDiff & {TrialParas.CorrectWrong} == "Wrong");
            else
                Idx.All = find([TrialParas.Diff]==devDiff & strcmp({TrialParas.CueType},cue_types{cueN}));
                Idx.Correct = find([TrialParas.Diff]==devDiff & strcmp({TrialParas.CueType},cue_types{cueN}) & {TrialParas.CorrectWrong} == "Correct");
                Idx.Wrong = find([TrialParas.Diff]==devDiff & strcmp({TrialParas.CueType},cue_types{cueN}) & {TrialParas.CorrectWrong} == "Wrong");
            end

            % get behavioral raster data
            if devDiff ==1
                rasterPlot.behavioral(devDiff).(cue_types{cueN}) = [TrialParas(Idx.Wrong).PushTime]';
            else
                rasterPlot.behavioral(devDiff).(cue_types{cueN}) = [TrialParas(Idx.Correct).PushTime]';
            end
            % get neural raster data
            for CWType = 1:length(behavResType) %correct/wrong/all
                for aligNum = 1:length(alignment) %Alignment methods
                    spikeGroup = [];
                    for trialN = 1:length(Idx.(behavResType{CWType}))
                        buffer = AlignSpikeBuffer{Idx.(behavResType{CWType})(trialN)}.(alignment{aligNum});
                        spikeGroup = [spikeGroup; buffer' ones(length(buffer),1)*trialN];
                    end
                    rasterPlot.neuronal.(cue_types{cueN})(devDiff).(alignment{aligNum}).(behavResType{CWType}) = spikeGroup;
                end
            end
    end
end


