function varargout = RatSPRNoiseWave(TrialParas,plotpara,Savepath)
eval([GetStructStr(plotpara) '=ReadStructValue(plotpara);']);

AxisHeight=0.6/length(Chs);
AxisWidth=0.93/2;
BasicXpos=0.03;
BasicYpos=1-AxisHeight-0.03;

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
        %% plot raster
        subplot('position',[BasicXpos BasicYpos-(count-1)*(AxisHeight+0.003) AxisWidth AxisHeight])
        %  try
        for soundnum = 1:length({TrialParas.SpikeRes.RasterPlot})
            buffer = TrialParas.SpikeRes(soundnum).RasterPlot;
            plot(buffer,ones(length(buffer),1)*soundnum,'r.','MarkerSize',10); hold on ;
        end
        xlim([0 TrialParas.SpikeRes(1).NeuWin(2)]);
        if ch==Chs(1)
            title([' Repetation Noise RasterPlot' ProtocolName  ],'Fontsize',20);
        end

        %% plot firing rate tuning
        subplot('position',[BasicXpos+(AxisWidth+0.02) BasicYpos-(count-1)*(AxisHeight+0.003) AxisWidth AxisHeight])
        buffer = [TrialParas.SpikeRes.FiringRate];
        plot([1:1:length(buffer)],buffer,'ro','MarkerSize',10,'LineWidth',3); hold on;
        plot([1:1:length(buffer)],buffer,'r-','LineWidth',2); hold on;
        if ch==Chs(1)
            title([' Repetation Noise FringRate TuningCurve' ProtocolName  ],'Fontsize',20);
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

    saveas(h,[figsavepath   '\Spike Repetation Noise' ProtocolName '.jpg']);
    close
end

toc
end
