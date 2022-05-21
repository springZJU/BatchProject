function [resStdFr, resStdFrRaw] = StdFrCalculation(TrialParas,StdFrPlotPara,varargin)
eval([GetStructStr(StdFrPlotPara) '=ReadStructValue(StdFrPlotPara);']);
for i = 1:2:length(varargin)
    eval([ varargin{i} '=varargin{i+1};']);
end

%% get firingrate of std sounds for each trial
for Paranum = 1:size(TrialParas,1)
    spikeBuffer = TrialParas(Paranum).AlignmentSpikeRaw.Std1Onset;
    stdTime = (TrialParas(Paranum).SoundTime - TrialParas(Paranum).Std1Time)*1000;
    stdTime(end) = []; % the last sound is deviant
    for winN = 1:size(win,1)
        for stdN = 1:length(stdTime)
            currentWin = win(winN,:)+stdTime(stdN);
            resStdFrRaw(Paranum).(['FRwin' num2str(win(winN,1)) '_' num2str(win(winN,2))])(stdN) = ...
                histcounts(spikeBuffer,currentWin)*1000/(currentWin(2)-currentWin(1));
        end
    end
end

%% calculate mean firing rate for all trials
winFields = fields(resStdFrRaw);
for winN = 1:length(winFields)
    dataBuffer = {resStdFrRaw.(winFields{winN})};
    resStdFr.(winFields{winN}) = diffSizeCell(dataBuffer);
end

