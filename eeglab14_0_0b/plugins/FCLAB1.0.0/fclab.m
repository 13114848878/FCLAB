% pop_fclab() - Functional Connectivity Lab for EEGLAB  
%
% Usage:
%   >>  OUTEEG = pop_fclab( INEEG, type );
%
% Inputs:
%   INEEG   - input EEG dataset
%   type    - type of processing. 1 process the raw
%             data and 0 the ICA components.
%   
%    
% Outputs:
%   OUTEEG  - output dataset
%
% See also:
%   SAMPLE, EEGLAB 

% Copyright (C) <year>  <name of author>
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

function [outEEG, com] = fclab(inEEG, params)
if nargin < 1
    error('FCLAB:Need parameters');
	return;
end

outEEG = inEEG;
[m, n, o] = size(inEEG.data);
if strcmp(params.metric, 'cor');
    if (o == 1)
        temp_adj = corrcoef(inEEG.data');
    else
        temp_adj = corrcoef(mean(inEEG.data,3)');
    end  
end

%% Apply threshold value (if any)
% disp(['Thresh set to ', num2str(params.gthresh)]);
% if(isempty(params.gthresh) ~= 1 && isnan(params.gthresh) == 0)
%     temp_adj(temp_adj < params.gthresh) = 0;
% end

disp('>>FCLAB: Automatically discarding potential negative values...');
temp_adj(temp_adj < 0) = 0;
outEEG.FC.correlation.adj_matrix = temp_adj;

%% Perform network analysis
addpath('2017_01_15_BCT');
addpath('matlab_networks_routines/code');

L = weight_conversion(temp_adj, 'lengths'); %connection-length matrix
D = distance_wei(L); %distance matrix

%local measures
outEEG.FC.correlation.local.BC = betweenness_wei(L)./((n-1)*(n-2));
outEEG.FC.correlation.local.DEG = degrees_und(temp_adj)./(n-1);
[~, ~, outEEG.FC.correlation.local.ECC, ~, ~] = charpath(D);
outEEG.FC.correlation.local.clustcoef = clustering_coef_wu(temp_adj);
outEEG.FC.correlation.local.Elocal = efficiency_wei(temp_adj, 1); %or 2 for modified version
outEEG.FC.correlation.local.EC = eigenvector_centrality_und(temp_adj);

%global measures
[~, ~, ~, ~, outEEG.FC.correlation.global.diam] = charpath(D);
[~, ~, ~, outEEG.FC.correlation.global.rad, ~] = charpath(D);
outEEG.FC.correlation.global.LN = leaf_nodes(temp_adj);
[outEEG.FC.correlation.global.lambda, ~, ~, ~, ~] = charpath(D);
outEEG.FC.correlation.global.DEGcor = pearson(temp_adj); %CHECK THIS
outEEG.FC.correlation.global.Eglobal = efficiency_wei(temp_adj, 0);

%%
com = sprintf('fclab( %s, %s );', inputname(1), 'params');

return;
