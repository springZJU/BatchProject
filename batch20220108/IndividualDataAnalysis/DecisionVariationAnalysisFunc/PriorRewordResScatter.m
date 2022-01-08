function PriorRewordResScatter(varargin)

eval([GetStructStr(params) '=ReadStructValue(params);']);
figure
scatter(PriorCorrectRes,PriorWrongRes); hold on
xlabel('PriorCorrectRes');
ylabel('PriorWrongRes');
plot([0 1], [0 1],'k--'); hold on
Ax = gca;
xlim([min([Ax.XLim Ax.YLim]) max([Ax.XLim Ax.YLim])]);
ylim([min([Ax.XLim Ax.YLim]) max([Ax.XLim Ax.YLim])]);