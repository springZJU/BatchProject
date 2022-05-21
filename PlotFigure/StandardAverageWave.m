function varargout=StandardAverageWave(TrialParas,plotpara,Savepath)

eval([GetStructStr(plotpara) '=ReadStructValue(plotpara);']);
TrialParas([TrialParas.IsArtifact]>0)=[]; % use trials without artifact

AxisHeight=0.9/length(Chs);
AxisWidth=0.95;
BasicXpos=0.03;
BasicYpos=1-AxisHeight-0.03;
tic

[Wave.YData Wave.XData ind Wave.Single]=CalMeanWaveRes(TrialParas,CueType,Diff,Behav,ResStr,PlotWin,'ChAll',ChAll);

if ToPlot==1
    h=figure
    set(gcf,'outerposition',get(0,'screensize'));
    count=0;
end
for ch=Chs

    Res{1,1}=rmfield(Wave,'Single');
    if ToPlot==1
        count=count+1;
        subplot('position',[BasicXpos BasicYpos-(count-1)*(AxisHeight+0.003) AxisWidth AxisHeight])
        %  try
        PlotWave(Wave,ch);
        Ax{ch} = gca;
        if ~isempty(ylinepos)
            for py=1:length(ylinepos)
                plot([ylinepos(py) ylinepos(py)],Ax{ch}.YLim,'k--','linewidth',2);hold on
            end
        end
        ylabel(['Ch' num2str(ch)]);
        if ch~=Chs(end)
            set(gca,'xticklabel','');
        end
        if ch==Chs(1)
            title([CueType ' ' Behav ' ' ResStr   ' Standard Wave Average    n=' num2str(length(ind)) ],'Fontsize',20);
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

WaveAll{1}=Wave;
WaveAll{2}=[];
varargout{1}=WaveAll;
varargout{2}=Res;
toc
end

