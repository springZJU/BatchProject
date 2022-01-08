function varargout = RatSPRNoiseSpect(TrialParas,plotpara,Savepath)
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
    Spect = TrialParas.Spectrum;
    Res = Spect;
    if ToPlot==1
        count=count+1;
    subplot('position',[BasicXpos BasicYpos-(count-1)*(AxisHeight+0.003) AxisWidth AxisHeight])
    %  try
    PlotSpect(Spect,Cscale,ch,Ytick,'ColorStyle',ColorStyle,'linepos',linepos,'Coneinf',Coneinf);
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
        title([' Repetation Noise ' ProtocolName  ],'Fontsize',20);
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

saveas(h,[figsavepath   '\Repetation Noise' ProtocolName ' Ch' num2str(Chs(1)) '-' num2str(Chs(end)) '.jpg']);
close
end

SpectAll{1}=Spect;
SpectAll{2}=[];
varargout{1}=SpectAll;
varargout{2}=Res;
toc
end
