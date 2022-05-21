function varargout=CalculateMMNSpect(TrialParas,plotpara,Savepath)
eval([GetStructStr(plotpara) '=ReadStructValue(plotpara);']);
TrialParas([TrialParas.IsArtifact]>0)=[]; % use trials without artifact


AxisHeight=0.9/length(Chs);
AxisWidth=0.9/length(Diff);
BasicXpos=0.03;
BasicYpos=1-AxisHeight-0.03;
Ymin=min([TrialParas.SpecYlength]);
tic
if ToPlot==1
    h=figure
    set(gcf,'outerposition',get(0,'screensize'));
    
end
for dev_diff=Diff
    [Spect.CData Spect.XData Spect.YData Spect.Coi ind Spect.Single ]=CalMeanSpecRes(TrialParas,CueType,dev_diff,Behav,ResStr,Ymin,PlotWin,'MMN',MMN,'ChAll',ChAll);
    count=0;
    for ch=Chs
        
        count=count+1;
        %         Res{1,dev_diff}=rmfield(Spect,'Single'); %All Ch is calculated accodring to ChAll in func CalMeanSpecRes, so here do not need para ch.
        Res{1,dev_diff}=Spect; %All Ch is calculated accodring to ChAll in func CalMeanSpecRes, so here do not need para ch.
        
        if ToPlot==1
            subplot('position',[BasicXpos+(find(Diff==dev_diff)-1)*(AxisWidth+0.01) BasicYpos-(count-1)*(AxisHeight+0.003) AxisWidth AxisHeight])
            Ax{ch,dev_diff}=gca;
            try
                PlotSpect(Spect,Cscale,ch,Ytick,'ColorStyle',ColorStyle,'linepos',linepos,'Coneinf',Coneinf);
                
                if ~isempty(ylinepos)
                    for py=1:length(ylinepos)
                        plot([ylinepos ylinepos],[Spect.YData(1) Spect.YData(end)],'k--','linewidth',2);hold on
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
                    set(gca,'xticklabel',num2strcell(1000*get(gca,'xtick')));
                    xlabel([ResStr '(ms)'])
                end
                if ch==Chs(1)
                    title([CueType ' ' Behav ' ' ResStr ' Diff' num2str(dev_diff-1) '   n=' num2str(length(ind)) ]);
                end
            catch
                CLimMax(ch,dev_diff)= 0;
            end
        end
    end
    SpectAll{dev_diff}=Spect;
    IndN(dev_diff)=length(ind);
end



if ToPlot==1
    if strcmp(Cscale,'auto_equalCLim')
        for ch=Chs
            CLimChMax=max(CLimMax(ch,2:end));
            for dev_diff=Diff
                set(Ax{ch,dev_diff},'CLim',[-CLimChMax CLimChMax]);
            end
        end
        
    end
    
    %     newpath=[savefold  ];
    newpath=[savefold '\' CueType '\' Behav ];
    figsavepath=check_mkdir_SPR(Savepath,newpath);
    %     set(gcf,'outerposition',get(0,'screensize'));
    saveas(h,[figsavepath  '\' CueType  ' ' Behav ' '  ResStr ' ' num2str(Chs(1)) '-' num2str(Chs(end)) '.jpg']);
    close
end
varargout{1}=SpectAll;
varargout{2}=IndN;
varargout{3}=Res;
toc

