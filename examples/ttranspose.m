function [tableTransposed] = transposeTable(tableIn)
%this function transposes a table. 
props =tableIn.Properties.VariableNames;

tableTransposed = table();
tableSz = size(tableIn);
tableTransposed.metricName = props';
tableTransposed(1,:) = [];
for newPropertyNum = 1:tableSz(1)
    propCurr = table2array(tableIn(newPropertyNum,1));
    if isa(propCurr,'numeric')
        newProperty = num2str( propCurr );
    else %assumed to be string
        newProperty = propCurr;

    end
    tableTransposed = setfield(tableTransposed,newProperty,table2array(tableIn(newPropertyNum,2:end))');
end