function BSCR = basiccapital(capitalRequirements,flagCase)
% Computes the Basic Solvency Capital Requirements with the correlation
% tables provided by the regulation of Solvency II.
%
% INPUT:
%  - SCR: struct containing the solvency capital requirements associated to
%         the risks of interest.
% 
% OUTPUT:
%  - BSCR.
%

%% Correlation Matrices:

% Market correlations:
if flagCase==1
mktCorr = [1, 0, 0;...
           0, 1, 0.75;...
           0, 0.75, 1];
else
    mktCorr = [1, 0.5, 0.5;...
               0.5, 1, 0.75;...
               0.5, 0.75, 1];
end

% Life correlations:
lifeCorr = mktCorr;
lifeCorr(1,2) = 0;
lifeCorr(2,1) = 0;

% Global correlations:
globalCorr = [1, 0.25; 0.25, 1];

%% Computations:
mktVector = [capitalRequirements.ir; capitalRequirements.equity; capitalRequirements.spread];
lifeVector = [capitalRequirements.mortality ; capitalRequirements.lapse; capitalRequirements.cat];

mktSCR = sqrt(dot(mktVector,mktCorr*mktVector));
lifeSCR = sqrt(dot(lifeVector, lifeCorr*lifeVector));

globalSCR = [mktSCR; lifeSCR];

BSCR = sqrt(dot(globalSCR, globalCorr*globalSCR));

end