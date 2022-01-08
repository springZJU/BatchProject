function AmbiguousPushResPlot(varargin)
for i = 1:2:length(varargin)
    eval([ varargin{i} '=varargin{i+1};']);
end
eval([GetStructStr(params) '=ReadStructValue(params);']);

h = figure;
set(gcf,'outerposition',get(0,'screensize'));
params = AddParameterInPara('Para',params,'h',h) ;
% Plot Figures of Prior Effect
    PriorEffectFigures('params',params);
% Plot Figures of Stdnum Effect
    StdnumEffectFigures('params',params);
end