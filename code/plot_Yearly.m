load_Yearly
close all

outdir = 'output/Yearly';

countryid = 12;

%{
Xvnames = {'d12ip','d12hcpi_m','d12ccpi_m','d12fcpi_m','d12ecpi_m','d12ppi_m','d12uempr','d12ir_lending','d12xr','d12ep'};
Xvnames_long = {'Output Growth','CPI Inflation','Core CPI Inflation','Food CPI Inflation','Energy CPI Inflation','PPI Inflation',...
        'Unemployment Change','Interest Rate Change','Exchange Rate Change','Stock Returns'};
Xnvar = length(Xvnames);

% Create matrices of variables to be used in the VAR
X = nan(nobs,Xnvar);
for ii=1:Xnvar
    X(:,ii) = DATA(countryid).(Xvnames{ii});
end

% Open a figure of the desired size and plot the selected series
FigSize(30,18)
for ii=1:Xnvar
    subplot(2,5,ii)
    H(ii) = plot(X(:,ii),'LineWidth',1,'Color',cmap(1));
    title(Xvnames_long(ii));
    DatesPlot(date(1),nobs,6,'m')
    grid on; 
end
% Save figure
strA=[outdir '/figures/id_' num2str(countryid) '_econ'];
SaveFigure(strA,1,'png')
%}

%% Plot weather and climate data

Xvnames = {'cei','cei_hot','cei_cold','cei_drought','cei_prep','cei_wind'};
Xvnames_long = {'Climate Index (CEI)','Heat Stress','Cold Stress','Drought',...
        'Precipitation','Wind Speed'};
Xnvar = length(Xvnames);

X = nan(nobs,Xnvar);
MX = nan(nobs,Xnvar);
for ii=1:Xnvar
    X(:,ii) = DATA(countryid).(Xvnames{ii});
    MX(:,ii) = movmean(DATA(countryid).(Xvnames{ii}),15, "omitnan"); % A 15-year moving average
end

% Plot time series
figure('name','Weather and Climate: Trend')
FigSize(30,18)
for ii=1:Xnvar
    subplot(2,3,ii)
    H(ii) = plot(X(:,ii),'LineWidth',1,'Color',cmap(1));
    hold on
    MH(ii) = plot(MX(:,ii),'LineWidth',2,'Color',cmap(2));
        xlim([1981 2020]);
    title(Xvnames_long(ii));
    DatesPlot(date(1),nobs+1,5,'y')
    grid on; 
end

strA=[outdir '/figures/id_' num2str(countryid) '_cei_trend'];
SaveFigure(strA,1,'png')


% Plot histogram
figure('name','Weather and Climate: Distribution')
FigSize(30,18)
for ii=1:Xnvar
    subplot(2,3,ii)
    histogram(X(:,ii), 10 ,'Normalization','probability')
    title(Xvnames_long(ii));
end

strA=[outdir '/figures/id_' num2str(countryid) '_cei_hist'];
SaveFigure(strA,1,'png')

