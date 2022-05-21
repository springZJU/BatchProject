function  TrialParas = RatSPRSpikeAnalyze(TrialParas,varargin)
if nargin>=2
    for i = 1:2:length(varargin)
        eval([ varargin{i} '=varargin{i+1};']);
    end
    try
        eval([GetStructStr(Para) '=ReadStructValue(Para);']);
    catch
    end
end

savepath = check_mkdir_SPR(savepath,'ResultFigures');
%% Load existed PlotData
try  
load([savepath '\PlotData.mat']); 
catch
end

spiketime = TrialParas.Spikeraw*1000;  %unit:ms
for soundnum = 1:length(TrialParas.SoundTime)
    selectWin = NeuWin + TrialParas.SoundTime(soundnum)*1000;
raster{soundnum,1} = spiketime(spiketime>selectWin(1)&spiketime<selectWin(2))-TrialParas.SoundTime(soundnum)*1000;
firingrate{soundnum,1} = length(raster{soundnum,1})*1000/(NeuWin(2)-NeuWin(1));
Neuwin{soundnum,1} = NeuWin;
end
SpikeData = struct('RasterPlot',raster,'FiringRate',firingrate,'NeuWin',Neuwin);
TrialParas.SpikeRes = SpikeData;
%% Plot spectro-temporal result

for Ch1=1:PlotCh:ChAll(end)
    plotpara=SetPlotPara(TrialParas,'PlotType',1002,'Chs',[Ch1:1:(Ch1+PlotCh-1)],'ChAll',ChAll,...
               'savefold','SpikeRasterFiringRate','ToPlot',1,'ProtocolName',ProtocolName);
    PlotTypes(TrialParas,plotpara,savepath);
    SpecData.plotpara.NoiseRepetation = plotpara;
end

PlotData.SpikeData = SpikeData;


save([savepath '\PlotData.mat'], 'PlotData');
end