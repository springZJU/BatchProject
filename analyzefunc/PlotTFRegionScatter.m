function PlotTFRegionScatter(varargin)

for i = 1:2:length(varargin)
    eval([ varargin{i} '=varargin{i+1};']);
end
eval([GetStructStr(Para) '=ReadStructValue(Para);']);
eval([GetStructStr(params) '=ReadStructValue(params);']);
eval([GetStructStr(plotpara) '=ReadStructValue(plotpara);']);

for protypes = 1:length(ActiveProtocolTypes)
    TrialParasPath = strrep(BufferData(cellnum).(ActiveProtocolTypes{protypes}).TrialParasPath,'F:\',RootDisk);
    load(TrialParasPath);
    TrialPush = TrialParas(strcmp({TrialParas.Behav},'Push'));
    TrialNoPush = TrialParas(strcmp({TrialParas.Behav},'NoPush'));
    subplot('Position',[BasicXposScatter+0.005 BasicYpos-(protypes*2-1)*(HeightScatter+0.02) WidthScatter HeightScatter])
    plot([TrialPush.TFCertainZscore],[TrialPush.Diff],'ro','MarkerSize',5,'MarkerFaceColor','r'); hold on 
    plot([TrialNoPush.TFCertainZscore],[TrialNoPush.Diff],'bo','MarkerSize',5); hold on 
    ylim([0 7]);
    plot([0 0],[0 7],'k--'); hold on
    set(gca,'YTickLabel',{' ','1','2','3','4','5',' ',' '});
    Ax = gca;
    xlim([-max(Ax.XLim)*1.2 max(Ax.XLim)*1.2]);
    title([ActiveProtocolTypes{protypes}]);
    legend('Push','NoPush');
end