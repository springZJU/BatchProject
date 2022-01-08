function Para =AddParameterInPara(varargin)
for i = 1:2:length(varargin)
    eval([ varargin{i} '=varargin{i+1};']);
end

for i = 1:2:length(varargin)
    if ~strcmp(varargin{i},'Para')
    eval(['Para.' varargin{i} '=varargin{i+1};']);
    end
end