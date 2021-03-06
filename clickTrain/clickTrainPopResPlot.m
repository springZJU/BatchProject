function [Fig,rez] = clickTrainPopResPlot(params)
fieldName = fields(params);
for i = 1:length(fields(params))
    eval([fieldName{i} ' = params.(fieldName{i});']);
end

if ~exist('Fig','var')
    Fig = figure;
    maximizeFig(Fig);
end
buffer = rez.CT.raster(ch);
spearman = rez.CT.spearman(ch);
clickSlope = rez.CT.clickSlope(ch);
frate = cell2mat(cellfun(@(x) x{1},mstruct2cell(rez.CT.frate(ch))','UniformOutput',false));
RS = cell2mat(cellfun(@(x) [x{1} x{2}],mstruct2cell(rez.CT.RS(ch))','UniformOutput',false));
ICIs = fields(buffer);
ICI = cell2mat(cellfun(@(x) str2num(erase(x,'ICI')),ICIs,'UniformOutput',false));
psthBuffer = cellfun(@(x) mstruct2cell(x),mstruct2cell(rez.CT.psth(ch)),'UniformOutput',false);
psth = cellfun(@(x) [smoothdata(cell2mat(x(:,1)),'gaussian',3) (cell2mat(x(:,2)'))'], psthBuffer,'UniformOutput',false);
clickAdapt = cellfun(@(x) x{2},mstruct2cell(rez.CT.click(ch)),'UniformOutput',false);
click = cell2mat(cellfun(@(x) x{1},mstruct2cell(rez.CT.click(ch)),'UniformOutput',false)');

%% for raster plot
Width = 0.3; Height = 0.28; Xpos = 0.02; Ypos = 0.68; ICIN = length(ICIs); subAxis = ICIN;
axis.raster = [ones(subAxis,1)*Xpos (Ypos+(0:1:subAxis-1)*Height/subAxis)' ones(subAxis,1)*Width ones(subAxis,1)*Height/subAxis];
colors.raster = generateColorGrad(ICIN,'rgb','red',[1:ceil(ICIN/2)-1],'blue',[ceil(ICIN/2):ICIN]);
for N = 1:ICIN
    Ax = subplot('Position',axis.raster(N,:));
    rasterX = buffer.(ICIs{N})(:,1);
    bufferY = buffer.(ICIs{N})(:,3);
    rasterY = buffer.(ICIs{N})(:,3);
    trialNums = unique(rasterY);
    for num = 1:length(trialNums)
        rasterY(bufferY == trialNums(num)) = num;
    end
    scatter(rasterX,rasterY,5,colors.raster{N},'filled'); hold on;
    YLIM = get(gca,'YLim');
    for S = 1:length(clickAdapt{N})
    plot([ICI(N)*(S-1) ICI(N)*(S-1)],YLIM,'Color','#555555','LineStyle','-'); hold on;
    end
    xlim([0 1650]);
    ylabel(ICIs{N});
    set(Ax,'yticklabel',[]);
    if N ~= 1
        set(Ax,'xticklabel',[]);
    else
        xlabel('time from trial onset (ms)');
    end
end
title([protName ' raster plot, Channel = ' num2str(ch) '  [spearman coeff , p] = [' num2str(roundn(spearman.coeff,-3)) ', ' num2str(roundn(spearman.p,-3)) '],  [clickTrainSlope , p] = [' num2str(roundn(clickSlope.slope,-3)) ', ' num2str(roundn(clickSlope.p,-3)) ']'])


% for PSTH plot
Width = 0.3; Height = 0.28; Xpos = 0.02; Ypos = 0.35; ICIN = length(ICIs); subAxis = ICIN;
axis.psth = [ones(subAxis,1)*Xpos (Ypos+(0:1:subAxis-1)*Height/subAxis)' ones(subAxis,1)*Width ones(subAxis,1)*Height/subAxis];
colors.psth = generateColorGrad(ICIN,'rgb','red',[1:ceil(ICIN/2)-1],'blue',[ceil(ICIN/2):ICIN]);
YLIM = [0 max(cell2mat(cellfun(@(x) max(x(:,1)),psth,'UniformOutput',false)))];
for N = 1:ICIN
    Ax = subplot('Position',axis.psth(N,:));
    plot(psth{N}(:,4),psth{N}(:,1),'color',colors.psth{N},'LineStyle','-','LineWidth',2,'DisplayName',ICIs{N} ); hold on
    ylim(YLIM);
    xlim([0 1650]);
    errorbar(10+(0:ICI(N):ICI(N)*(size(clickAdapt{N},1)-1)),clickAdapt{N}(:,1),clickAdapt{N}(:,2),'color',colors.psth{N},'LineStyle','-','LineWidth',1); hold on
    for S = 1:length(clickAdapt{N})
    plot([ICI(N)*(S-1) ICI(N)*(S-1)],YLIM,'Color','#555555','LineStyle','-'); hold on;
    end
    ylabel(ICIs{N});
    set(Ax,'yticklabel',[]);
    if N ~= 1
        set(Ax,'xticklabel',[]);
    else
        xlabel('time from trial onset (ms)');
    end
end
title([protName ' PSTH plot, Channel = ' num2str(ch) ]); hold on


%% for firing rate & teyleigh statistics plot
Width = 0.26; Height = 0.28; Xpos = 0.04; Ypos = 0.02; ICIN = length(ICIs); subAxis = 1;
axis.frate = [ones(subAxis,1)*Xpos (Ypos+(0:1:subAxis-1)*Height/subAxis)' ones(subAxis,1)*Width ones(subAxis,1)*Height/subAxis];
Ax = subplot('Position',axis.frate);
yyaxis left
errorbar(ICI,frate(:,1),frate(:,2),'b-','LineWidth',3,'DisplayName','clickTrain frate'); hold on
errorbar(ICI,click(:,1),click(:,2),'c-','LineWidth',3,'DisplayName','click frate'); hold on
ylabel('Firing rate (Hz)');

yyaxis right

errorbar(ICI,RS(:,1),RS(:,2),'r-','LineWidth',3,'DisplayName','RS'); hold on
for N = 1:ICIN
    if abs(RS(N,3)) < 0.05
        scatter(ICI(N),RS(N,1),100,'red','filled','HandleVisibility','off'); hold on
    else
        scatter(ICI(N),RS(N,1),100,'red','HandleVisibility','off'); hold on
    end
end
ylabel('RS');

set(gca,'XScale','log');
plot(get(gca,'XLim'),[13.8 13.8],'k:','LineWidth',3,'DisplayName','RS = 13.8'); hold on
title([protName ' firing rate & Rayleigh statistics plot, Channel = ' num2str(ch) ]); hold on
legend('Location','northwest');
xlabel('ICI (ms)')



%% inregrate click train and click adaptation
if isfield(popRez,'CA')
Width = 0.2; Height = 0.26; Xpos = 0.35; Ypos = 0.04; ICIN = length(ICIs); subAxis = 1;
axis.CTCA = [ones(subAxis,1)*Xpos (Ypos+(0:1:subAxis-1)*Height/subAxis)' ones(subAxis,1)*Width ones(subAxis,1)*Height/subAxis];
Ax = subplot('Position',axis.CTCA);

CAICI = popRez.CA.ICI;
ICIAll = [ICI ; CAICI];
CAclick = popRez.CA.click;
clickAll = [click ; CAclick];
errorbar(ICIAll,clickAll(:,1),clickAll(:,2),'r-','LineWidth',3); hold on
set(Ax,'XScale','log');
set(Ax,'XTick',ICIAll);
set(Ax,'xticklabel',cellfun(@(x) num2str(x),num2cell(ICIAll),'UniformOutput',false));
legend('click ','Location','northwest');
title([protName 'click adaptation integration, Channel = ' num2str(ch) ]); hold on


end
rez.RS = RS;
rez.frate = frate;
rez.click = click;
rez.clickAdapt = clickAdapt;
rez.ICI = ICI;

end

