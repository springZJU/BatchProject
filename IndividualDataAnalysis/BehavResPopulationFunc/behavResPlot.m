 function bhvPlotbuffer = hehavResPlot(popRes,varargin)
for i = 1:2:length(varargin)
    eval([ varargin{i} '=varargin{i+1};']);
end
eval([GetStructStr(params) '=ReadStructValue(params);']);
popResFields = fields(popRes);
figure
set(gcf,'outerposition',get(0,'screensize'));
    %% relationship between behavioral threshold and base frequency
for popResNum = 1:length(popResFields)   
        buffer = popRes.(popResFields{popResNum});
    if popResNum == 1
        buffer2 = [buffer.baseStiPara [buffer.behavioralThr.freq]'];
    else
        buffer2 = [buffer2; buffer.baseStiPara [buffer.behavioralThr.freq]'];
    end
end
%     subplotPanel(length(popResFields),popResNum,'position');
    scatter(buffer2(:,1),buffer2(:,2),'k','filled'); hold on;
    res = uniqueCount(buffer2,1);
    bhvPlot(:,1) = cell2mat(res(:,1)); %frequency
    bhvPlot(:,2) = cellfun(@mean,res(:,2)); % mean
    bhvPlot(:,3) = cellfun(@std,res(:,2))./sqrt(cellfun(@length,res(:,2))); % SE
    errorbar(bhvPlot(:,1),bhvPlot(:,2),bhvPlot(:,3),'r-','LineWidth',1.5); hold on;
    bhvPlotbuffer.bhvPlot = bhvPlot;
    bhvPlotbuffer.res = res;
    set(gca,'xscale','log');
end

