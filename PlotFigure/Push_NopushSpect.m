function varargout=Push_NopushSpect(SpectAll,plotpara,Savepath)
eval([GetStructStr(plotpara) '=ReadStructValue(plotpara);']);
SpectPush=SpectAll{1};
SpectNoPush=SpectAll{2};

AxisHeight=0.9/length(Chs);
AxisWidth=0.9/length(Diff);
BasicXpos=0.02;
BasicYpos=1-AxisHeight-0.03;
tic
if ToPlot==1
    h=figure
    set(gcf,'outerposition',get(0,'screensize'));
end
for dev_diff=Diff
    count=0;
    
        for ch=Chs
            
            count=count+1;
            if ToPlot==1
                subplot('position',[BasicXpos+(find(Diff==dev_diff)-1)*(AxisWidth+0.01) BasicYpos-(count-1)*(AxisHeight+0.003) AxisWidth AxisHeight])
                 Ax{ch,dev_diff}=gca;
            end
try
            Spect.CData{ch}=SpectPush{dev_diff}.CData{ch}-SpectNoPush{dev_diff}.CData{ch};
            Spect.XData=SpectPush{dev_diff}.XData;
            Spect.YData=SpectPush{dev_diff}.YData;
            Spect.Coi=SpectPush{dev_diff}.Coi;
            Res{dev_diff}=Spect;

            if ToPlot==1
                
                try
                 PlotSpect(Spect,Cscale,ch,Ytick,'ColorStyle',ColorStyle,'linepos',linepos,'Coneinf',Coneinf);
                if ~isempty(ylinepos)
                    for py=1:length(ylinepos)
                        plot([ylinepos(py) ylinepos(py)],[Spect.YData(1) Spect.YData(end)],'k--','linewidth',2);hold on
                    end
                end                
                if strcmp(Cscale,'auto_equalCLim')
                    
                    CLimMax(ch,dev_diff)= max(abs(Ax{ch,dev_diff}.CLim));

                end
                if dev_diff==Diff(1)
                    ylabel(['Ch' num2str(ch)]);
                end
                if dev_diff>Diff(1)
                    set(gca,'yticklabel','');
                end
                if dev_diff==Diff(end)
                    colorbar
                end
                if ch~=Chs(end)
                    set(gca,'xticklabel','');
                else
                    if PlotType==4
                        set(gca,'xticklabel',num2strcell(1000*get(gca,'xtick')));
                        xlabel([ResStr '(ms)']);

                    end
                end
                if ch==Chs(1)
                    title([CueType ' ' Behav ' ' ResStr 'Push-NoPush' ' Diff' num2str(dev_diff-1)]);
                end
                catch
                    CLimMax(ch,dev_diff)=0.001;
            end
           
                
        end
    
catch
    Spect.CData{ch}=[];
            Spect.XData=[];
            Spect.YData=[];
            Spect.Coi=[];
CLimMax(ch,dev_diff)=0.001;
Res{ch,dev_diff}=Spect;
end
        
        end

end
if ToPlot==1
    if strcmp(Cscale,'auto_equalCLim')
        for ch=Chs
            CLimChMax=max(CLimMax(ch,2:end));
            if isempty(CLimChMax)
                CLimChMax=max(CLimMax(ch,:));
            end
            for dev_diff=Diff
                set(Ax{ch,dev_diff},'CLim',[-CLimChMax CLimChMax]);
            end
        end

    end
    newpath=[savefold  '\' CueType  ];
    figsavepath=check_mkdir_SPR(Savepath,newpath);

    saveas(h,[figsavepath '\'  ResStr ' ' num2str(Chs(1)) '-' num2str(Chs(end)) '.jpg']);
    close
end
varargout = Res;
toc
end