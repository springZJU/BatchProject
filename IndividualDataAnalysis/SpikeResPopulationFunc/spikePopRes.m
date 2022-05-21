function [pop,params] = spikePopRes(varargin)
for i = 1:2:length(varargin)
    eval([ varargin{i} '=varargin{i+1};']);
end
eval([GetStructStr(params) '=ReadStructValue(params);']);

ProtocolName = BufferField(ProtocolLogic & any(StructLogic,1));
ActiveProtocolTypes = ProtocolName(contains(ProtocolName,'Active'));
for protypes = 1:length(ActiveProtocolTypes)
    protName = ActiveProtocolTypes{protypes};
    proIdx = contains(BufferField,protName);
    validLogic = RegionLogic & any(proIdx & StructLogic,2); %certain region & certain protocol containing data
    BufferData2 = BufferData(validLogic);
    for cellnum = 1:size(BufferData2,1)
        BufferProt = BufferData2(cellnum).(ActiveProtocolTypes{protypes}); % get current protocol data
        DPCurve = BufferProt.PlotData.SpikeAnalysis.DPCurve;
        DPWin = BufferProt.PlotData.SpikeAnalysis.DPWin;
        frTuningCurve = BufferProt.PlotData.SpikeAnalysis.frTuningCurve;
        timeLag = BufferProt.PlotData.SpikeAnalysis.timeLag;
        behavioralThr = BufferProt.PlotData.SpikeAnalysis.Threshold.behavioralThr;
        neuronalThr = BufferProt.PlotData.SpikeAnalysis.Threshold.neuronalThr;
        resStdFr = BufferProt.PlotData.SpikeAnalysis.resStdFr;
        SpikePsth = BufferProt.PlotData.SpikeAnalysis.SpikePsth;
        cuetype = fields(DPCurve);

        for m = 1:length(cuetype)
            %DPCurve
            pop.(protName).DPCurve.(cuetype{m}){cellnum,1} = [DPCurve.(cuetype{m}).value];
            %DPWin
            for winN = 1:size(DPWin.(cuetype{m}),2)
                try
                    pop.(protName).DPWin.(cuetype{m}){winN}(cellnum) = DPWin.(cuetype{m})(winN);
                catch
                    continue
                end
            end
            %SpikePsth
            alignType = fields(SpikePsth.(cuetype{m}));
            for alignNum = 1:length(alignType)
                pop.(protName).SpikePsth.(cuetype{m}).(alignType{alignNum}){1} = SpikePsth.(cuetype{m}).(alignType{alignNum})(1,:);
                for devDiff = 2:size(SpikePsth.(cuetype{m}).(alignType{alignNum}),1)
                    if cellnum == 1
                        pop.(protName).SpikePsth.(cuetype{m}).(alignType{alignNum}){devDiff} = SpikePsth.(cuetype{m}).(alignType{alignNum})(devDiff,:);
                    else
                        pop.(protName).SpikePsth.(cuetype{m}).(alignType{alignNum}){devDiff} = [pop.(protName).SpikePsth.(cuetype{m}).(alignType{alignNum}){devDiff};SpikePsth.(cuetype{m}).(alignType{alignNum})(devDiff,:)];
                    end
                end
            end

            %frTuning
            CorrectWrong = fields(frTuningCurve.(cuetype{m}));
            for CWType = 1:length(CorrectWrong)
                win = fields(frTuningCurve.(cuetype{m}).(CorrectWrong{CWType}));
                for winN = 1:length(win)
                    for devDiff = 1:size(frTuningCurve.(cuetype{m}).(CorrectWrong{CWType}),2)
                        if contains((win{winN}),'Raw')
                            pop.(protName).frTuningCurve.(cuetype{m}).(CorrectWrong{CWType})(devDiff).(win{winN}){cellnum,1} = frTuningCurve.(cuetype{m}).(CorrectWrong{CWType})(devDiff).(win{winN});
                        else
                            pop.(protName).frTuningCurve.(cuetype{m}).(CorrectWrong{CWType})(devDiff).(win{winN})(:,cellnum) = frTuningCurve.(cuetype{m}).(CorrectWrong{CWType})(devDiff).(win{winN});
                        end

                    end
                end
            end
            %timeLag
            lagTypes = fields(timeLag.(cuetype{m}));
            for lagtypeN = 1:length(lagTypes)
                for devDiff = 1:size(timeLag.(cuetype{m}),2)
                    try
                        pop.(protName).timeLag.(cuetype{m})(devDiff).(lagTypes{lagtypeN})(cellnum,1) = timeLag.(cuetype{m})(devDiff).(lagTypes{lagtypeN});
                    catch
                    end
                end
            end
            %behavioralThr
            try
                pop.(protName).behavioralThr.(cuetype{m})(cellnum,1) = behavioralThr.(cuetype{m});
            catch
            end
            %neuronalThr
            neuThrTypes = fields(neuronalThr.(cuetype{m}));
            for neuThrN = 1:length(neuThrTypes)
                try
                    pop.(protName).neuronalThr.(cuetype{m}).(neuThrTypes{neuThrN})(cellnum,1) = neuronalThr.(cuetype{m}).(neuThrTypes{neuThrN});
                catch

                end
            end
        end

    end
end
end
