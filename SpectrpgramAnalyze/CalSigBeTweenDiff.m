function p=CalSigBeTweenDiff(SampleData,Diff,varargin)


    [m,n]=size(SampleData{Diff(1)});
    p=ones(m,n);
    if ~isempty(p)
    try ROI=varargin{1};
        Columnrange=ROI{1}; %time range
        Rowrange=ROI{2}; %frequency range
    catch

        Columnrange=1:n; %time range
        Rowrange=1:m; %frequency range
    end
hh=waitbar(0,'please wait');
count=0;
tic
countall=length(Columnrange)*length(Rowrange);
    for SampleRow=Rowrange
        for SampleCol=Columnrange
            count=count+1;
            Cval{SampleRow,SampleCol}=[];
            
            for dev_diff=Diff
                bufferdata=SampleData{1,dev_diff}{SampleRow,SampleCol};
                bufferlabel=ones(size(bufferdata))*dev_diff;
                buffer=[bufferdata bufferlabel];
                Cval{SampleRow,SampleCol}= [Cval{SampleRow,SampleCol};buffer];
            end
            p(SampleRow,SampleCol) = anova1(Cval{SampleRow,SampleCol}(:,1),Cval{SampleRow,SampleCol}(:,2),'off');
        t=toc;
            str=['Calculating p value,runing' num2str(roundn(t,-1)), 's(' ,num2str(roundn(count/countall*100,-1)),'%)'  ',remain', num2str(roundn(t/count*(countall-count),-1)) 's'  ];
        
        waitbar(count/countall,hh,str)
        end
    end
    delete(hh);
    end



