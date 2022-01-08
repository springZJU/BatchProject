function h=CalSigBeTweenDiff_anova(SpectAll,plotpara,savepath,h)
eval([GetStructStr(plotpara) '=ReadStructValue(plotpara);']);
chs=1:4:13;
AxisHeight=0.9/length(Chs);
AxisWidth=0.9/4;
BasicXpos=0.03;
BasicYpos=1-AxisHeight-0.03;
Ind=find(strcmp(BehavAll,Behav));

tic
     count=0;
    if ToPlot==1&h==0
       
    h=figure
    set(gcf,'outerposition',get(0,'screensize'));
    end
for ch=Chs
    if ToPlot==1
        count=count+1;

    subplot('position',[BasicXpos+(find(chs==Chs(1))-1)*(AxisWidth+0.01) BasicYpos-(count-1)*(AxisHeight+0.003) AxisWidth AxisHeight])
    Ax{ch}=gca;
    end

    for dev_diff=Diff
        buffer=SpectAll{Ind}{dev_diff}.Single(:,ch);
        XTicks=SpectAll{Ind}{dev_diff}.XData;
        YTicks=SpectAll{Ind}{dev_diff}.YData;
        Coi=SpectAll{Ind}{dev_diff}.Coi;
        [~,SampleRaw(ch,dev_diff)]=AverageDiffLength(buffer,2);
    end
    try 
        clear ROIind
        ROIind{1}=find(XTicks>ROI(1,1)&XTicks<ROI(1,2)); %time range
        ROIind{2}=find(YTicks>ROI(2,1)&YTicks<ROI(2,2))'; %freq range
    p{ch}=CalSigBeTweenDiff(SampleRaw(ch,:),Diff,ROIind);
    catch
      p{ch}=CalSigBeTweenDiff(SampleRaw(ch,:),Diff);
    end
    p{ch}=floor(logg(SigBase,p{ch}));
    if ToPlot==1
            Spect.CData{ch}=p{ch};
            Spect.XData=XTicks;
            Spect.YData=YTicks;
            Spect.Coi=Coi;
            
                 try
                 PlotSpect(Spect,Cscale,ch,Ytick,'ColorStyle',ColorStyle,'linepos',linepos,'Coneinf',Coneinf);
                %Plot Region of ROI
                 plot([ROI(1,1) ROI(1,2)],[ROI(2,1) ROI(2,1)],'y--','linewidth',2); hold on; 
                plot([ROI(1,1) ROI(1,2)],[ROI(2,2) ROI(2,2)],'y--','linewidth',2); hold on;
                plot([ROI(1,1) ROI(1,1)],[ROI(2,1) ROI(2,2)],'y--','linewidth',2); hold on;
                plot([ROI(1,2) ROI(1,2)],[ROI(2,1) ROI(2,2)],'y--','linewidth',2); hold on;
                 if ~isempty(ylinepos)
                    for py=1:length(ylinepos)
                        plot([ylinepos ylinepos],[Spect.YData(1) Spect.YData(end)],'k--','linewidth',2);hold on
                    end
                end                
                if strcmp(Cscale,'auto_equalCLim')
                    
                    CLimMax(ch)= max(abs(Ax{ch}.CLim));

                end
%                 if dev_diff==Diff(1)
                    ylabel(['Ch' num2str(ch)]);
%                 end
%                 if dev_diff>Diff(1)
%                     set(gca,'yticklabel','');
%                 end
%                 if dev_diff==Diff(end)
                    colorbar
%                 end
                if ch~=Chs(end)
                    set(gca,'xticklabel','');
                else
                    if PlotType==4
                        set(gca,'xticklabel',num2strcell(1000*get(gca,'xtick')));
                        xlabel([ResStr '(ms)']);

                    end
                end
                if ch==Chs(1)
                    title([CueType ' ' Behav ' ' ResStr 'Anova' ' ' num2str(Chs(1)) '-' num2str(Chs(end))  ]);
                end
                catch
                    CLimMax(ch,dev_diff)=0.001;
            end




    end
end
    if strcmp(Cscale,'auto_equalCLim')
        for ch=Chs
            CLimChMax=max(CLimMax(ch,2:end));
            for dev_diff=Diff
                set(Ax{ch,dev_diff},'CLim',[-CLimChMax CLimChMax]);
            end
        end

    end
if ch==16
                newpath=[savefold '\Anova' ];
                figsavepath=check_mkdir_SPR(savepath,newpath);
                saveas(h,[figsavepath  '\' CueType ' ' Behav ' ' ResStr 'Anova.jpg' ]);
                close
            end

end
