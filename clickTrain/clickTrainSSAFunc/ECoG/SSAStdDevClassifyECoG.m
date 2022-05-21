function batchOpt = SSAStdDevClassifyECoG(batchOpt)
eval([GetStructStr(batchOpt) '=ReadStructValue(batchOpt);']);
    
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
                asStd(stdN).lfpData{m,n} = changeCellRowNum({stimPara(asStd(stdN).Idx{m,n}).lfpData}')'; 
                
            end

            asDev.Idx{m,n} = find([stimPara.order]' == SSAPairs(m,n) & ismember([stimPara.nToDev]',0));
            asDev.lfpData{m,n} = changeCellRowNum({stimPara(asDev.Idx{m,n}).lfpData}')'; 

        end
    end
    
    %% save results
    rez.asStd = asStd;
    rez.asDev = asDev;
    batchOpt.stdEnd = stdEnd; batchOpt.stdOrder = stdOrder; batchOpt.soundOrder = soundOrder; % sound indexes
    batchOpt.rez = rez; % asStd & asDev
end