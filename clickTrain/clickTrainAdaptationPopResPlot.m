function [Fig,rez] = clickTrainAdaptationPopResPlot(params)
fieldName = fields(params);
for i = 1:length(fields(params))
    eval([fieldName{i} ' = params.(fieldName{i});']);
end

if ~exist('Fig','var')
    Fig = figure;
    maximizeFig(Fig);
end
buffer = rez.CTA.raster(ch);
spearman = rez.CTA.spearman(ch);
clickSlope = rez.CTA.clickSlope(ch);
ICIs = fields(buffer);

para = clickTrainConfig(protName);
ISI = para.ISI*1000;

adaptRepeat = length(clickSlope.p);
%% 
for num = 1:adaptRepeat %% split trials into different groups accoring to soundNum
    frateBuffer = cellfun(@(x) x{num},mstruct2cell(rez.CTA.frate(ch)),'UniformOutput',false);
    RSBuffer = cellfun(@(x) x{num},mstruct2cell(rez.CTA.RS(ch)),'UniformOutput',false);
    clickBuffer = cellfun(@(x) x{num},mstruct2cell(rez.CTA.click(ch)),'UniformOutput',false);
    for N = 1:length(ICIs)
        frateBuffer2{num,N} = frateBuffer{N};
        RSBuffer2{num,N} = RSBuffer{N};
        clickBuffer2{num,N} = clickBuffer{N};
        buffer.(ICIs{N}){num}(:,1) =  buffer.(ICIs{N}){num}(:,1) + (num-1)*ISI;
        rasterY = buffer.(ICIs{N}){num}(:,3);
        trialNums = unique(rasterY);
        nTrialN(N) = length(trialNums);
        for tnum = 1:length(trialNums)
        buffer.(ICIs{N}){num}(rasterY == trialNums(tnum),3) = tnum;
        end
    end
end
frateStruct = easyStruct(ICIs,frateBuffer2);
RSStruct = easyStruct(ICIs,RSBuffer2);
clickStruct = easyStruct(ICIs,clickBuffer2);

optPSTH = para.optPSTH;
for N = 1:length(ICIs)
    raster.(ICIs{N}) =  cell2mat(buffer.(ICIs{N})');
    psthBuffer{N} = mstruct2cell(calPsth(raster.(ICIs{N})(:,1),optPSTH,1000,'edge',[0 adaptRepeat*ISI],'nTrial', nTrialN(N)));
end

ICI = cell2mat(cellfun(@(x) str2num(erase(x,'ICI')),ICIs,'UniformOutput',false));
psth = cellfun(@(x) [smoothdata(cell2mat(x(:,1)),'gaussian',3) (cell2mat(x(:,2)'))'], psthBuffer,'UniformOutput',false);


%% for raster plot
Width = 0.4; Height = 0.2; Xpos = 0.58; Ypos = 0.78; ICIN = length(ICIs); subAxis = ICIN;
axis.raster = [ones(subAxis,1)*Xpos (Ypos+(0:1:subAxis-1)*Height/subAxis)' ones(subAxis,1)*Width ones(subAxis,1)*Height/subAxis];
% colors.raster = generateColorGrad(ICIN,'rgb','red',[1:ceil(ICIN/2)-1],'blue',[ceil(ICIN/2):ICIN]);
colors.raster = generateColorGrad(ICIN,'rgb');
for N = 1:ICIN
    Ax = subplot('Position',axis.raster(N,:));
    
    rasterX = raster.(ICIs{N})(:,1);
    rasterY = raster.(ICIs{N})(:,3);
    scatter(rasterX,rasterY,5,colors.raster{N},'filled'); hold on;
    YLIM = get(gca,'YLim');
    xlim([0 adaptRepeat*ISI]);
    ylabel(ICIs{N});
    set(Ax,'yticklabel',[]);
    if N ~= 1
        set(Ax,'xticklabel',[]);
    end
end
title([protName ' raster plot, Channel = ' num2str(ch)])


%% for PSTH plot
Width = 0.4; Height = 0.2; Xpos = 0.58; Ypos = 0.55; ICIN = length(ICIs); subAxis = ICIN;
axis.psth = [ones(subAxis,1)*Xpos (Ypos+(0:1:subAxis-1)*Height/subAxis)' ones(subAxis,1)*Width ones(subAxis,1)*Height/subAxis];
% colors.psth = generateColorGrad(ICIN,'rgb','red',[1:ceil(ICIN/2)-1],'blue',[ceil(ICIN/2):ICIN]);
colors.psth = generateColorGrad(ICIN,'rgb');
YLIM = [0 max(cell2mat(cellfun(@(x) max(x(:,1)),psth,'UniformOutput',false)))];

for N = 1:ICIN
    Ax = subplot('Position',axis.psth(N,:));
    plot(psth{N}(:,4),psth{N}(:,1),'color',colors.psth{N},'LineStyle','-','LineWidth',2,'DisplayName',ICIs{N} ); hold on
    ylim(YLIM);
    xlim([0 adaptRepeat*ISI]);

    ylabel(ICIs{N});
    set(Ax,'yticklabel',[]);
    if N ~= 1
        set(Ax,'xticklabel',[]);
    else
        xlabel('time from trial onset (ms)');
    end
end

title([protName ' PSTH plot, Channel = ' num2str(ch) ]); hold on


%% for firing rate
Width = 0.18; Height = 0.20; Xpos = 0.58; Ypos = 0.28; ICIN = length(ICIs); subAxis = 1;
axis.frate = [ones(subAxis,1)*Xpos (Ypos+(0:1:subAxis-1)*Height/subAxis)' ones(subAxis,1)*Width ones(subAxis,1)*Height/subAxis];
Ax = subplot('Position',axis.frate);
colors.frate = generateColorGrad(ICIN,'rgb');

for N = 1:ICIN
    frate = cell2mat(cellfun(@(x) x{1},frateBuffer2(:,N),'UniformOutput',false));
errorbar(1:adaptRepeat,frate(:,1),frate(:,2),'color',colors.frate{N},'LineStyle','-','LineWidth',3,'DisplayName',ICIs{N}); hold on
end
xlabel('sound number in a trial');
title([protName ' firing rate plot, Channel = ' num2str(ch) ]); hold on
% legend;

%% for click frate
Width = 0.18; Height = 0.20; Xpos = 0.8; Ypos = 0.28; ICIN = length(ICIs); subAxis = 1;
axis.click = [ones(subAxis,1)*Xpos (Ypos+(0:1:subAxis-1)*Height/subAxis)' ones(subAxis,1)*Width ones(subAxis,1)*Height/subAxis];
Ax = subplot('Position',axis.click);
colors.click = generateColorGrad(ICIN,'rgb');
for N = 1:ICIN
    click = cell2mat(cellfun(@(x) x{1},clickBuffer2(:,N),'UniformOutput',false));
errorbar(1:adaptRepeat,click(:,1),click(:,2),'color',colors.click{N},'LineStyle','-','LineWidth',3,'DisplayName',ICIs{N}); hold on
end
xlabel('sound number in a trial');
title([protName ' click firing rate plot, Channel = ' num2str(ch) ]); hold on
% legend;

%% for RS
Width = 0.18; Height = 0.20; Xpos = 0.58; Ypos = 0.02; ICIN = length(ICIs); subAxis = 1;
axis.RS = [ones(subAxis,1)*Xpos (Ypos+(0:1:subAxis-1)*Height/subAxis)' ones(subAxis,1)*Width ones(subAxis,1)*Height/subAxis];
Ax = subplot('Position',axis.RS);
colors.RS = generateColorGrad(ICIN,'rgb');
for N = 1:ICIN
RS = cell2mat(cellfun(@(x) x{1},RSBuffer2(:,N),'UniformOutput',false));
RSp = cell2mat(cellfun(@(x) x{2},RSBuffer2(:,N),'UniformOutput',false));
errorbar(1:adaptRepeat,RS(:,1),RS(:,2),'color',colors.RS{N},'LineStyle','-','LineWidth',3,'DisplayName',ICIs{N}); hold on
for tnum = 1:adaptRepeat
    if abs(RSp(tnum)) < 0.05
        scatter(tnum,RS(tnum),100,colors.RS{N},'filled','HandleVisibility','off'); hold on
    else
        scatter(tnum,RS(tnum),100,colors.RS{N},'HandleVisibility','off'); hold on
    end
end
end
plot(get(gca,'XLim'),[13.8 13.8],'k:','LineWidth',3,'DisplayName','RS = 13.8'); hold on
title([protName ' RS plot, Channel = ' num2str(ch) ]); hold on
xlabel('sound number in a trial');
% legend;



%% for spearman & click slope
Width = 0.17; Height = 0.20; Xpos = 0.8; Ypos = 0.02; ICIN = length(ICIs); subAxis = 1;
axis.SS = [ones(subAxis,1)*Xpos (Ypos+(0:1:subAxis-1)*Height/subAxis)' ones(subAxis,1)*Width ones(subAxis,1)*Height/subAxis];
Ax = subplot('Position',axis.SS);
yyaxis left
plot(1:adaptRepeat,spearman.coeff,'color','red','LineStyle','-','LineWidth',3,'DisplayName','spearman rank corr coeff'); hold on
ylabel('spearman rank corr coeff');

yyaxis right
plot(1:adaptRepeat,cell2mat(clickSlope.slope),'color','blue','LineStyle','-','LineWidth',3,'DisplayName','clickSlope'); hold on
ylabel('slope through different ICIs');

title([protName ' spearman and click train slope plot, Channel = ' num2str(ch) ]); hold on
xlabel('sound number in a trial');
legend;



rez.RS = RS;
rez.frate = frate;
rez.click = click;
rez.ICI = ICI;

end

