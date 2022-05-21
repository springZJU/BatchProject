function [frTuningCurve,Threshold,TrialParas] = ThrCalculation(TrialParas,ThrPlotPara,varargin)
eval([GetStructStr(ThrPlotPara) '=ReadStructValue(ThrPlotPara);']);
singleTrial = true;
for i = 1:2:length(varargin)
    eval([ varargin{i} '=varargin{i+1};']);
end

%% choose spikes according to existence of spike type
if ~exist('neuronalData','var')
    neuronalData = true;
elseif ~neuronalData
    frTuningCurve = [];
end
behavResType = {'Correct','Wrong','All'};
IsControl = strcmp({TrialParas.CueType},'control');
IsDiff = ~IsControl;
cue_types = unique({TrialParas(IsDiff).CueType});

%% Calculate firing rate in different time window
if neuronalData % if false, skip neuronal analysis, only for behavioral analysis
    
    if ~exist('alignment','var')
        alignment = fields(AlignSpikeBuffer{1});
    end
    if isfield(TrialParas,'AlignmentSpikeSort') & all(cellfun(@isempty,{TrialParas.Spikesort}))
        AlignSpikeBuffer = {TrialParas.AlignmentSpikeSort}';
    else
        AlignSpikeBuffer = {TrialParas.AlignmentSpikeRaw}';
    end

    if singleTrial
        for aligNum = 1:length(alignment) %Alignment methods
            for Paranum = 1:size(TrialParas,1) %Trialnum
                spikeBuffer = AlignSpikeBuffer{Paranum}.(alignment);
                FRBuffer(Paranum,1) = FRcal(spikeBuffer,win);
            end
        end
    end
    if ~all(contains(fields(TrialParas),fields(FRBuffer)))
        TrialParas = catstruct(TrialParas,FRBuffer);
    end
    winFields = fields(FRBuffer);
end
%% calculate AUC and behavres for different diff in different windows
for cueN = 1:length(cue_types) % CueType
    for devDiff = unique([TrialParas.Diff]) %Diff num
        if devDiff == 1
            controlIdx = find([TrialParas.Diff]==devDiff);
            Idx.All = find([TrialParas.Diff]==devDiff);
            Idx.Correct = find([TrialParas.Diff]==devDiff & {TrialParas.CorrectWrong} == "Correct");
            Idx.Wrong = find([TrialParas.Diff]==devDiff & {TrialParas.CorrectWrong} == "Wrong");
        else
            Idx.All = find([TrialParas.Diff]==devDiff & strcmp({TrialParas.CueType},cue_types{cueN}));
            Idx.Correct = find([TrialParas.Diff]==devDiff & strcmp({TrialParas.CueType},cue_types{cueN}) & {TrialParas.CorrectWrong} == "Correct");
            Idx.Wrong = find([TrialParas.Diff]==devDiff & strcmp({TrialParas.CueType},cue_types{cueN}) & {TrialParas.CorrectWrong} == "Wrong");
        end
        if neuronalData
            for winN = 1:length(winFields) % wins to calculate firingrate
                for CWType = 1:length(behavResType)
                    frDataBuffer = [FRBuffer(Idx.(behavResType{CWType})).(winFields{winN})]';
                    frTuningCurve.(cue_types{cueN}).(behavResType{CWType})(devDiff).((winFields{winN})) = [mean(frDataBuffer); std(frDataBuffer)/sqrt(length(frDataBuffer))];
                    frTuningCurve.(cue_types{cueN}).(behavResType{CWType})(devDiff).([(winFields{winN}) '_Raw']) = frDataBuffer;
                end
                
                    controlBuffer = [FRBuffer(controlIdx).(winFields{winN})]';
                    controlBuffer = [controlBuffer zeros(length(controlBuffer),1)];
                
                diffBuffer = [FRBuffer(Idx.All).(winFields{winN})]' ;
                diffBuffer = [diffBuffer ones(length(diffBuffer),1)];
                diffDataBuffer = [controlBuffer; diffBuffer];
%                 diffDataBuffer(:,1) = zscore(diffDataBuffer(:,1));
                resAUC.(cue_types{cueN})(devDiff).(winFields{winN}) = AUCcal(diffDataBuffer,devDiff);
            end
        end
        behavBuffer = [TrialParas(Idx.All).PushTime]';
        behavBuffer(behavBuffer>0) = 1;
        resBehav(devDiff).(cue_types{cueN}) = sum(behavBuffer(:)==1)/length(behavBuffer);
    end
end

%% calculate threshold
for cueN = 1:length(cue_types) % CueType
    if strcmp(cue_types{cueN},'int')
        opt.lanmuda = [0 5 10 15 20]';
    else
        opt.lanmuda = unique([TrialParas.FreqDev]');
    end
    opt.yThr = 0.8;
    opt.xThr = 2.9;
    opt.fitMethod = 'gaussint';
    opt.thrMethod = 'Y';

    % calculate neuronal threshold
    if neuronalData
        for winN = 1:length(winFields)
            opt.dataType = 'neural';
            opt.fitMethod = 'gaussint';
            AUCBuffer = [resAUC.(cue_types{cueN}).(winFields{winN})]';
            [~,Threshold.neuronalThr.(cue_types{cueN}).(winFields{winN})] = Thrcal(AUCBuffer,opt);
        end
    end

    % calculate behavioral threshold
    opt.dataType = 'behavioral';
    opt.fitMethod = 'gaussint';
    fitBehavBuffer = [resBehav.(cue_types{cueN})]';
    Threshold.behavioralThr.(cue_types{cueN}) = Thrcal(fitBehavBuffer,opt);
end



