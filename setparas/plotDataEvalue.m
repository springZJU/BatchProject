function ProtocolData = plotDataEvalue(ProtocolData,PlotData)
if ~isempty(PlotData)
    if isfield(PlotData,'SpectData')
            ProtocolData.PlotData = rmfield(PlotData,'SpectData');
    else
        ProtocolData.PlotData = PlotData;
    end
           
   if isfield(PlotData,'SpikeAnalysis')
                 buffer = ProtocolData.PlotData.SpikeAnalysis.SpikePsth;
                ProtocolData.PlotData.SpikeAnalysis = rmfield(PlotData.SpikeAnalysis,{'SpikePsth','rasterPlot'});
            
            %Psth数据只存DevOnset对齐和PushTime对齐且做对的
            cueType = fields(buffer);
            for cueNum = 1:length(cueType)
                psthBuffer.DevOnset = [buffer.(cueType{cueNum})(1).DevOnset.All.edges];
                psthBuffer.Pushtime = [buffer.(cueType{cueNum})(1).Pushtime.All.edges];
                psthBuffer.DevOnset([1 2],:) = []; psthBuffer.Pushtime([1 2],:)  = []; 
                for devDiff = 1:size(buffer.(cueType{cueNum}),2)
                    psthBuffer.DevOnset = [psthBuffer.DevOnset ;buffer.(cueType{cueNum})(devDiff).DevOnset.Correct.y];
                    psthBuffer.Pushtime = [psthBuffer.Pushtime ;buffer.(cueType{cueNum})(devDiff).Pushtime.Correct.y];
                end
            DevOnsetIndex = psthBuffer.DevOnset(1,:)>-500 & psthBuffer.DevOnset(1,:)<1500;
            PushTimeIndex = psthBuffer.Pushtime(1,:)>-1000 & psthBuffer.Pushtime(1,:)<1000;
            ProtocolData.PlotData.SpikeAnalysis.SpikePsth.(cueType{cueNum}).DevOnset = psthBuffer.DevOnset(:,DevOnsetIndex);
            ProtocolData.PlotData.SpikeAnalysis.SpikePsth.(cueType{cueNum}).Pushtime = psthBuffer.Pushtime(:,PushTimeIndex);
            end
            end
end