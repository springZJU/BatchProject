function [hist,resArray] = histcInd(A,edge)
         histRes = histcounts(A,edge);
         histBin = edge(1:end-1)+(edge(2)-edge(1))/2;
         for edgeN = 1:length(edge)-1
             idx = find(A>=edge(edgeN) & A<edge(edgeN+1));
             histInd(idx) = edgeN;
         end
         hist(1,:) = histRes;
         hist(2,:) = histBin;
         resArray(1,:) = A;
         resArray(2,:) = histInd;

end