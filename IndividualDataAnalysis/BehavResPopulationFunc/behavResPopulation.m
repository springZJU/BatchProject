function [popPlotData,params] = behavResPopulation(varargin)
for i = 1:2:length(varargin)
    eval([ varargin{i} '=varargin{i+1};']);
end

[popPlotData.popRes params] = behavPopRes('params',params);
 popPlotData.bhvPlot = behavResPlot(popPlotData.popRes,'params',params);

