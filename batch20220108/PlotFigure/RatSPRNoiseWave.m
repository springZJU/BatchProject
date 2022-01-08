function varargout = RatSPRNoiseWave(TrialParas,plotpara,Savepath)
eval([GetStructStr(plotpara) '=ReadStructValue(plotpara);']);

AxisHeight=0.9/length(Chs);
AxisWidth=0.95;
BasicXpos=0.03;
BasicYpos=1-AxisHeight-0.03;

Ymin=min([TrialParas.SpecYlength]);
tic

if ToPlot==1
h=figure
set(gcf,'outerposition',get(0,'screensize'));
count=0;
end
for ch=Chs
    Lfp.Wave = TrialParas.Lfpdata;
    Lfp.T = [(1:1:length(Lfp.Wave))/TrialParas.FsRaw];
    Res = Lfp;
    if ToPlot==1
        count=count+1;
    subplot('position',[BasicXpos BasicYpos-(count-1)*(AxisHeight+0.003) AxisWidth AxisHeight])
    %  try
    plot(Lfp.T,Lfp.Wave(ch,:),'B-','LineWidth',1); hold on;

 if ~isempty(ylinepos)
                    for py=1:length(ylinepos)
                        plot([ylinepos(py) ylinepos(py)],[min(reshape(Lfp.Wave,numel(Lfp.Wave),1)) max(reshape(Lfp.Wave,numel(Lfp.Wave),1))],'k--','linewidth',2);hold on
                    end
                end  
    ylabel(['Ch' num2str(ch)]);
    if ch~=Chs(end)
        set(gca,'xticklabel','');
    end
    if ch==Chs(1)
        title([' LfpWave Repetation Noise ' ProtocolName  ],'Fontsize',20);
    end
    %  catch
    %  end
    end
end
if ToPlot==1
newpath=[savefold ];
if ~isempty(newpath)
figsavepath=check_mkdir_SPR(Savepath,newpath);
else
    figsavepath = Savepath;
end

saveas(h,[figsavepath   '\LfpWave Repetation Noise' ProtocolName  ' Ch' num2str(Chs(1)) '-' num2str(Chs(end)) '.jpg']);
close
end

SpectAll{1}=Lfp;
SpectAll{2}=[];
varargout{1}=SpectAll;
varargout{2}=Res;
toc
end
