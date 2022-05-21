function S1 = UpdateStruct(S1,S2,OverlapField)
FieldS1 = fields(S1);
FieldS2 = fields(S2);
LengthS1 = length(S1);
LengthS2 = length(S2);
%% If true, add new field to S1
count = 0;
for j = 1:LengthS2
    if ~isempty(find(strcmp({S1.(OverlapField)},S2(j).(OverlapField)))) %whether the field "OverlapField" in S1 contains save element in S2  
        Ind = find(strcmp({S1.(OverlapField)},S2(j).(OverlapField)));% if true,get the index of S1
    for i = 1:length(FieldS2)   % if the element in S2 is not null (means new value in S2), evalue it to S1
        if ~isempty(S2(j).(FieldS2{i}))
        S1(Ind).(FieldS2{i}) = S2(j).(FieldS2{i});
        end
    end
    else % the element is not in S1
        count = count+1;
        for i = 1:length(FieldS2)
        S1(LengthS1+count).(FieldS2{i}) = S2(j).(FieldS2{i});
        end
    end
end
end