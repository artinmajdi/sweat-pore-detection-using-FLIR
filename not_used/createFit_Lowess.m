function [fitresult, gof] = createFit_Lowess(X3, Y3, h3)
%CREATEFIT2(X3,Y3,H3)
%  Create a fit.
%
%  Data for 'untitled fit 1' fit:
%      X Input : X3
%      Y Input : Y3
%      Z Output: h3
%  Output:
%      fitresult : a fit object representing the fit.
%      gof : structure with goodness-of fit info.
%
%  See also FIT, CFIT, SFIT.

%  Auto-generated by MATLAB on 07-Nov-2019 11:32:41


%% Fit: 'untitled fit 1'.
[xData, yData, zData] = prepareSurfaceData( X3, Y3, h3 );

% Set up fittype and options.
ft = fittype( 'loess' );
opts = fitoptions( 'Method', 'LowessFit' );
opts.Normalize = 'on';
opts.Robust = 'LAR';
opts.Span = 0.05;

% Fit model to data.
[fitresult, gof] = fit( [xData, yData], zData, ft, opts );

% Plot fit with data.
figure( 'Name', 'untitled fit 1' );
h = plot( fitresult, [xData, yData], zData );
legend( h, 'untitled fit 1', 'h3 vs. X3, Y3', 'Location', 'NorthEast', 'Interpreter', 'none' );
% Label axes
xlabel( 'X3', 'Interpreter', 'none' );
ylabel( 'Y3', 'Interpreter', 'none' );
zlabel( 'h3', 'Interpreter', 'none' );
grid on
view( 77.2, 52.2 );

