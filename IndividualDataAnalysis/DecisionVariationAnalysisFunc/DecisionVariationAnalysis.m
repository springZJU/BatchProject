function IndividualData = DecisionVariationAnalysis(varargin)
for i = 1:2:length(varargin)
    eval([ varargin{i} '=varargin{i+1};']);
end
eval([GetStructStr(params) '=ReadStructValue(params);']);

%% choose ambiguous trials(PushRate∈[ThL ThH]), and classify based on prior trial (get reword or not) and current trial (push or not)
% params = AmbiguousClassify('params',params,'method','prior');
%% classify ambiguous trials based on standard number
% params = AmbiguousClassify('params',params,'method','stdnum');

IndividualData = params.BufferData;

%% Scatter plot of pushrate based on prior reworded or not  
AmbiguousPushResPlot('params',params);





