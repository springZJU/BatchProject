function StdnumEffectFigures(varargin)
for i = 1:2:length(varargin)
    eval([ varargin{i} '=varargin{i+1};']);
end
eval([GetStructStr(params) '=ReadStructValue(params);']);
    Stdnum = fields(StdnumRes.(cuetype));
        StdBuffer{1} = [StdnumRes.(cuetype).(Stdnum{1})];
        StdBuffer{end} = [StdnumRes.(cuetype).(Stdnum{end})];
        % Fisher's exact test (since sample num<40 and certain push/nopush rate<5)
        for Protnum = 1:size(StdBuffer{1},2)
            FisherBuffer{Protnum} = [StdBuffer{1}(2,Protnum) StdBuffer{1}(3,Protnum)-StdBuffer{1}(2,Protnum);...
                StdBuffer{end}(2,Protnum) StdBuffer{end}(3,Protnum)-StdBuffer{end}(2,Protnum)]; % row: prior correct/wrong; col: current push/nopush
            [hFisher(Protnum),pFisher(Protnum)] = fishertest(FisherBuffer{Protnum},'Tail','right','Alpha',0.05);
        end
        % Plot Scatter with p-value information
        subplot(2,2,3)
        scatter(StdBuffer{1}(1,hFisher),StdBuffer{end}(1,hFisher),'r','filled'); hold on;
        scatter(StdBuffer{1}(1,~hFisher),StdBuffer{end}(1,~hFisher),'k'); hold on;

        plot([0 1],[0 1],'k--'); hold on;
        Ax = gca;
        xlabel(['Stdnum=' num2str(erase(Stdnum{1},'std')) 'Push rate'])
        ylabel(['Stdnum=' num2str(erase(Stdnum{end},'std')) 'Push rate']);
        xlim([min([Ax.XLim Ax.YLim]) max([Ax.XLim Ax.YLim])]);
        % Trial grouped Pearson chi-square test
        Chi2Buffer = [];
        for stdnums = 1:length(Stdnum)
        Chi2Buffer = [Chi2Buffer ;length(StdnumTrialClassesAll.(cuetype).(['Stdnum' num2str(erase(Stdnum{stdnums},'std')) 'ResPush'])),...
            length(StdnumTrialClassesAll.(cuetype).(['Stdnum' num2str(erase(Stdnum{stdnums},'std')) 'ResNoPush']))];
        xtickStr{stdnums} = ['Stdnum=' num2str(erase(Stdnum{stdnums},'std'))];
        end
        [pChi2,~] = chi2test(Chi2Buffer);
        title(['Standard Number Affected Push Rate Scatter Result, total chi2test p-value=' num2str(pChi2)]);
        legend('significant protocol','non-significant protocol','');
        % Plot bar of prior reword effect
        subplot(2,2,4)
        Chi2PushRate = Chi2Buffer./sum(Chi2Buffer,2);
        b = bar(Chi2PushRate);
        b(1).FaceColor = [0 0 0];
        b(2).FaceColor = [1 1 1];
        legend('Push','NoPush');
        xticklabels(xtickStr);
        for i = 1:length(Stdnum)
            text(i-0.2,Chi2PushRate(i,1)+0.03,num2str(Chi2PushRate(i,1)),'fontsize',10);
            text(i+0.1,Chi2PushRate(i,2)+0.03,num2str(Chi2PushRate(i,2)),'fontsize',10);
        end
        ylim([0 1]);
        title('Behavior Result of Standard Number Effect');