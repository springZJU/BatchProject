function firingrate = FRcal(spikeBuffer,win)
    for winN = 1:size(win,1)
        firingrate.(['FRwin' num2str(win(winN,1)) '_' num2str(win(winN,2))]) = histcounts(spikeBuffer,win(winN,:))*1000/(win(winN,2)-win(winN,1));
    end
end
    
