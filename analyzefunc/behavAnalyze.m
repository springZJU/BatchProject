function varargout = behavAnalyze(TrialParas,Para,varargin)
%% read input arguments
if nargin<2
    disp('Please input datapath information')
    return
else

    for i = 1:2:length(varargin)
        eval([ varargin{i} '=varargin{i+1};']);
    end
    try
        eval([GetStructStr(Para) '=ReadStructValue(Para);']);
    catch
    end
end
% load behavresult in PlotData
        if ~isfield(PlotData,'behavresult')
        savefoldT = erase(datapath,'\TrialParas.mat');
        load([savefoldT '\data.mat'])
        PlotData.behavresult = data.behavresult;
        end
        
    ThrPlotPara = SetUserPara('win',[0 100; 250 350; 200 500],'alignment','DevOnset');
    [~,PlotData.behavAnalysis.Threshold,~]= ThrCalculation(TrialParas,ThrPlotPara,'neuronalData',false);
    PlotData.behavAnalysis.baseStiPara = [TrialParas(1).FreqBase TrialParas(1).IntBase TrialParas.DurBase];
varargout{1} = TrialParas;
varargout{2} = PlotData;
