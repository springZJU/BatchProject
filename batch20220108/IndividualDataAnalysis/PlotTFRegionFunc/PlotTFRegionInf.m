function PlotTFRegionInf(varargin)
for i = 1:2:length(varargin)
    eval([ varargin{i} '=varargin{i+1};']);
end
eval([GetStructStr(Para) '=ReadStructValue(Para);']);
eval([GetStructStr(params) '=ReadStructValue(params);']);
eval([GetStructStr(plotpara) '=ReadStructValue(plotpara);']);
hh = waitbar(0,'please wait');
for cellnum = 1:size(BufferData,1)
% for cellnum = 62
    str=['Running PlotTFRegionInf, current: ' num2str(cellnum) , '(' num2str(cellnum) '/' num2str(size(BufferData,1)) ')' ];
    waitbar(cellnum/size(BufferData,1),hh,str)
    h = figure
    set(gcf,'outerposition',get(0,'screensize'));
    ProtocolName = BufferField(ProtocolLogic&StructLogic(cellnum,:));
    ActiveProtocolTypes = ProtocolName(contains(ProtocolName,'Active'));
    PassiveProtocolTypes = strrep(ActiveProtocolTypes,'Active','Passive');
    HeightSpect = 0.86/length(ActiveProtocolTypes)/2; HeightHistogram = HeightSpect-0.02; HeightScatter = HeightSpect; HeightSpike = HeightSpect;
    SitePos = BufferData(cellnum).SitePos;
    Date = BufferData(cellnum).Date;
    Region = BufferData(cellnum).Region;
    
    for ch = Chs
        params.ProtocolName = ProtocolName; params.ActiveProtocolTypes = ActiveProtocolTypes; params.PassiveProtocolTypes = PassiveProtocolTypes;
        params.HeightSpect = HeightSpect; params.HeightHistogram = HeightHistogram; params.HeightScatter = HeightScatter;  params.HeightSpike = HeightSpike;
        params.cellnum = cellnum; params.ch = ch; 
        NotSave = [];

        %% plot timefrequency result
        try
        PlotTFRegionSpect('params',params,'plotpara',plotpara,'Para',Para);
        catch
            NotSave = [NotSave 1];
        end

        %% plot TFCertainRegion zscored power distribution
        try
        PlotTFRegionDistribution('params',params,'plotpara',plotpara,'Para',Para);
        catch
            NotSave = [NotSave 2];
        end

        %% plot timefrequency result
        try
        PlotTFRegionScatter('params',params,'plotpara',plotpara,'Para',Para);
        catch
            NotSave = [NotSave 3];
        end

    end
    if sum(NotSave)~=6
    savepath = check_mkdir_SPR(savefold,['TFRegionInf\' Region] );
    saveas(h,[savepath '\' SitePos '_' Date  '.jpg']);
    close
    end


end
delete(hh)
