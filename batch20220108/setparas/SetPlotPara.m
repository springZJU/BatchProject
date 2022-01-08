function plotpara=SetPlotPara(varargin)
plotpara.CueType='int';% the type of the stimulus
plotpara.Behav='Push'; % the behavior result to select
plotpara.Cscale='auto'; % the scale of the colormap, 'auto':auto scale; 'auto_equalCLim': abs(-CLim)==abs(CLim); [m,n]: CLim(m,n)
plotpara.ResStr='Align2Std1Onset'; % the alignment style 
plotpara.PlotWin=[-3 3];  % with which you select the data to analyze, be careful, the PlotWin is related to ResStr
plotpara.Chs=1;  % the channel  plot in the result figure
plotpara.Diff=1:5; % the diff plot in  the result figure
plotpara.Ytick=[1 2 10 30 100];  % the Ytick of the spectemporal figure
plotpara.savefold='result'; %the name of the figure save fold
plotpara.MMN=0; % if MMN, then result=PlotWin data - (PlotWin-isi) data
plotpara.ISI=0.5; % the isi of the trial
plotpara.linepos=[2 5 10]; % to line line at the specific frequency
plotpara.ylinepos=[];
plotpara.ColorStyle='jet'; %the type of image colormap
plotpara.Coneinf=1; %Cone of influence, if 1, plot the cone line with 'w--';
plotpara.ToPlot=1; %plot figure or not
plotpara.PlotType=1; %Plot type
plotpara.ChAll=1:16; %All channels recorded
plotpara.SetCLim=[];
plotpara.BehavAll={'Push','NoPush','All'};
for i = 1:2:length(varargin)
    eval(['plotpara.' varargin{i} '=varargin{i+1};']);
end

end
