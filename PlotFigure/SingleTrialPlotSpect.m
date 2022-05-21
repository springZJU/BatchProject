function h=SingleTrialPlotSpect(TrialParas,plotpara,Savepath)

eval([GetStructStr(plotpara) '=ReadStructValue(plotpara);']);
AxisHeight=0.9/length(Chs);
AxisWidth=0.9;
BasicXpos=0.02;
BasicYpos=1-AxisHeight-0.03;
TimeUpperLater(1)=TrialParas(1).StdSelect-TrialParas(1).Std1Time;
Ymin=min([TrialParas.SpecYlength]);
tic

for Trialnum=1:length(TrialParas)
    h=figure
    set(gcf,'outerposition',get(0,'screensize'));
    count=0;
    for ch=Chs
        count=count+1;
        subplot('position',[BasicXpos BasicYpos-(count-1)*(AxisHeight+0.003) AxisWidth AxisHeight])
        Spect=TrialParas(Trialnum).Spectrum;
        DevTime=TrialParas(Trialnum).DevTime-TrialParas(Trialnum).Std1Time;
        Spect.XData=Spect.XData+TimeUpperLater(1)-DevTime;
        Std1Time=-DevTime;
        try
            PlotSpect(Spect,Cscale,ch,Ytick,'ColorStyle',ColorStyle,'linepos',linepos,'Coneinf',Coneinf)   
            plot([0 0],[Spect.YData(1) Spect.YData(end)],'r--','linewidth',2);hold on
            plot([Std1Time Std1Time],[Spect.YData(1) Spect.YData(end)],'y--','linewidth',2);hold on
            plot([1 1],[Spect.YData(1) Spect.YData(end)],'k--','linewidth',2);hold on
            plot([2 2],[Spect.YData(1) Spect.YData(end)],'k--','linewidth',2);hold on
            plot([Std1Time-2 Std1Time-2],[Spect.YData(1) Spect.YData(end)],'k--','linewidth',2);hold on
            
            ylabel(['Ch' num2str(ch)]);
            colorbar
            if ch~=Chs(end)
                set(gca,'xticklabel','');
            end
            if ch==Chs(1)
                title(['Trialnum=' num2str(Trialnum) ' ' TrialParas(Trialnum).CueType   ' Diff' num2str(max([TrialParas(Trialnum).FreqDiff ; TrialParas(Trialnum).IntDiff])-1)  ' ' TrialParas(Trialnum).Behav  '   Align2DevOnset  STD number=' num2str(TrialParas(Trialnum).StdNum)  ],'Fontsize',20);
            end
        catch
        end
    end
    
    newpath=[savefold '\' TrialParas(Trialnum).CueType ' Diff' num2str(max([TrialParas(Trialnum).FreqDiff  TrialParas(Trialnum).IntDiff])-1) ' ' TrialParas(Trialnum).Behav   ];
    newpath2=[savefold '\All ' TrialParas(Trialnum).Behav  ' Trials' ];
    figsavepath=check_mkdir_SPR(Savepath,newpath);
    figsavepath2=check_mkdir_SPR(Savepath,newpath2);
%     set(gcf,'outerposition',get(0,'screensize'));
    
    saveas(h,[figsavepath2  '\' 'Trialnum=' num2str(Trialnum) '.jpg']);
    saveas(h,[figsavepath  '\' 'Trialnum=' num2str(Trialnum) '.jpg']);
    close
    
    
end
end

