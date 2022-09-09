% Run of the assignment.

clear all
close all
clc

%% Read datas from the excel sheet:
r = xlsread('Final_Project_data_20181231.xlsx','c4:c18');
r_up = xlsread('Final_Project_data_20181231.xlsx','d4:d18');
r_down = xlsread('Final_Project_data_20181231.xlsx','e4:e18');

qMen = xlsread('Final_Project_data_20181231.xlsx','i3:i112');
qWomen = xlsread('Final_Project_data_20181231.xlsx','m3:m114');

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

%% Random simulation for computing S:
P = 100000; % numero di montecarlo 
M = 100;  % numero di step considerati

g = randn(P,M);

%% Flag to choose the case A or B
flagCase = 1; % case A if flag = 1 
              % case B    otherwise
%% Basic case
dataMan = struct('T',T,'r',R,'N',1000,'S0',200,'s',s,'sigma',0.2,...
              'x',60, 'feeRate', 0.015, 'lapseRate', 0.05,'q',qMen);

dataWoman = struct('T',T,'r',R,'N',1000,'S0',200,'s',s,'sigma',0.2,...
              'x',60, 'feeRate', 0.015, 'lapseRate', 0.05,'q',qWomen);
          
base = 0;

%% Choose the age interval 
N = 15;
age = dataMan.x+1:dataMan.x+N;

%% Compute the liabilities 
manLiabilities = zeros(N,1);
womanLiabilities = zeros(N,1);
manDuration = zeros(N,1);
womanDuration = zeros(N,1);


for i = 1:N
    dataMan.x = dataMan.x + 1;
    dataWoman.x = dataWoman.x + 1;
    manSCR = SCR(dataMan,base,g,flagCase);
    womanSCR = SCR(dataWoman, base, g, flagCase);
    
    manLiabilities(i) = manSCR.liabs;
    womanLiabilities(i) = womanSCR.liabs;
    manDuration(i) = manSCR.duration;
    womanDuration(i) = womanSCR.duration;

end

%% Plot
figure
plot(age,manLiabilities,'o-', age, womanLiabilities,'o-')
legend ('male insured','female insured')
grid on
xlabel('age of the insured')
ylabel('liabilities')
xlim([61, 75])

figure
plot(age,manDuration,'o-', age, womanDuration,'o-')
legend ('male insured','female insured')
grid on
xlabel('age of the insured')
ylabel('Duration')
xlim([61, 75])
