%% 0. PRELIMINARIES
%-------------------------------------------------------------------------- 
clear all; clear session; close all; clc
warning off all


% 1. Load data
[data, vnames] = xlsread('data/data_Monthly_1981_2022_final.xlsx','data','D1:AC7057');

date = 1981:1/12:2022+11/12;
date = date';
nvar = length(vnames);
nstate = 14;
nobs = size(data,1)/nstate;

% Store variables in the structure DATA
for jj=1:nstate
    for ii=1:length(vnames)
        DATA(jj).(vnames{ii}) = data((jj-1)*nobs+1:jj*nobs,ii);
    end
end

% Create two more variables; interest rate spread, trade balance
for jj=1:nstate 
        DATA(jj).ir_spread = DATA(jj).ir_lending - DATA(jj).ir_deposit;
        DATA(jj).tbal = DATA(jj).xport - DATA(jj).mport;
end

% {'hcpi_m','ccpi_m','fcpi_m','ecpi_m','ppi_m','ep','ip','empn','xr','xport','mport','ir_deposit','ir_lending','uempr','uempn'}
% {'hot','cold','drought','prep','wind','AECI'}
% {'vix','totcom','energy','agri','usip'}



% Transform selected variables
%temptreat = {'logdiff','diff','rate'};
%tempscale = [100,100,1];

tempnames = {'hcpi_m','ccpi_m','fcpi_m','ecpi_m','ppi_m','ep','ip','xr','xport','mport','vix','totcom','energy','agri','usip', 'tbal'};
for jj=1:nstate
    for ii=1:length(tempnames)
        aux = {['d' tempnames{ii}]};
        DATA(jj).(aux{1}) = 1200*XoX(DATA(jj).(tempnames{ii}),1,'rate'); % annualized growth rate
    end
end

for jj=1:nstate
    for ii=1:length(tempnames)
        aux = {['d12' tempnames{ii}]};
        DATA(jj).(aux{1}) = 100*XoX(DATA(jj).(tempnames{ii}),12,'rate'); % annualized growth rate
    end
end

DATA(14).dip = nan(size(DATA(14).dip)); % HKG ip series already came in YoY.
DATA(14).d12ip = DATA(14).ip;

% Create new variables: adjustment speed in trade balance
for jj=1:nstate 
    DATA(jj).dtbaladj = DATA(jj).dxport - DATA(jj).dmport;    
    DATA(jj).d12tbaladj = DATA(jj).d12xport - DATA(jj).d12mport;
end


tempnames = {'ir_deposit','ir_lending','uempr','ir_spread'};
for jj=1:nstate
    for ii=1:length(tempnames)
        aux = {['d' tempnames{ii}]};
        DATA(jj).(aux{1}) = XoX(DATA(jj).(tempnames{ii}),1,'diff');
    end
end

for jj=1:nstate
    for ii=1:length(tempnames)
        aux = {['d12' tempnames{ii}]};
        DATA(jj).(aux{1}) = XoX(DATA(jj).(tempnames{ii}),12,'diff');
    end
end


tempnames = {'hot','cold','drought','prep','wind','AECI'};
for jj=1:nstate 
    for ii=1:length(tempnames)
        aux = {['mv12' tempnames{ii}]};
        DATA(jj).(aux{1}) = MovAvg(DATA(jj).(tempnames{ii}),12);
    end
end
