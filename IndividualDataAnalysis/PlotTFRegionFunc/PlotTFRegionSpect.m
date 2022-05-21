function PlotTFRegionSpect(varargin)
for i = 1:2:length(varargin)
    eval([ varargin{i} '=varargin{i+1};']);
end
eval([GetStructStr(Para) '=ReadStructValue(Para);']);
eval([GetStructStr(params) '=ReadStructValue(params);']);
eval([GetStructStr(plotpara) '=ReadStructValue(plotpara);']);
for protypes = 1:length(ActiveProtocolTypes)
    
    Path = strrep(BufferData(cellnum).(ActiveProtocolTypes{protypes}).PlotDataPath,'F:\',RootDisk);
    TFPlot{1} = load(Path);
    try
        Path = strrep(BufferData(cellnum).(PassiveProtocolTypes{protypes}).PlotDataPath,'F:\',RootDisk);
        ActiveProtocolTypes{protypes,2} = PassiveProtocolTypes{protypes};
        TFPlot{2} = load(Path);
        Plotnum = 2;
    catch
        Plotnum = 1;
    end
    for TFnum = 1:Plotnum
        BehavType = {'Push','NoPush'};
        for Behavnum = 1:2
            try
                Spect = TFPlot{TFnum}.PlotData.SpectData.Stdres.freq.Align2Std1Onset.(BehavType{Behavnum}){1,1};
            catch
                continue
            end

            subplot('Position',[BasicXposSpect+(TFnum-1)*(WidthSpect+0.01) BasicYpos-((protypes-1)*2+Behavnum)*(HeightSpect+0.02) WidthSpect HeightSpect])
            AxSpect{(protypes-1)*2+Behavnum,TFnum}=gca;
            PlotSpect(Spect,Cscale,ch,Ytick,'ColorStyle',ColorStyle,'linepos',linepos,'Coneinf',Coneinf,'BackgroundRegion',BackgroundRegion);
            if ~isempty(ylinepos)
                for py=1:length(ylinepos)
                    plot([ylinepos(py) ylinepos(py)],[Spect.YData(1) Spect.YData(end)],'k--','linewidth',2);hold on
                end
            end
            if any(strcmp(Cscale,{'auto_equalCLim','auto_semiequalCLim'}))
                CLimMax((protypes-1)*2+Behavnum,TFnum)= max(abs(AxSpect{(protypes-1)*2+Behavnum,TFnum}.CLim));
            end
            if ~(protypes==length(ActiveProtocolTypes) & Behavnum==2)
                set(gca,'XTickLabel','');
            end
            title([ActiveProtocolTypes{protypes,TFnum} ' ' BehavType{Behavnum} ] )
        end
    end
end


%% set all colorbars to the same scale.
try
CLimMaxAll =  sort(reshape(CLimMax,numel(CLimMax),1));
CLimFinal = CLimMaxAll(end-1);
for Rows = 1:size(AxSpect,1)
    for Columns = 1:size(AxSpect,2)
        try
            if strcmp(Cscale,'auto_equalCLim')
                set(AxSpect{Rows,Columns},'CLim',[-CLimFinal CLimFinal]);
            elseif strcmp(Cscale,'auto_semiequalCLim')
                set(AxSpect{Rows,Columns},'CLim',[0 CLimFinal]);
            end
        catch
            continue
        end
    end
end
catch
end

