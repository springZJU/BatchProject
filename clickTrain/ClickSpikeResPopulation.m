function [popPlotData,params] = ClickSpikeResPopulation(varargin)
for i = 1:2:length(varargin)
    eval([ varargin{i} '=varargin{i+1};']);
end
eval([GetStructStr(params) '=ReadStructValue(params);']);


%% population result
for cellnum = 1:length(BufferData)
    SitePos = BufferData(cellnum).SitePos;
Date = BufferData(cellnum).Date;
Region = BufferData(cellnum).Region;
savefold = IndividualSaveFold;
    rez.CT = BufferData(cellnum).ClickTrain.rez; % ClickTrain
    rez.CA = BufferData(cellnum).ClickAdaptation.rez; % ClickAdaptation
    rez.CTA = BufferData(cellnum).ClickTrainAdaptation.rez; % ClickTrainAdaptation
    ch.CT = find(~isnan([rez.CT.clickSlope.p]));
    ch.CA = find(~isnan([rez.CA.adaptation.p]));
    buffer = cell2mat(cellfun(@(x) x{1},struct2cell(rez.CTA.clickSlope)','UniformOutput',false));
    ch.CTA = find(~isnan(buffer(:,2)));
    chSame = intersect(intersect(ch.CT,ch.CA),ch.CTA);
    fieldBuffer = fields(BufferData);
    protocolNames = fieldBuffer(ProtocolLogic);
    for ch = chSame'
        for prot = 1:length(protocolNames)
            protName = protocolNames{prot};
            params.rez = rez;
            params.ch = ch;
            params.protName = protName;
            params.popRez.Raw = [];
            switch protName
                case 'ClickTrain'
                    %% plot for click train protocol
                    % raster, frate(title including spearman & clickSlope), psth, RS
                    if exist('Fig','var')
                        params.Fig = Fig;
                    end
                    [Fig , params.popRez.CT] = clickTrainPopResPlot(params);
                case 'ClickAdaptation'
                    %% plot for click adaptation protocol
                    % raster, frate, slope
                    if exist('Fig','var')
                        params.Fig = Fig;
                    end
                    [Fig , params.popRez.CA] = clickAdaptationPopResPlot(params);
                case 'ClickTrainAdaptation'
                    %% plot for click train adaptation protocol
                    % raster, frate(title including spearman & clickSlope), psth, RS
                    if exist('Fig','var')
                        params.Fig = Fig;
                    end
                    [Fig , params.popRez.CTA] = clickTrainAdaptationPopResPlot(params);
            end

        end
        savepath = check_mkdir_SPR(savefold, [Region '\' Date '_' SitePos]);
        saveas(Fig,[savepath '\Ch' num2str(ch)  '.jpg']);
        close(Fig);
        clear Fig 
        params = rmfield(params,{'popRez','Fig'});
    end

end


