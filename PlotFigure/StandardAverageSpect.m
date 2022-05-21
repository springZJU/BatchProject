function varargout=StandardAverageSpect(TrialParas,plotpara,Savepath)

eval([GetStructStr(plotpara) '=ReadStructValue(plotpara);']);

TrialParas([TrialParas.IsArtifact]>0)=[]; % use trials without artifact

AxisHeight=0.9/length(Chs);
AxisWidth=0.95;
BasicXpos=0.03;
BasicYpos=1-AxisHeight-0.03;
tic

Ymin=min([TrialParas.SpecYlength]);
[Spect.CData Spect.XData Spect.YData Spect.Coi ind Spect.Single ]=CalMeanSpecRes(TrialParas,CueType,Diff,Behav,ResStr,Ymin,PlotWin,'ChAll',ChAll);

if ToPlot==1
h=figure
set(gcf,'outerposition',get(0,'screensize'));
count=0;
end
for ch=Chs
    
    Res{1,1}=rmfield(Spect,'Single');
    if ToPlot==1
        count=count+1;
    subplot('position',[BasicXpos BasicYpos-(count-1)*(AxisHeight+0.003) AxisWidth AxisHeight])
    %  try
    PlotSpect(Spect,Cscale,ch,Ytick);
 if ~isempty(ylinepos)
                    for py=1:length(ylinepos)
                        plot([ylinepos(py) ylinepos(py)],[Spect.YData(1) Spect.YData(end)],'k--','linewidth',2);hold on
                    end
                end  
    ylabel(['Ch' num2str(ch)]);
    colorbar
    if ch~=Chs(end)
        set(gca,'xticklabel','');
    end
    if ch==Chs(1)
        title([CueType ' ' Behav ' ' ResStr   ' Standard Average    n=' num2str(length(ind)) ],'Fontsize',20);
    end
    %  catch
    %  end
    end
end
if ToPlot==1
newpath=[savefold '\' CueType '\' Behav];
figsavepath=check_mkdir_SPR(Savepath,newpath);

saveas(h,[figsavepath  '\' CueType  ' ' Behav ' '  ResStr ' ' num2str(Chs(1)) '-' num2str(Chs(end)) '.jpg']);
close
end

SpectAll{1}=Spect;
SpectAll{2}=[];
varargout{1}=SpectAll;
varargout{2}=Res;
toc
end

