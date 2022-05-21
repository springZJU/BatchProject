function PlotSpect(Spect,Cscale,ch,Ytick,varargin)
ColorType='jet';

for i = 1:2:length(varargin)
    eval([ varargin{i} '=varargin{i+1};']);
end
try 
Xind = find(Spect.XData>=BackgroundRegion(1)&Spect.XData<=BackgroundRegion(2));
Spect.XData = Spect.XData(Xind);
Spect.CData{ch} = Spect.CData{ch}(:,Xind);
Spect.Coi= Spect.Coi(Xind);
catch
end

try
    if length(Cscale)==2
        hs = imagesc('XData',Spect.XData,...
            'YData',Spect.YData,...
            'CData',Spect.Single{Trialnum,ch},Cscale); hold on;
    else
        hs = imagesc('XData',Spect.XData,...
            'YData',Spect.YData,...
            'CData',Spect.Single{Trialnum,ch}); hold on;
    end
catch
    if length(Cscale)==2
        hs = imagesc('XData',Spect.XData,...
            'YData',Spect.YData,...
            'CData',Spect.CData{ch},Cscale);hold on;
    else
        hs = imagesc('XData',Spect.XData,...
            'YData',Spect.YData,...
            'CData',Spect.CData{ch});hold on;
    end
end
try
    if Coneinf==1
        plot(Spect.XData,Spect.Coi,'w--','LineWidth',1);
    end
catch
end
try
    for pos=1:length(linepos)
        plot(Spect.XData,ones(length(Spect.XData),1)*linepos(pos),'r--','LineWidth',1);
    end
catch
end
colormap(ColorType);
ylim([Spect.YData(end) Spect.YData(1)]);
xlim([Spect.XData(1) Spect.XData(end)]);

colorbar

set(gca,'YScale','log');
set(gca,'ytick',Ytick);
set(gca,'yticklabel',get(gca,'ytick'));
% title(ResStr);
