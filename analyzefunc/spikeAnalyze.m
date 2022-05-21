function varargout = spikeAnalyze(TrialParas,Para,varargin)
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

savefoldT = erase(datapath,'\TrialParas.mat');
Savepath = check_mkdir_SPR(savefoldT,'ResultFigures');
%% get folder names under folder ResultFigures
oldpath=pwd;
cd(Savepath);
buffer = dir('*.*');
subfold = buffer([buffer.isdir] & ~strcmp({buffer.name},'.') & ~strcmp({buffer.name},'..'),:);
subfoldname = {subfold.name};
cd(oldpath);

%% Align Spiketime to DevOnet/DevOffSet/Pushtime
if ~isfield(TrialParas,'AlignmentSpikeRaw')
    TrialParas=SpikeAlignment(TrialParas,'Para',Para);
end

try
    load([Savepath '\PlotData.mat']);
catch
end
%% Get PSTH result
PSTHPlotPara = SetUserPara('PsthSet.binsize',50,'PsthSet.binstep',5,'wholePlotWindow',[0 1000],'enlargePlotWindow',[100 600],...
    'Edge.Std1Onset',[-3000 7000],'Edge.DevOnset',[-5000 3000],'Edge.DevOffset',[-5000 3000],'Edge.Pushtime',[-1000 2000],...
    'linecolors',{'white','#AAAAAA','black','blue','red'},...
    'behavRes',{'Push','NoPush','All'},'scaleFactor',1000);
PlotData.SpikeAnalysis.SpikePsth = SpikeTrialPsth(TrialParas,PSTHPlotPara,'singleTrial',false);

%% Get spike firing rate of standard responses
StdFrPlotPara = SetUserPara('win',[0 100; 100 500; 0 500]);
PlotData.SpikeAnalysis.resStdFr = StdFrCalculation(TrialParas,StdFrPlotPara);

%% Get raster plot data
PlotData.SpikeAnalysis.rasterPlot = GetRasterData(TrialParas);
if contains(datapath,'Active')
    %% DP curve calculation
    DPPlotPara = SetUserPara('PsthSet.binsize',100,'PsthSet.binstep',50,'Edge',[0 1000],'alignment','DevOnset',...
        'scaleFactor',1000);
    PlotData.SpikeAnalysis.DPCurve = DPCalculation(TrialParas,DPPlotPara);

    %% DP certain win calculation
    DPPlotPara = SetUserPara('win',[0 100; 250 350],'alignment','DevOnset','scaleFactor',1000);
    PlotData.SpikeAnalysis.DPWin = DPCalculation(TrialParas,DPPlotPara);

    %% Threshold of neuronal and behavioral responses
    ThrPlotPara = SetUserPara('win',[0 100; 250 350; 200 500],'alignment','DevOnset');
    [PlotData.SpikeAnalysis.frTuningCurve PlotData.SpikeAnalysis.Threshold TrialParas]= ThrCalculation(TrialParas,ThrPlotPara);

    %% Time lag of behavior and neural responses
    timeLagPlotPara = SetUserPara('win',[200 500],'AUCPercent',0.5,'alignment','DevOnset');
    PlotData.SpikeAnalysis.timeLag = timeLagCalculation(PlotData,TrialParas,timeLagPlotPara);
end
save([Savepath '\PlotData.mat'], 'PlotData');

save([savefoldT '\TrialParas.mat'],'TrialParas');
varargout{1} = TrialParas;
varargout{2} = PlotData;
% end
cd(oldpath);
end