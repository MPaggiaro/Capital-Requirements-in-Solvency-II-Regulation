% Run of the assignment.

clear all
close all
clc

%% Read datas from the excel sheet:
r = xlsread('Final_Project_data_20181231.xlsx','c4:c18');
r_up = xlsread('Final_Project_data_20181231.xlsx','d4:d18');
r_down = xlsread('Final_Project_data_20181231.xlsx','e4:e18');

q = xlsread('Final_Project_data_20181231.xlsx','i3:i112');

%% data
T = 10;
N=1000;
B0=800;

%% Changing annual to continuous compounding:
R = log(1+r(1:T));
R_up = log(1+r_up(1:T));
R_down = log(1+r_down(1:T));

% spread:
s = 1/T*(log(N/B0))- R(10);

data = struct('T',T,'r',R,'N',1000,'S0',200,'s',s,'sigma',0.2,...
              'x',60, 'feeRate', 0.015, 'lapseRate', 0.05,'q',q);

%% Random simulation for computing S:
M = 100000; % number of MC simulation
P = 100;  % number of time step

g = randn(M,P); % std.n matrix

%% Flag to choose the case A or B
flagCase = 1; % case A: if flag = 1 
              % case B:   otherwise
%% Basic case:
base = 0;
basic = SCR(data, base,g,flagCase);

%% a) Market interest: up & down
BOF_base = basic.BOF;
data.r = R_up; 
IRup = SCR(data, BOF_base,g,flagCase);

data.r = R_down;
IRdown = SCR(data, BOF_base,g,flagCase);

capitalRequirements.ir = max(IRup.dBOF,IRdown.dBOF);
%% b) Market Equity
data.r = R;

data.S0 = data.S0*(1-0.39);
equity = SCR(data, BOF_base,g,flagCase);

capitalRequirements.equity = max(equity.dBOF,0);
%% c) Market spread

data.S0 = 200;
MV_bond = B0*(1 - (0.045+0.005*(10-5)));
data.s = 1/T*(log(N/MV_bond))- R(10);

spread = SCR(data, BOF_base,g,flagCase);

capitalRequirements.spread = max(spread.dBOF,0);

%% d) Mortality risk
data.s = 1/T*(log(N/B0))- R(10);
data.q = data.q*(1.15);
mortality = SCR(data, BOF_base,g,flagCase);

capitalRequirements.mortality = max(mortality.dBOF,0);

%% e) Lapse risk
data.q = data.q/(1.15); 

data.lapseRate = data.lapseRate * (1.5);
lapseUp = SCR(data, BOF_base,g,flagCase);

data.lapseRate = 0.05*(0.5);
lapseDown = SCR(data, BOF_base,g,flagCase);

data.lapseRate = -1; %Flag for the case 'lapse mass':

%lapse apply at the first year
lapseMass = SCR(data, BOF_base,g,flagCase);

capitalRequirements.lapse = max([lapseUp.dBOF,lapseDown.dBOF,lapseMass.dBOF,0]);
%% f) Cat risk

data.lapseRate = 0.05;
data.q(data.x+2) = data.q(data.x+2) + 0.0015;

CAT = SCR(data, BOF_base,g,flagCase);

capitalRequirements.cat = max(CAT.dBOF,0);

%% Basic Solvency Capital Requirements:

BSCR = basiccapital(capitalRequirements,flagCase);
