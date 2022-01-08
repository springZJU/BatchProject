function TrialParas=GenerateTrialPara(params,sound_all,lfp,varargin)
if nargin>1
    for i = 1:2:length(varargin)
        val([ varargin{i} '=varargin{i+1};']);
    end
end
eval([GetStructStr(params) '=ReadStructValue(params);']);
if  contains(ProtocolName,'Basic')
    TrialParas = PEOddBaseTrialParas(params,sound_all,lfp);
elseif contains(ProtocolName,'139')
    TrialParas = PEOdd139TrialParas(params,sound_all,lfp);
elseif contains(ProtocolName,'LongTerm')
    TrialParas = PEOddLongTermTrialParas(params,sound_all,lfp);
else
    clc;
    disp('Error ProtocolName Input!')
end