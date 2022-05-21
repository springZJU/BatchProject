function  TrialParas = RatSPRLfpAnalyze(TrialParas,varargin)
if nargin>=2
    for i = 1:2:length(varargin)
        eval([ varargin{i} '=varargin{i+1};']);
    end
    try
        eval([GetStructStr(Para) '=ReadStructValue(Para);']);
    catch
    end
end


%% config parameters
FsRaw = TrialParas.FsRaw;
savepath = check_mkdir_SPR(savepath,'ResultFigures');
TrialParas=SpectroAnalyze(TrialParas,FsRaw,Wavelet,FsNew,'Para',Para,'TRIAL',1);

%% Load existed PlotData
try  
load([savepath '\PlotData.mat']); 
catch
end
%% Plot spectro-temporal result

for Ch1=1:PlotCh:ChAll(end)
    plotpara=SetPlotPara(TrialParas,'PlotType',1000,'Chs',[Ch1:1:(Ch1+PlotCh-1)],'ChAll',ChAll,...
        'linepos',[1/0.3 1/0.6 1 1/1.5 1/2 10 30 100],'Ytick',roundn([1/2 1/1.5 1/1 1/0.6 1/0.3 10 30 100],-1),'Cscale','auto',...
        'PlotWin',[TrialParas.SoundTime(1) TrialParas.SoundTime(end)+(TrialParas.SoundTime(end)-TrialParas.SoundTime(end-1))],...
        'ylinepos',TrialParas.SoundTime,'savefold','SpectroTemporal','ToPlot',1,'ProtocolName',ProtocolName);

    [SpectAll SpecData.NoiseRepetation]=PlotTypes(TrialParas,plotpara,savepath);
    SpecData.plotpara.NoiseRepetation = plotpara;
end
PlotData.SpectData = SpecData;


%% Plot raw waveform 
for Ch1=1:PlotCh:ChAll(end)
    plotpara=SetPlotPara(TrialParas,'PlotType',1001,'Chs',[Ch1:1:(Ch1+PlotCh-1)],'ChAll',ChAll,...
        'PlotWin',[TrialParas.SoundTime(1) TrialParas.SoundTime(end)+(TrialParas.SoundTime(end)-TrialParas.SoundTime(end-1))],...
        'ylinepos',TrialParas.SoundTime,'savefold','Waveform','ToPlot',1,'ProtocolName',ProtocolName);

    [WaveAll WaveData.NoiseRepetation]=PlotTypes(TrialParas,plotpara,savepath);
    WaveData.plotpara.NoiseRepetation = plotpara;
end
PlotData.WaveData = WaveData;


save([savepath '\PlotData.mat'], 'PlotData');

end