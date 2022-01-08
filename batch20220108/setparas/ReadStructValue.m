function varargout=ReadStructValue(Struct)
Varnames=fieldnames(Struct);
for i=1:length(Varnames)
    varargout{i}=Struct.(Varnames{i});
end
end 