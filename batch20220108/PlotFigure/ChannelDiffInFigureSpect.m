function varargout=ChannelDiffInFigureSpect(TrialParas,plotpara,Savepath)

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
    [Spect.CData Spect.XData Spect.YData Spect.Coi ind Spect.Single ]=CalMeanSpecRes(TrialParas,CueType,dev_diff,Behav,ResStr,Ymin,PlotWin,'ChAll',ChAll);
    count=0;
    for ch=Chs
        count=count+1;
        Res{ch,dev_diff}=rmfield(Spect,'Single');
        if ToPlot==1
            subplot('position',[BasicXpos+(dev_diff-1)*(AxisWidth+0.01) BasicYpos-(count-1)*(AxisHeight+0.003) AxisWidth AxisHeight])
            Ax{ch,dev_diff}=gca;
            try
                PlotSpect(Spect,Cscale,ch,Ytick,'ColorStyle',ColorStyle,'linepos',linepos,'Coneinf',Coneinf)
                if ~isempty(ylinepos)
                    for py=1:length(ylinepos)
                        plot([ylinepos ylinepos],[Spect.YData(1) Spect.YData(end)],'k--','linewidth',2);hold on
                    end
                end
                if strcmp(Cscale,'auto_equalCLim')|strcmp(Cscale,'auto_semiequalCLim')

                    CLimMax(ch,dev_diff)= max(abs(Ax{ch,dev_diff}.CLim));
                end
                if dev_diff==Diff(1)
                    ylabel(['Ch' num2str(ch)]);
                end
                if dev_diff>Diff(1)
                    % set(gca,'yticklabel','');
                end
                if dev_diff==Diff(end)
                    colorbar
                end
                if ch~=Chs(end)
                    set(gca,'xticklabel','');
                else

                    set(gca,'xticklabel',num2strcell(1000*get(gca,'xtick')));
                    if PlotWin(2)-PlotWin(1)<2
                        xlabel([ResStr '(ms)']);
                    end
                end
                if ch==Chs(1)
                    title([CueType ' ' Behav ' ' ResStr ' Diff' num2str(dev_diff-1) '   n=' num2str(length(ind)) ]);
                end
            catch
                CLimMax(ch,dev_diff)=0;
            end
        end
    end
    SpectAll{dev_diff}=Spect;
    IndN(dev_diff)=length(ind);
end
if ToPlot==1
    for ch=Chs
        if ~isempty(SetCLim)

            CLimChMax(ch)=SetCLim(ch);
        else
            CLimChMax(ch)=max(CLimMax(ch,2:end));
        end

        for dev_diff=Diff
            if strcmp(Cscale,'auto_equalCLim')
                set(Ax{ch,dev_diff},'CLim',[-CLimChMax(ch) CLimChMax(ch)]);
            elseif strcmp(Cscale,'auto_semiequalCLim')
                set(Ax{ch,dev_diff},'CLim',[0 CLimChMax(ch)]);
            end

        end
    end

    newpath=[savefold '\' CueType '\' Behav ];
    figsavepath=check_mkdir_SPR(Savepath,newpath);
    % set(gcf,'outerposition',get(0,'screensize'));
    saveas(h,[figsavepath  '\' CueType  ' ' Behav ' '  ResStr ' ' num2str(Chs(1)) '-' num2str(Chs(end)) '.jpg']);
    close
end
varargout{1}=SpectAll;
varargout{2}=IndN;
% varargout{3}=CLimChMax;
varargout{3}=Res;
toc

