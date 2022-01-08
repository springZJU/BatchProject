function TrialParas=LabelStrTypes(TrialParas,params,varargin)

if nargin>1
    for i = 1:2:length(varargin)
        val([ varargin{i} '=varargin{i+1};']);
    end
    eval([GetStructStr(params) '=ReadStructValue(params);']);
end

if  contains(ProtocolName,'PEOddBasic')
    TrialParas = PEOddBaseLabelStr(TrialParas);
elseif contains(ProtocolName,'PEOdd139')
    TrialParas = PEOdd139LabelStr(TrialParas);
elseif contains(ProtocolName,'PEOddLongTerm')
    TrialParas = PEOddLongTermLabelStr(TrialParas);
elseif contains(ProtocolName,'DurOdd')
    TrialParas = DurOddLabelStr(TrialParas);
else
    clc;
    disp('Error ProtocolName Input!')
end


end