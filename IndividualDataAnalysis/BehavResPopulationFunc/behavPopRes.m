function [pop,params] = behavPopRes(varargin)
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
            behavioralThr = BufferProt.PlotData.behavAnalysis.Threshold.behavioralThr;
            baseStiPara = BufferProt.PlotData.behavAnalysis.baseStiPara(1);
            pushResult = BufferProt.PlotData.behavresult;
            cuetype = fields(behavioralThr);
            for m = 1:length(cuetype)
                %behavioralThr
                try
                    pop.(protName).behavioralThr(cellnum,1).(cuetype{m}) = behavioralThr.(cuetype{m});
                    pop.(protName).baseStiPara(cellnum,1) = baseStiPara;
                    pop.(protName).pushResult{cellnum,1} = pushResult;
                catch
                end
            end

        end
    end
end
