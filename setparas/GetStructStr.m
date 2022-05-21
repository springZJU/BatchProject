function Str=GetStructStr(Struct)
Varnames=fieldnames(Struct);
Str='[';
for i=1:length(Varnames)
    Str=[Str ' ' Varnames{i}];
end
Str=[Str ']'];
end
