load_Monthly; % call first

close all

outdir = 'output/Monthly';

countrynames = {'Bruei','Cambodia','Indonesia','Lao','Malaysia','Myanmar','Philippines','Singapore','Thailand','Vietnam','China','Japan','Korea','Hong Kong'};

nobsf = nobs + 10;

%% Economic variables
    Xvnames = {'d12hcpi_m','d12ccpi_m','d12fcpi_m','d12ecpi_m','d12ppi_m','d12uempr','d12xport','d12mport','d12tbaladj','ir_deposit','ir_lending','ir_spread',...
            'd12ir_deposit','d12ir_lending','d12ir_spread','d12ip','d12xr','d12ep'};
    Xvnames_long = {'CPI Inflation','Core CPI Inflation','Food CPI Inflation','Energy CPI Inflation','PPI Inflation',...
            'Unemployment Change','Export Growth','Import Growth','Trade Balance Adjustment','Deposit Rates', 'Lending Rates','Interest Rate Spread',...
            'Deposit Rate Change', 'Lending Rate Change','Interest Spread Change', 'Output (IP) Growth','Exchange Rate Change','Stock Returns'};
    Xnvar = length(Xvnames);

for kk = 1:nstate

    countryid = kk;
    
    X = nan(nobs,Xnvar);
    for ii=1:Xnvar
        X(:,ii) = DATA(countryid).(Xvnames{ii});
    end
    
    % Open a figure of the desired size and plot the selected series
    FigSize(20,24)
    for ii=1:Xnvar
        subplot(6,3,ii)
        H(ii) = plot(X(:,ii),'LineWidth',1,'Color',cmap(1));
        title(Xvnames_long(ii));
        DatesPlot(date(1),nobsf,11,'m')
        grid on;
    end
    sgtitle(countrynames(kk),'Color',cmap(1),'FontSize',18);

    % Save figure
    strA=[outdir '/figures/id_' num2str(countryid) '_econ'];
    SaveFigure(strA,1,'png')

end

%% Plot weather and climate data

% Climate variables
    Xvnames = {'AECI','hot','cold','drought','prep','wind'};
    Xvnames_long = {'Climate Index (AECI)','Heat Stress','Cold Stress','Drought',...
            'Precipitation','Wind Speed'};
    Xnvar = length(Xvnames);


% Plot time series

for kk = 1:nstate

    countryid = kk;

    X = nan(nobs,Xnvar);
    MX = nan(nobs,Xnvar);
    for ii=1:Xnvar
        X(:,ii) = DATA(countryid).(Xvnames{ii});
        MX(:,ii) = movmean(DATA(countryid).(Xvnames{ii}),12*10+1, "omitnan");
    end
        
    %figure('name','Weather and Climate: Trend')
    FigSize(20,11)
    for ii=1:Xnvar
        subplot(2,3,ii)
        H(ii) = plot(X(:,ii),'LineWidth',1,'Color',cmap(1));
        hold on
        MH(ii) = plot(MX(:,ii),'LineWidth',2,'Color',cmap(2));
        hold off
        title(Xvnames_long(ii));
        DatesPlot(date(1),nobsf,11,'m') % Set the x-axis label using dates
        grid on; 
    end

    sgtitle(countrynames(kk),'Color',cmap(1),'FontSize',18);
    
    strA=[outdir '/figures/id_' num2str(countryid) '_weather_trend'];
    SaveFigure(strA,1,'png')
    
end


% Plot histogram

for kk = 1:nstate

    countryid = kk;

    X = nan(nobs,Xnvar);
    
    for ii=1:Xnvar
        X(:,ii) = DATA(countryid).(Xvnames{ii});
    end
        
    %figure('name','Weather and Climate: Distribution')
    FigSize(20,11)
    for ii=1:Xnvar
        subplot(2,3,ii)
        histogram(X(:,ii), 30 ,'Normalization','probability')
        title(Xvnames_long(ii));
    end

    sgtitle(countrynames(kk),'Color',cmap(1),'FontSize',18);
    
    strA=[outdir '/figures/id_' num2str(countryid) '_weather_hist'];
    SaveFigure(strA,1,'png')

end


%% Plot cross-correlations between Econ and Weather variables


% Climate variables
    Xvnames = {'AECI','hot','cold','drought','prep','wind'};
    Xvnames_long = {'Climate Index (AECI)','Heat Stress','Cold Stress','Drought',...
            'Precipitation','Wind Speed'};
    Xnvar = length(Xvnames);


% Economic variables
    Yvnames = {'d12hcpi_m','d12ccpi_m','d12fcpi_m','d12ecpi_m','d12ppi_m','d12uempr','d12xport','d12mport','d12tbaladj','ir_deposit','ir_lending','ir_spread',...
            'd12ir_deposit','d12ir_lending','d12ir_spread','d12ip','d12xr','d12ep'};
    Yvnames_long = {'CPI Inflation','Core CPI Inflation','Food CPI Inflation','Energy CPI Inflation','PPI Inflation',...
            'Unemployment Change','Export Growth','Import Growth','Trade Balance Adjustment','Deposit Rates', 'Lending Rates','Interest Rate Spread',...
            'Deposit Rate Change', 'Lending Rate Change','Interest Spread Change', 'Output (IP) Growth','Exchange Rate Change','Stock Returns'};
    Ynvar = length(Yvnames);    


countryid = 13;

X = nan(nobs,Xnvar);
Y = nan(nobs,Ynvar);

    for ii=1:Xnvar
        X(:,ii) = DATA(countryid).(Xvnames{ii});
    end

    for jj=1:Ynvar
        Y(:,jj) = DATA(countryid).(Yvnames{jj});
    end

LL=12;
XCF = nan(LL*2+1,Xnvar,Ynvar);

for ii=1:Xnvar
    for jj=1:Ynvar
        XCF(:,ii,jj) = crosscorr(X(:,ii),Y(:,jj),NumLags=LL,NumSTD=1);
    end
end


