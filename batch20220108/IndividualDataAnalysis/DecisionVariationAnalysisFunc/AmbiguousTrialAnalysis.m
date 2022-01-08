function varargout = AmbiguousTrialAnalysis(AmbiguousTrials,varargin)
for i = 1:2:length(varargin)
    eval([ varargin{i} '=varargin{i+1};']);
end

buffer = AmbiguousTrials;
switch method
    case 'prior'
        TrialClasses.PriorCorrectResPush = buffer(strcmp({buffer.PriorRes},'Correct')&strcmp({buffer.Behav},'Push'));
        TrialClasses.PriorCorrectResNoPush = buffer(strcmp({buffer.PriorRes},'Correct')&strcmp({buffer.Behav},'NoPush'));
        TrialClasses.PriorWrongResPush = buffer(strcmp({buffer.PriorRes},'Wrong')&strcmp({buffer.Behav},'Push'));
        TrialClasses.PriorWrongResNoPush = buffer(strcmp({buffer.PriorRes},'Wrong')&strcmp({buffer.Behav},'NoPush'));
        PriorCorrectRes(2,1) = size(TrialClasses.PriorCorrectResPush,1);
        PriorCorrectRes(3,1) = sum(size([TrialClasses.PriorCorrectResPush;TrialClasses.PriorCorrectResNoPush],1));
        PriorCorrectRes(1,1) = PriorCorrectRes(2)/PriorCorrectRes(3);
        PriorWrongRes(2,1) = size(TrialClasses.PriorWrongResPush,1);
        PriorWrongRes(3,1) = sum(size([TrialClasses.PriorWrongResPush;TrialClasses.PriorWrongResNoPush],1));
        PriorWrongRes(1,1) = PriorWrongRes(2)/PriorWrongRes(3);

        try TrialClassesAll.PriorCorrectResPush;
            TrialClassesAll.PriorCorrectResPush = [TrialClassesAll.PriorCorrectResPush;TrialClasses.PriorCorrectResPush];
            TrialClassesAll.PriorCorrectResNoPush = [TrialClassesAll.PriorCorrectResNoPush;TrialClasses.PriorCorrectResNoPush];
            TrialClassesAll.PriorWrongResPush = [TrialClassesAll.PriorWrongResPush;TrialClasses.PriorWrongResPush];
            TrialClassesAll.PriorWrongResNoPush = [TrialClassesAll.PriorWrongResNoPush;TrialClasses.PriorWrongResNoPush];
        catch
            TrialClassesAll = TrialClasses;
        end


        varargout{1} = PriorCorrectRes;
        varargout{2} = PriorWrongRes;
        varargout{3} = TrialClassesAll;
        varargout{4} = TrialClasses;
    case 'stdnum'
        for n = unique([buffer.StdNum])
            TrialClasses.(['Stdnum' num2str(n) 'ResPush']) = buffer([buffer.StdNum]==n&strcmp({buffer.Behav},'Push'));
            TrialClasses.(['Stdnum' num2str(n) 'ResNoPush']) = buffer([buffer.StdNum]==n&strcmp({buffer.Behav},'NoPush'));
            StdnumRes.(['std' num2str(n)])(2,1) = size(TrialClasses.(['Stdnum' num2str(n) 'ResPush']),1);
            StdnumRes.(['std' num2str(n)])(3,1) = sum([size(TrialClasses.(['Stdnum' num2str(n) 'ResPush']),1),size(TrialClasses.(['Stdnum' num2str(n) 'ResNoPush']),1)]);
            StdnumRes.(['std' num2str(n)])(1,1) = StdnumRes.(['std' num2str(n)])(2)/StdnumRes.(['std' num2str(n)])(3);
        
        try TrialClassesAll.(['Stdnum' num2str(n) 'ResPush']);
            TrialClassesAll.(['Stdnum' num2str(n) 'ResPush']) = [TrialClassesAll.(['Stdnum' num2str(n) 'ResPush']);TrialClasses.(['Stdnum' num2str(n) 'ResPush'])];
            TrialClassesAll.(['Stdnum' num2str(n) 'ResNoPush']) = [TrialClassesAll.(['Stdnum' num2str(n) 'ResNoPush']);TrialClasses.(['Stdnum' num2str(n) 'ResNoPush'])];
        catch
            TrialClassesAll = TrialClasses;
        end
        end
        varargout{1} = StdnumRes;
        varargout{2} = TrialClassesAll;
        varargout{3} = TrialClasses;
end

end



