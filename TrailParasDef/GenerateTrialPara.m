function TrialParas=GenerateTrialPara(params,sound_all,lfp,varargin)
if nargin>1
    for i = 1:2:length(varargin)
        val([ varargin{i} '=varargin{i+1};']);
    end
end
eval([GetStructStr(params) '=ReadStructValue(params);']);
if  contains(ProtocolName,'PEOddBasic')
    TrialParas = PEOddBaseTrialParas(params,sound_all,lfp);
elseif contains(ProtocolName,'PEOdd139')
    TrialParas = PEOdd139TrialParas(params,sound_all,lfp);
elseif contains(ProtocolName,'PEOddLongTerm')
    TrialParas = PEOddLongTermTrialParas(params,sound_all,lfp);
elseif contains(ProtocolName,'DurOdd')
    TrialParas = DurOddTrialParas(params,sound_all,lfp);
else
    clc;
    disp('Error ProtocolName Input!')
end