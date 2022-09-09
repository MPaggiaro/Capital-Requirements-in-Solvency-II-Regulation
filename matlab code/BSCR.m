function [assets, liabs, BOF, dBOF, duration] = SCR(data, base)


%% Compute assets values
t =(0:data.T)';
[B,S] = AssetValue(data.B0,data.N,data.S0,data.r,data.T,t,data.sigma,data.M);
F = B+S;
assets = F(1);

%% Liabilities & duration:

[liabs,duration] = liabilities(data.T,data.x,data.r,data.fee_rate,data.lapse,data.q,data.l,F);

%% BOF:
BOF = assets - liabs;

%% dBOF:
if base == 0
    dBOF = 0;
else
    dBOF = BOF - base;
end

end