function batchOpt = SSAStdDevClassifySpike(batchOpt)
eval([GetStructStr(batchOpt) '=ReadStructValue(batchOpt);']);
%% spikeSort To PSTH
    opt.binsize = 20; % ms
    opt.binstep = 5; % ms
    
    %% category trials by order and sound number
    [M,N] = size(SSAPairs);
    
    stdOrder = sort(unique([stimPara.nToDev]));
    if contains(savePath,'LongTerm')
        stdOrder = 1;
    else
        stdOrder = stdOrder(stdOrder>0); % the standard sound indexes
    end
    stdEnd = max(stdOrder); % the last standard
    soundOrder = sort(unique([stimPara.soundNum])); % in a block, no matter std or dev is the same or not
    for m = 1:M
        for n = 1:N
            for stdN = soundOrder
                asStd(stdN).Idx{m,n} = find([stimPara.stdOrder]' == SSAPairs(m,n) & ismember([stimPara.soundNum]',stdN));
                asStd(stdN).fRate{m,n} = [stimPara(asStd(stdN).Idx{m,n}).fRate]; % 0-50 ms firing rate
                asStd(stdN).fRate0{m,n} = [stimPara(asStd(stdN).Idx{m,n}).fRate0]; % 0-50 ms firing rate
                asStd(stdN).fRate1{m,n} = [stimPara(asStd(stdN).Idx{m,n}).fRate1]; % 50-200 ms firing rate
                asStd(stdN).lfpData{m,n} = changeCellRowNum({stimPara(asStd(stdN).Idx{m,n}).lfpData}')'; 
                
                for ch = 1:size(asStd(stdN).fRate1{m,n},1)
                    spikeBuffer = cellfun(@(x) [x{ch}*1000 ones(length(x{ch}),1)]  ,{stimPara(asStd(stdN).Idx{m,n}).Spikesort}','UniformOutput',false);
                    for nTrial = 1:length(spikeBuffer)
                        if ~isempty(spikeBuffer{nTrial})
                            spikeBuffer{nTrial}(:,2) = spikeBuffer{nTrial}(:,2) * nTrial;
                        end
                    end
                    asStd(stdN).rasterBySound{m,n}{ch,1} = cell2mat(spikeBuffer);
                    rasterBuffer = cell2mat(spikeBuffer);
                    if ~isempty(rasterBuffer)
                        asStd(stdN).PSTHBySound{m,n}{ch,1} = calPsth(rasterBuffer(:,1),opt,1000,'EDGE',[0 ISI]*1000,'nTrial',length(unique(rasterBuffer(:,2))));
                    else
                        asStd(stdN).PSTHBySound{m,n}{ch,1} = calPsth(-1,opt,1000,'EDGE',[0 ISI]*1000,'nTrial',1);
                    end
                end

                asStd(stdN).psth{m,n}{ch,1} = cell2mat(spikeBuffer);
                asStd(stdN).fRateMean1{m,n} = mean(asStd(stdN).fRate1{m,n},2);
                asStd(stdN).fRateMean0{m,n} = mean(asStd(stdN).fRate0{m,n},2);
                asStd(stdN).fRateMean{m,n} = mean(asStd(stdN).fRate{m,n},2);
                asStd(stdN).fRateSE{m,n} = std(asStd(stdN).fRate{m,n},1,2)/sqrt(size(asStd(stdN).fRate{m,n},2));
                asStd(stdN).fRateSE0{m,n} = std(asStd(stdN).fRate0{m,n},1,2)/sqrt(size(asStd(stdN).fRate0{m,n},2));
                asStd(stdN).fRateSE1{m,n} = std(asStd(stdN).fRate1{m,n},1,2)/sqrt(size(asStd(stdN).fRate1{m,n},2));
            end

            asDev.Idx{m,n} = find([stimPara.order]' == SSAPairs(m,n) & ismember([stimPara.nToDev]',0));
            asDev.fRate{m,n} = [stimPara(asDev.Idx{m,n}).fRate];
            asDev.fRate0{m,n} = [stimPara(asDev.Idx{m,n}).fRate0];
            asDev.fRate1{m,n} = [stimPara(asDev.Idx{m,n}).fRate1];
            asDev.lfpData{m,n} = changeCellRowNum({stimPara(asDev.Idx{m,n}).lfpData}')'; 
            for ch = 1:size(asDev.fRate1{m,n},1)
                spikeBuffer = cellfun(@(x) [x{ch}*1000 ones(length(x{ch}),1)]  ,{stimPara(asDev.Idx{m,n}).Spikesort}','UniformOutput',false);
                for nTrial = 1:length(spikeBuffer)
                    if ~isempty(spikeBuffer{nTrial})
                        spikeBuffer{nTrial}(:,2) = spikeBuffer{nTrial}(:,2) * nTrial;
                    end
                end
                asDev.rasterBySound{m,n}{ch,1} = cell2mat(spikeBuffer);
                rasterBuffer = cell2mat(spikeBuffer);
                if ~isempty(rasterBuffer)
                    asDev.PSTHBySound{m,n}{ch,1} = calPsth(rasterBuffer(:,1),opt,1000,'EDGE',[0 ISI]*1000,'nTrial',length(unique(rasterBuffer(:,2))));
                else
                    asDev.PSTHBySound{m,n}{ch,1} = calPsth(-1,opt,1000,'EDGE',[0 ISI]*1000,'nTrial',1);
                end
                [~,tP0{m,n}(ch,1)] =  ttest2(asStd(1).fRate1{m,n}(ch,:),asDev.fRate1{m,n}(ch,:));
                [~,tP{m,n}(ch,1)] =  ttest2(asStd(stdEnd).fRate1{m,n}(ch,:),asDev.fRate1{m,n}(ch,:));
                [~,t0P0{m,n}(ch,1)] =  ttest2(asStd(1).fRate0{m,n}(ch,:),asDev.fRate0{m,n}(ch,:));
                [~,t0P{m,n}(ch,1)] =  ttest2(asStd(stdEnd).fRate0{m,n}(ch,:),asDev.fRate0{m,n}(ch,:));

            end
            asDev.fRateMean{m,n} = mean(asDev.fRate{m,n},2);
            asDev.fRateSE{m,n} = std(asDev.fRate{m,n},1,2)/sqrt(size(asDev.fRate{m,n},2));
            asDev.fRateMean1{m,n} = mean(asDev.fRate1{m,n},2);
            asDev.fRateSE1{m,n} = std(asDev.fRate1{m,n},1,2)/sqrt(size(asDev.fRate1{m,n},2));
            asDev.fRateMean0{m,n} = mean(asDev.fRate0{m,n},2);
            asDev.fRateSE0{m,n} = std(asDev.fRate0{m,n},1,2)/sqrt(size(asDev.fRate0{m,n},2));

        end
    end
    
    %% save results
    rez.asStd = asStd;
    rez.asDev = asDev;

    batchOpt.tP0 = tP0;  batchOpt.tP = tP;  batchOpt.t0P0 = t0P0; batchOpt.t0P = t0P;  % p values of ttest2 between same sound as dev and last std seperately
    batchOpt.stdEnd = stdEnd; batchOpt.stdOrder = stdOrder; batchOpt.soundOrder = soundOrder; % sound indexes
    batchOpt.rez = rez; % asStd & asDev
end