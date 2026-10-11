%% 0. PRELIMINARIES
%-------------------------------------------------------------------------- 
clear all; clear session; close all; clc
warning off all


% 1. Load data
[data, vnames] = xlsread('data/Yearly_1981_2019_final.xlsx','data','E1:BL508');

date = 1981:2019;
nvar = length(vnames);
nstate = 13;
nobs = size(data,1)/nstate;

% Store variables in the structure DATA
for jj=1:nstate
    for ii=1:length(vnames)
        DATA(jj).(vnames{ii}) = data((jj-1)*nobs+1:jj*nobs,ii);
    end
end

%{

% 'pop'	'emp'	'avh'	'hc'	'rgdpna'	'rconna'	'rdana'	'rnna'	'rkna'	'rtfpna'	'irr'	'xr'	'pl_c'	'pl_i'	'pl_g'	'pl_x'	'pl_m'	'pl_n'	'pl_k'	
% 'hcpi_a'	'ccpi_a'	'fcpi_a'	'ecpi_a'	'ppi_a'	'def_a'	'ip'	'empn'	'xr_ifs'	'xport'	'mport'	'ir_deposit'	'ir_lending'	'uempr_ifs'	'uempn'	'empr'	'uempr'	'ep'	
% 'cei'	'cei_hot'	'cei_cold'	'cei_prep'	'cei_wind'	'cei_drought'	'max_hot'	'max_cold'	'max_drought'	'max_prep'	'max_wind'	'max_AECI'	'mean_hot'	'mean_cold'	'mean_drought'	'mean_prep'	'mean_wind'	'mean_AECI'	
% 'vix'	'totcom'	'energy'	'agri'	'us_rgdpna'

% Transform selected variables
%temptreat = {'logdiff','diff','rate'};
%tempscale = [100,100,1];
tempnames = {'hcpi_m','ccpi_m','fcpi_m','ecpi_m','ppi_m','ep','ip','xr','xport','mport','tbal','vix','totcom','energy','agri','usip'};
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


tempnames = {'ir_deposit','ir_lending','uempr','xportshare'};
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

%}