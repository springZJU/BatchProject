function params = clickTrainConfig(ProtocolName)
    if strcmp(ProtocolName,'ClickTrain')
        params.TrainDur = 1600; %ms
        params.interval = 6; %sec.
        params.ISI = 7.6; % sec.
    elseif strcmp(ProtocolName,'ClickAdaptation')
        params.TrainDur = 1; % ms
        params.interval = 6; % sec.
        params.ISI = 6.001; %sec.
    elseif strcmp(ProtocolName,'ClickTrainAdaptation')
        params.TrainDur = 300; % ms
        params.interval = 0.1; % sec.
        params.ISI = 0.4; %sec.
    elseif contains(ProtocolName,'ClickTrainSSA')
        load('clickTrainInfo.mat');
        params.TrainDur = clickTrainInfo.TrainDur;
        params.clickICI = clickTrainInfo.clickICI;
        params.SSAPairs = clickTrainInfo.SSApairs;
        if contains(ProtocolName,'LongTerm')
            params.S1Duration = clickTrainInfo.S1Duration;
            if contains(ProtocolName,'ICIThr')
                params.ICIThr = clickTrainInfo.ICIThr;
            end
            if contains(ProtocolName,'Var')
                params.sd = clickTrainInfo.sd;
            end
        end
        
    elseif contains(ProtocolName,'ClickTrainToneCF')
        % None
    else
        error('Error protocol name !');
    end
    optPSTH.binsize = 20; optPSTH.binstep = 10; % for psth calculation
    params.optPSTH = optPSTH;
end

