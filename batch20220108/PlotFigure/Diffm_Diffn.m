function Diffm_Diffn(SpectAll,Diffm,Diffn,plotpara,IndN,Savepath)
eval([GetStructStr(plotpara) '=ReadStructValue(plotpara);']);
figure
Chs=length(SpectAll{1}.CData);
% Diff=length(Diffm);
AxisHeight=0.9/Chs;
AxisWidth=0.9/length(Diffm);
BasicXpos=0.02;
BasicYpos=1-AxisHeight-0.03;
for diffm=Diffm
    count=0;
    for ch=1:Chs
        count=count+1;
        subplot('position',[BasicXpos+(find(Diffm==diffm)-1)*(AxisWidth+0.01) BasicYpos-(count-1)*(AxisHeight+0.003) AxisWidth AxisHeight])
        Res.CData{ch}=SpectAll{diffm}.CData{ch}-SpectAll{Diffn}.CData{ch};
        Res.XData=SpectAll{diffm}.XData;
        Res.YData=SpectAll{diffm}.YData;
        Res.Coi=SpectAll{diffm}.Coi;
        PlotSpect(Res,Cscale,ch,Ytick,'ColorStyle',ColorStyle,'linepos',linepos,'Coneinf',Coneinf);
         if diffm==Diffm(1)
                    ylabel(['Ch' num2str(ch)]);
                end
                if diffm>Diffm(1)
                    set(gca,'yticklabel','');
                end
                if diffm==Diffm(end)
                    colorbar
                end
                if ch~=Chs
                    set(gca,'xticklabel','');
                end
                if ch==1
                    title([CueType ' ' Behav ' ' ResStr ' Diff' num2str(diffm-1)  '-Diff' num2str(Diffn-1) ]);
                end
    end
end

if ToPlot==1
    newpath=[savefold '\' Behav ];
    figsavepath=check_mkdir_SPR(Savepath,newpath);
    set(gcf,'outerposition',get(0,'screensize'));
    saveas(h,[figsavepath  '\' CueType  ' ' Behav ' '  ResStr '.jpg']);
    close
end

