function PriorEffectFigures(varargin)
for i = 1:2:length(varargin)
    eval([ varargin{i} '=varargin{i+1};']);
end
eval([GetStructStr(params) '=ReadStructValue(params);']);
        PriorCorrectBuffer = PriorCorrectRes.(cuetype);
        PriorWrongBuffer = PriorWrongRes.(cuetype);
        % Fisher's exact test (since sample num<40 and certain push/nopush rate<5)
        for Protnum = 1:size(PriorCorrectBuffer,2)
            FisherBuffer{Protnum} = [PriorCorrectBuffer(2,Protnum) PriorCorrectBuffer(3,Protnum)-PriorCorrectBuffer(2,Protnum);...
                PriorWrongBuffer(2,Protnum) PriorWrongBuffer(3,Protnum)-PriorWrongBuffer(2,Protnum)]; % row: prior correct/wrong; col: current push/nopush
            [hFisher(Protnum),pFisher(Protnum)] = fishertest(FisherBuffer{Protnum},'Tail','right','Alpha',0.05);
        end
        % Plot Scatter with p-value information
        subplot(2,2,1)
        scatter(PriorCorrectBuffer(1,hFisher),PriorWrongBuffer(1,hFisher),'r','filled'); hold on;
        scatter(PriorCorrectBuffer(1,~hFisher),PriorWrongBuffer(1,~hFisher),'k'); hold on;

        plot([0 1],[0 1],'k--'); hold on;
        Ax = gca;
        xlabel('PriorCorrect Push rate');
        ylabel('PriorWrong Push rate');
        xlim([min([Ax.XLim Ax.YLim]) max([Ax.XLim Ax.YLim])]);
        % Trial grouped Pearson chi-square test
        Chi2Buffer = [length(PriorTrialClassesAll.(cuetype).PriorCorrectResPush),...
            length(PriorTrialClassesAll.(cuetype).PriorCorrectResNoPush);...
            length(PriorTrialClassesAll.(cuetype).PriorWrongResPush),...
            length(PriorTrialClassesAll.(cuetype).PriorWrongResNoPush)];
        [pChi2,~] = chi2test(Chi2Buffer);
        title(['Prior Result Affected Push Rate Scatter Result, total chi2test p-value=' num2str(pChi2)]);
        legend('significant protocol','non-significant protocol','');
        % Plot bar of prior reword effect
        subplot(2,2,2)
        Chi2PushRate = Chi2Buffer./sum(Chi2Buffer,2);
        b = bar(Chi2PushRate);
        b(1).FaceColor = [0 0 0];
        b(2).FaceColor = [1 1 1];
        legend('Push','NoPush');
        xticklabels({'PriorCorrect(Reword)','PriorWrong(NoReword)'});
        for i = 1:2
            text(i-0.2,Chi2PushRate(i,1)+0.03,num2str(Chi2PushRate(i,1)),'fontsize',10);
            text(i+0.1,Chi2PushRate(i,2)+0.03,num2str(Chi2PushRate(i,2)),'fontsize',10);
        end
        ylim([0 1]);
        title('Behavior Result of Prior Reword Effect');