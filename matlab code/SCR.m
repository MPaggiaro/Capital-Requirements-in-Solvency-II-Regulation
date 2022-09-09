function policyData = SCR(data, base,g,flagCase)

%% Compute assets values
[policyData.assets,C] = assetvalue(data,g,flagCase);

%% Liabilities & duration:

[policyData.liabs,policyData.duration] = liabilities(data,C);

%% BOF:
policyData.BOF = policyData.assets - policyData.liabs;

%% dBOF:
if base == 0
    policyData.dBOF = 0;
else
    policyData.dBOF = base - policyData.BOF;
end

end