function PlotWave(Wave,ch,varargin)
ColorType='jet';

for i = 1:2:length(varargin)
    eval([ varargin{i} '=varargin{i+1};']);
end

%% plot single trial waveform
for Trialnum = 1:size(Wave.Single,1)
    Fs = 1/(Wave.XData(2)-Wave.XData(1));
    plot((0:length(Wave.Single{Trialnum,ch})-1)/Fs+Wave.XData(1),Wave.Single{Trialnum,ch},'Color','#AAAAAA','LineStyle','-'); hold on;
end
%% plot average trial waveform
    plot((0:length(Wave.YData{ch})-1)/Fs+Wave.XData(1),Wave.YData{ch},'Color','red','LineStyle','-','LineWidth',1.5); hold on;

xlim([Wave.XData(1) Wave.XData(end)]);



