function res = mstruct2cell(Struct)
    field = fields(Struct);
    res = cell(length(Struct),length(field));
    for m = 1:length(Struct) % row
        for n = 1:length(field) % fields
            res{m,n} = Struct(m).(field{n});
        end
    end
end
