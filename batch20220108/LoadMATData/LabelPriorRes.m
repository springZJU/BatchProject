function TrialParas = LabelPriorRes(TrialParas,varargin)
for i = 1:2:length(varargin)
    eval([ varargin{i} '=varargin{i+1};']);
end

for Paranum = 2:size(TrialParas,1)
    TrialParas(Paranum).PriorRes = TrialParas(Paranum-1).CorrectWrong;
end
