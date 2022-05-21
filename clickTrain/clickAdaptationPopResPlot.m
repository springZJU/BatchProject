function [Fig,rez] = clickAdaptationPopResPlot(params)
fieldName = fields(params);
for i = 1:length(fields(params))
    eval([fieldName{i} ' = params.(fieldName{i});']);
end

if ~exist('Fig','var')
    Fig = figure;
    maximizeFig(Fig);
end

buffer = rez.CA.raster(ch);
frate = cell2mat(mstruct2cell(rez.CA.frateNew(ch))');
ICIs = fields(buffer);
ICI = cell2mat(cellfun(@(x) str2num(erase(x,'ICI')),ICIs,'UniformOutput',false));
psthBuffer = cellfun(@(x) mstruct2cell(x),mstruct2cell(rez.CA.psthNew(ch)),'UniformOutput',false);
psth = cellfun(@(x) [smoothdata(cell2mat(x(:,1)),'gaussian',3) (cell2mat(x(:,2)'))'], psthBuffer,'UniformOutput',false);
click = cell2mat(mstruct2cell(rez.CA.click(ch))');
adaptationBuffer = mstruct2cell(rez.CA.adaptation(ch));
adaptation = cell2mat(adaptationBuffer([1 2]));

clickNum = max(max(cell2mat(cellfun(@(x) max(x(:,2)),mstruct2cell(rez.CA.raster),'UniformOutput',false))));

%% for raster plot
Width = 0.2; Height = 0.28; Xpos = 0.35; Ypos = 0.68; ICIN = length(ICIs); subAxis = ICIN;
axis.raster = [ones(subAxis,1)*Xpos (Ypos+(0:1:subAxis-1)*Height/subAxis)' ones(subAxis,1)*Width ones(subAxis,1)*Height/subAxis];
% colors.raster = generateColorGrad(ICIN,'rgb','red',[1:ceil(ICIN/2)-1],'blue',[ceil(ICIN/2):ICIN]);
colors.raster = generateColorGrad(ICIN,'rgb');
for N = 1:ICIN
    Ax = subplot('Position',axis.raster(N,:));
%     a = buffer.(ICIs{N});
    rasterX = buffer.(ICIs{N})(:,1);
    rasterY = buffer.(ICIs{N})(:,2);
    scatter(rasterX,rasterY,5,colors.raster{N},'filled'); hold on;
%     xlim([0 ICI(N)*clickNum]);
    xlim([0 min(ICI)]);
    ylabel(ICIs{N});
    set(Ax,'yticklabel',[]);
    set(Ax,'xticklabel',{})
    if N ~= 1
        set(Ax,'xticklabel',[]);
    else
        xlabel('time from trial onset (ms)');
    end
end

title([protName ' raster plot, Channel = ' num2str(ch)  '[adaptation slope , p] = [' num2str(roundn(adaptation(1),-3)) ', ' num2str(roundn(adaptation(2),-3)) ']'])


%% for PSTH plot
% Width = 0.3; Height = 0.3; Xpos = 0.35; Ypos = 0.35; ICIN = length(ICIs); subAxis = ICIN;
% axis.psth = [ones(subAxis,1)*Xpos (Ypos+(0:1:subAxis-1)*Height/subAxis)' ones(subAxis,1)*Width ones(subAxis,1)*Height/subAxis];
% colors.psth = generateColorGrad(ICIN,'rgb','red',[1:ceil(ICIN/2)-1],'blue',[ceil(ICIN/2):ICIN]);
% YLIM = [0 max(cell2mat(cellfun(@(x) max(x(:,1)),psth,'UniformOutput',false)))];
% for N = 1:ICIN
%     Ax = subplot('Position',axis.psth(N,:));
%     plot(psth{N}(:,4),psth{N}(:,1),'color',colors.psth{N},'LineStyle','-','LineWidth',2,'DisplayName',ICIs{N} ); hold on
%     ylim(YLIM);
%     xlim([0 300]);
% %     errorbar(10+(0:ICI(N):ICI(N)*(size(clickAdapt{N},1)-1)),clickAdapt{N}(:,1),clickAdapt{N}(:,2),'color',colors.psth{N},'LineStyle','-','LineWidth',1); hold on
% %     plot(repmat((0:ICI(N):ICI(N)*(size(clickAdapt{N},1)-1))',1,2),repmat(YLIM,ceil(TrainDur/ICIN),1),'k:'); hold on;
%     ylabel(ICIs{N});
%     set(Ax,'yticklabel',[]);
%     if N ~= 1
%         set(Ax,'xticklabel',[]);
%     end
% end
% title([protName ' PSTH plot, Channel = ' num2str(ch) ]); hold on


%% for click adaptation
% Width = 0.2; Height = 0.3; Xpos = 0.35; Ypos = 0.35; ICIN = length(ICIs); subAxis = 1;
% axis.frate = [ones(subAxis,1)*Xpos (Ypos+(0:1:subAxis-1)*Height/subAxis)' ones(subAxis,1)*Width ones(subAxis,1)*Height/subAxis];
% Ax = subplot('Position',axis.frate);
% errorbar(ICI,click(:,1),click(:,2),'r-','LineWidth',3); hold on
% set(Ax,'XScale','log');
% set(Ax,'XTick',ICI);
% set(Ax,'xticklabel',cellfun(@(x) num2str(x),num2cell(ICI),'UniformOutput',false));
% legend('click adaptation firing rate','Location','northwest');
% title([protName 'click adaptation firing rate, Channel = ' num2str(ch) ]); hold on

%% for adpatation
Width = 0.2; Height = 0.28; Xpos = 0.35; Ypos = 0.35; ICIN = length(ICIs); subAxis = 1;
axis.adaptation = [ones(subAxis,1)*Xpos (Ypos+(0:1:subAxis-1)*Height/subAxis)' ones(subAxis,1)*Width ones(subAxis,1)*Height/subAxis];
Ax = subplot('Position',axis.adaptation);
colors.adapt = generateColorGrad(ICIN,'rgb');
for N = 1:ICIN
    plotBuffer = adaptationBuffer{5}{N};
    plot(1:length(plotBuffer),plotBuffer,'Color',colors.adapt{N},'LineStyle','-','LineWidth',3,'DisplayName',ICIs{N}); hold on
end
legend;
title([protName 'click  firing rate along repetation, Channel = ' num2str(ch) ]); hold on
xlabel('sound number in a trial');

%% inregrate click train and click adaptation
if isfield(popRez,'CT')
Width = 0.2; Height = 0.28; Xpos = 0.35; Ypos = 0.02; ICIN = length(ICIs); subAxis = 1;
axis.CTCA = [ones(subAxis,1)*Xpos (Ypos+(0:1:subAxis-1)*Height/subAxis)' ones(subAxis,1)*Width ones(subAxis,1)*Height/subAxis];
Ax = subplot('Position',axis.CTCA);

CTICI = popRez.CT.ICI;
ICIAll = [CTICI; ICI];
CTclick = popRez.CT.click;
clickAll = [CTclick ; click];
errorbar(ICIAll,clickAll(:,1),clickAll(:,2),'r-','LineWidth',3); hold on
set(Ax,'XScale','log');
set(Ax,'XTick',ICIAll);
set(Ax,'xticklabel',cellfun(@(x) num2str(x),num2cell(ICIAll),'UniformOutput',false));
legend('click ','Location','northwest');
title([protName 'click adaptation integration, Channel = ' num2str(ch) ]); hold on
xlabel('ICI (ms)')



end





rez.frate = frate;
rez.click = click;
rez.ICI = ICI;

end

