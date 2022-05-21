function popRes = SpikeResPopulation(IndividualData,varargin)
for i = 1:2:length(varargin)
    eval([ varargin{i} '=varargin{i+1};']);
end

savePath = 'E:\RATCLICK\IndividualResult\AC';
%% population result
cellBuffer = mstruct2cell(IndividualData);
buffer = cellBuffer(cellfun(@isstruct,cellBuffer));
chsAll = cellfun(@(x) find(x.rez.asDev.fRateMean1{1} ~= 0),buffer,'uni',false);
firstStdAll = cellfun(@(x) x.rez.asStd(1),buffer,'uni',false);
lastStdAll = cellfun(@(x) x.rez.asStd(end-1),buffer,'uni',false);
lastSoundAll = cellfun(@(x) x.rez.asStd(end),buffer,'uni',false);
devAll = cellfun(@(x) x.rez.asDev,buffer,'uni',false);
savePathAll = cellfun(@(x) erase(x.rezPath,'\\stimParams.mat'),buffer,'uni',false);
stimTypeAll = cellfun(@(x) x.stimType,buffer,'uni',false);


soundPairs = {'std1StdEnd' , 'stdEndDev' , 'stdEndSoundEnd'};
protName = {'BasicThr','Insert','BasicNoAtt','HighOrder'};
soundSelect = {'firstStd','lastStd','lastSound','dev'};

%% analyse for each protocol
% all cell
for i = 1 : length(chsAll)
    n = 0;
    chs = chsAll{i}';
    stimType = stimTypeAll{i};
    for ch = chs
        n = n + 1;
        for ii = 1 : numel(stimType)
            % 0-50 ms
            for soundN = 1 : length(soundSelect)
            eval(['fRate0.' soundSelect{soundN} '{i,ii}(n,:) = ' soundSelect{soundN} 'All{i}.fRate0{ii}(ch,:);']);
            eval(['fRateMean0.' soundSelect{soundN} '{i,ii}(n) = ' soundSelect{soundN} 'All{i}.fRateMean0{ii}(ch);']);
            end

            [~ , p0.std1StdEnd{i,ii}(n)] = ttest(fRate0.firstStd{i,ii}(n,:),fRate0.lastStd{i,ii}(n,:));
            [~ , p0.stdEndDev{i,ii}(n)] = ttest2(fRate0.lastStd{i,ii}(n,:),fRate0.dev{i,ii}(n,:));
            [~ , p0.stdEndSoundEnd{i,ii}(n)] = ttest(fRate0.lastStd{i,ii}(n,:),fRate0.lastSound{i,ii}(n,:));

            % 50-200 ms
            for soundN = 1 : length(soundSelect)
            eval(['fRate1.' soundSelect{soundN} '{i,ii}(n,:) = ' soundSelect{soundN} 'All{i}.fRate1{ii}(ch,:);']);
            eval(['fRateMean1.' soundSelect{soundN} '{i,ii}(n) = ' soundSelect{soundN} 'All{i}.fRateMean1{ii}(ch);']);
            end
            [~ , p1.std1StdEnd{i,ii}(n)] = ttest(fRate1.firstStd{i,ii}(n,:),fRate1.lastStd{i,ii}(n,:));
            [~ , p1.stdEndDev{i,ii}(n)] = ttest2(fRate1.lastStd{i,ii}(n,:),fRate1.dev{i,ii}(n,:));
            [~ , p1.stdEndSoundEnd{i,ii}(n)] = ttest(fRate1.lastStd{i,ii}(n,:),fRate1.lastSound{i,ii}(n,:));
        end

    end
end





%% group according to protNames

for protN = 1:length(protName)
    protIdx{protN} = find(contains(savePathAll,protName{protN}));
    popRes.(protName{protN}).stimType = stimTypeAll(protIdx{protN}(1));
    for sP = 1 : length(soundPairs)
    popRes.(protName{protN}).p0.(soundPairs{sP}).data = p0.(soundPairs{sP})(protIdx{protN},:);
    popRes.(protName{protN}).p1.(soundPairs{sP}).data = p1.(soundPairs{sP})(protIdx{protN},:);
  
    end
    
    for soundN = 1 : length(soundSelect)
    popRes.(protName{protN}).fRateMean0.(soundSelect{soundN}) = fRateMean0.(soundSelect{soundN})(protIdx{protN},:);
    popRes.(protName{protN}).fRateMean1.(soundSelect{soundN}) = fRateMean1.(soundSelect{soundN})(protIdx{protN},:);

    end
end


%% plot scatter figure

for protN = 1:length(protName)
    Fig = figure;
    maximizeFig(Fig);
    margins = [0.05;0.05;0.05;0.05];
    stimType = popRes.(protName{protN}).stimType{1};
    for ii = 1 : numel(stimTypeAll{1,1})


        %%  0-50ms
        Axis{1,ii} = mSubplot(Fig,2,numel(stimTypeAll{1}),(1-1)*numel(stimTypeAll{1})+ii,margins);
        plot([0 4.5],[1 1],'LineStyle',':','Color','#AAAAAA','LineWidth',1.5); hold on
        popRes.(protName{protN}).std1Buffer0{ii} = cell2mat(cellfun(@(x) x',popRes.(protName{protN}).fRateMean0.firstStd(:,ii),'UniformOutput',false));
        popRes.(protName{protN}).stdEndBuffer0{ii} = cell2mat(cellfun(@(x) x',popRes.(protName{protN}).fRateMean0.lastStd(:,ii),'UniformOutput',false));
        popRes.(protName{protN}).devBuffer0{ii} = cell2mat(cellfun(@(x) x',popRes.(protName{protN}).fRateMean0.dev(:,ii),'UniformOutput',false));
        popRes.(protName{protN}).soundEndBuffer0{ii} = cell2mat(cellfun(@(x) x',popRes.(protName{protN}).fRateMean0.lastSound(:,ii),'UniformOutput',false));
        
        
        % first std & last std
        for sP = 1 : length(soundPairs)
        switch soundPairs{sP}
            case 'std1StdEnd'
                y0Buffer = popRes.(protName{protN}).stdEndBuffer0{ii}./popRes.(protName{protN}).std1Buffer0{ii};
            case 'stdEndDev'
                 y0Buffer = popRes.(protName{protN}).devBuffer0{ii}./popRes.(protName{protN}).stdEndBuffer0{ii};
            case 'stdEndSoundEnd'
                y0Buffer = popRes.(protName{protN}).soundEndBuffer0{ii}./popRes.(protName{protN}).stdEndBuffer0{ii};
        end
        x0Buffer = ones(length(y0Buffer),1) * sP;
        p0Buffer = cell2mat(cellfun(@(x) x',popRes.(protName{protN}).p0.(soundPairs{sP}).data(:,ii),'UniformOutput',false));
        invalidIdx = (isnan(y0Buffer) | isinf(y0Buffer));  
        validIdx = ~invalidIdx & y0Buffer < mean(y0Buffer(~invalidIdx))+ 3 * std(y0Buffer(~invalidIdx));
        sigIdx = p0Buffer < 0.05 & validIdx;
        fRateSig.(soundPairs{sP}){1,ii} = y0Buffer(sigIdx); fRateValid.(soundPairs{sP}){1,ii} = y0Buffer(validIdx); 
        sigRatio = roundn(sum(p0Buffer < 0.05) / length(p0Buffer(validIdx)),-2);
        popRes.(protName{protN}).p0.(soundPairs{sP}).sigRatio = sigRatio;
        sigMean = mean(y0Buffer(sigIdx));  validMean = mean(y0Buffer(validIdx));
        sc1 = scatter(x0Buffer(sigIdx)-0.1,y0Buffer(sigIdx),10,'red','filled','DisplayName','sigCells'); hold on
        sc2 = scatter(x0Buffer(~sigIdx)+0.1,y0Buffer(~sigIdx),10,'black','DisplayName','noSigCells'); hold on
        plot([0.6 1.4] + sP-1, ones(1,2) * validMean,'LineStyle',':','Color','blue','LineWidth',1.5); hold on
        plot([0.7 1.1] + sP-1, ones(1,2) * sigMean,'LineStyle','-','Color','red','LineWidth',2); hold on
        errorbar(x0Buffer(1)-0.1, sigMean, std(y0Buffer(sigIdx))/sqrt(length(y0Buffer(sigIdx))),'Color','red','CapSize',15);hold on
        errorbar(x0Buffer(1)+0.1, validMean, std(y0Buffer(validIdx))/sqrt(length(y0Buffer(validIdx))),'Color','blue','CapSize',15);hold on
        text(0.8 + sP-1,2.7,[num2str(sigRatio*100) '%']);
        text(0.8 + sP-1,2.8,[num2str(sum(sigIdx)) '\' num2str(sum(validIdx | ~validIdx))]);
        text(0.5 + sP-1,sigMean+0.05,num2str(roundn(sigMean,-2)),'Color','red');
        text(1.3 + sP-1,validMean+0.05,num2str(roundn(validMean,-2)),'Color','blue');
        end


        xlim([0 4.5]);
        ylim([0 3]);
        set(gca,'XTick',[1 2 3]);
        set(gca,'XTickLabel',{'stdEnd/std1','dev/stdEnd','soundEnd/stdEnd'});
        title([stimType{ii} ' [0-50]']);
        legend([sc1 sc2]);
        legend('boxoff');


%% 50-200 ms
        Axis{2,ii} = mSubplot(Fig,2,numel(stimTypeAll{1}),(2-1)*numel(stimTypeAll{1})+ii,margins);
        plot([0 4.5],[1 1],'LineStyle',':','Color','#AAAAAA','LineWidth',1.5); hold on

        popRes.(protName{protN}).std1Buffer1{ii} = cell2mat(cellfun(@(x) x',popRes.(protName{protN}).fRateMean1.firstStd(:,ii),'UniformOutput',false));
        popRes.(protName{protN}).stdEndBuffer1{ii} = cell2mat(cellfun(@(x) x',popRes.(protName{protN}).fRateMean1.lastStd(:,ii),'UniformOutput',false));
        popRes.(protName{protN}).devBuffer1{ii} = cell2mat(cellfun(@(x) x',popRes.(protName{protN}).fRateMean1.dev(:,ii),'UniformOutput',false));
        popRes.(protName{protN}).soundEndBuffer1{ii} = cell2mat(cellfun(@(x) x',popRes.(protName{protN}).fRateMean1.lastSound(:,ii),'UniformOutput',false));


        for sP = 1 : length(soundPairs)
        switch soundPairs{sP}
            case 'std1StdEnd'
                y1Buffer = popRes.(protName{protN}).stdEndBuffer1{ii}./popRes.(protName{protN}).std1Buffer1{ii};
            case 'stdEndDev'
                 y1Buffer = popRes.(protName{protN}).devBuffer1{ii}./popRes.(protName{protN}).stdEndBuffer1{ii};
            case 'stdEndSoundEnd'
                y1Buffer = popRes.(protName{protN}).soundEndBuffer1{ii}./popRes.(protName{protN}).stdEndBuffer1{ii};
        end

        x1Buffer = ones(length(y1Buffer),1) * sP;
        p1Buffer = cell2mat(cellfun(@(x) x',popRes.(protName{protN}).p1.(soundPairs{sP}).data(:,ii),'UniformOutput',false));
        invalidIdx = (isnan(y1Buffer) | isinf(y1Buffer));  
        validIdx = ~invalidIdx & y1Buffer < mean(y1Buffer(~invalidIdx))+ 3 * std(y1Buffer(~invalidIdx));
        sigIdx = p1Buffer < 0.05 & validIdx;
        fRateSig.(soundPairs{sP}){2,ii} = y1Buffer(sigIdx); fRateValid.(soundPairs{sP}){2,ii} = y1Buffer(validIdx); 
        sigRatio = roundn(sum(p1Buffer < 0.05) / length(p1Buffer(validIdx)),-2);
        popRes.(protName{protN}).p1.(soundPairs{sP}).sigRatio = sigRatio;
        sigMean = mean(y1Buffer(sigIdx));  validMean = mean(y1Buffer(validIdx));
        sc1 = scatter(x1Buffer(sigIdx)-0.1,y1Buffer(sigIdx),10,'red','filled','DisplayName','sigCells'); hold on
        sc2 = scatter(x1Buffer(~sigIdx)+0.1,y1Buffer(~sigIdx),10,'black','DisplayName','noSigCells'); hold on
        plot([0.6  1.4] + sP-1, ones(1,2) * validMean,'LineStyle',':','Color','blue','LineWidth',1.5); hold on
        plot([0.7 1.1] + sP-1, ones(1,2) * sigMean,'LineStyle','-','Color','red','LineWidth',2); hold on
        errorbar(x1Buffer(1)-0.1, sigMean, std(y1Buffer(sigIdx))/sqrt(length(y1Buffer(sigIdx))),'Color','red','CapSize',15);hold on
        errorbar(x1Buffer(1)+0.1, validMean, std(y1Buffer(validIdx))/sqrt(length(y1Buffer(validIdx))),'Color','blue','CapSize',15);hold on
        text(0.8 + sP-1,2.7,[num2str(sigRatio*100) '%']);
        text(0.8 + sP-1,2.8,[num2str(sum(sigIdx)) '\' num2str(sum(validIdx | ~validIdx))]);
        text(0.5 + sP-1,sigMean+0.05,num2str(roundn(sigMean,-2)),'Color','red');
        text(1.3 + sP-1,validMean+0.05,num2str(roundn(validMean,-2)),'Color','blue');
        end
        xlim([0 4.5]);
        ylim([0 3]);
        set(gca,'XTick',[1 2 3]);
        set(gca,'XTickLabel',{'stdEnd/std1','dev/stdEnd','soundEnd/stdEnd'});
%         title([ stimType{ii}  ' [50-200]']);
        legend([sc1 sc2]);
        legend('boxoff');
    end

    %% compare reg and irreg
    for sP = 1 : length(soundPairs)
        for pairN = 1 : numel(stimType)/2
        % 0-50 ms sigCells   
        [~ , pRegIrregSig.(soundPairs{sP}).sig(1,pairN)] = ttest2(fRateSig.(soundPairs{sP}){1,2*pairN-1}, fRateSig.(soundPairs{sP}){1,2*pairN});
        % 0-50 ms validCells
        [~ , pRegIrregValid.(soundPairs{sP}).sig(1,pairN)] = ttest2(fRateValid.(soundPairs{sP}){1,2*pairN-1}, fRateValid.(soundPairs{sP}){1,2*pairN});
        
        title(Axis{1,2 * pairN - 1},[ stimType{ii}  ' [0-50], p-RegIrregValid = ' num2str(pRegIrregValid.(soundPairs{sP}).sig(1,pairN)) ]);
        title(Axis{1,2 * pairN},[ stimType{ii}  ' [0-50], p-RegIrregSig = ' num2str(pRegIrregSig.(soundPairs{sP}).sig(1,pairN)) ]);


        % 50-200 ms sigCells
        [~ , pRegIrregSig.(soundPairs{sP}).sig(2,pairN)] = ttest2(fRateSig.(soundPairs{sP}){2,2*pairN-1}, fRateSig.(soundPairs{sP}){2,2*pairN});
        % 50-200 ms validCells
        [~ , pRegIrregValid.(soundPairs{sP}).sig(2,pairN)] = ttest2(fRateValid.(soundPairs{sP}){2,2*pairN-1}, fRateValid.(soundPairs{sP}){2,2*pairN});
        
        title(Axis{2,2 * pairN - 1},[ stimType{ii}  ' [50-200], p-RegIrregValid = ' num2str(pRegIrregValid.(soundPairs{sP}).sig(2,pairN)) ]);
        title(Axis{2,2 * pairN},[ stimType{ii}  ' [50-200], p-RegIrregSig = ' num2str(pRegIrregSig.(soundPairs{sP}).sig(2,pairN)) ]);
        end
    end



    %% save figure
    saveas(Fig,[fullfile(savePath,protName{protN}) '.jpg']);
    close(Fig);
end

end


%
%
