function [cluster_idx, responsibility, cluster_centers, cluster_covariance, mixing] = GMM(input, k, display)
% function [cluster_idx, responsibility, cluster_centers, cluster_covariance, mixing] = GMM(input, k, display)
% input: NxD matrix, where N is the number of samples and D is the
%        dimension of the samples
% k: number of cluster centers
% display: 0 - do not display figures to show progress
%          1 - will display a figure shows the clustering process, but
%          duplicated colors will appear if k is greater than 7, and only
%          will display when the data is of 2 dimensions or less
% cluster_idx: the corresponding cluster id to each of input
% responsibility: the responsibility of each input
% culster_centers: the final result of cluster centers
% cluster_covariance: the final estimate of the covarariance matrix from
%                    each cluster
% example:
% X = [randn(100,2)+ones(100,2);...
% randn(100,2)-ones(100,2);
% randn(100,2)-[ones(100,1),-ones(100,1)]]; % generate dataset with three
% clusters
% [idx, res, ctr, ccov,m] = GMM(X,3,1);

if ~exist('display', 'var')
    display = 0;
end

[N, D] = size(input);
cluster_idx = zeros(N, 1);

if display && D <= 2
    color = ['y', 'm', 'c', 'r', 'b', 'g', 'k'];
else
    display = 0;
end

% randomly initilize the centers to some datapoints
idx = randperm(N);
cluster_centers = input(idx(1:k), :);
new_cluster_centers = zeros(k, D);
mixing = ones(k,1)/k;
new_mixing = zeros(k,1);
responsibility = zeros(N, k);
cluster_covariance = zeros(k, D, D);
new_cluster_covariance = zeros(k, D, D);

loglik_old = -Inf;

% initialize initial covariance matrix using identity matrix, it is possible
% to initilize it in some other way, e.g. using the covariance obtained
% from k-means
for i = 1 : k
    cluster_covariance(i, :, :) = eye(D);
end

% update centers iteratively
for iter = 1 : 100
    fprintf('%d\n', iter);
    
    % E step, evaluate the responsibility based on the current parameter
    % values
    for i = 1 : k
        responsibility(:,i) = mixing(k)*gaussian(input, cluster_centers(i, :), ...
            squeeze(cluster_covariance(i, :, :)), D);
    end
    responsibility = bsxfun(@rdivide, responsibility, sum(responsibility, 2));
    
    
    % M step, re-estimate the parameters
    lik = 0;
    for i = 1 : k
        Nk = sum(responsibility(:,i));
        new_cluster_centers(i, :) = sum(repmat(responsibility(:,i), 1, D).*input)/Nk;
        tmp = 0;
        for j = 1 : N
            tmp = tmp + responsibility(j,i)*(input(j,:)-cluster_centers(i, :))'...
                *(input(j,:)-cluster_centers(i, :));
        end
        new_cluster_covariance(i, :, :) = tmp/Nk;
        new_mixing(i) = Nk/N;
        lik = lik + new_mixing(i)*gaussian(input, new_cluster_centers(i,:), ...
            squeeze(new_cluster_covariance(i,:,:)), D);
    end
    
    [~,cluster_idx] = max(responsibility, [], 2);
    loglik_new = sum(log(lik));
    
    % try to display cluster data using different colors, but no more than
    % 7 colors
    if display
        STD = 2;                     % 2 standard deviations
        conf = 2*normcdf(STD)-1;     % covers around 95% of population
        scale = chi2inv(conf,2);     % inverse chi-squared with dof=#dimensions
        
        disp(['iteration', num2str(iter), ' Log-likelihood: ', num2str(loglik_new)]);
        figure(1); clf(1);hold on;
        for i = 1 : k
            plot(input(cluster_idx==i,1),input(cluster_idx==i,2),...
                [color(mod(i, length(color))),'.'],'MarkerSize',12);
            
            Cov = squeeze(new_cluster_covariance(i,:,:)) * scale;
            [V, val] = eig(Cov);
            
            t = linspace(0,2*pi,100);
            e = [cos(t) ; sin(t)];        % unit circle
            VV = V*sqrt(val);               % scale eigenvectors
            e = bsxfun(@plus, VV*e, new_cluster_centers(i,:)'); % project circle back to orig space
            plot(e(1,:), e(2,:), 'Color',color(mod(i, length(color))));
        end
        plot(new_cluster_centers(:,1),new_cluster_centers(:,2),'ko',...
            'MarkerSize',12,'LineWidth',2);
        hold off;
        drawnow;
        pause(0.5);
    end
    
    % stop updating while log likelihood does not change much
    
    if (loglik_new-loglik_old) < 1e-10
        break;
    end
    loglik_old = loglik_new;
    cluster_centers = new_cluster_centers;
    cluster_covariance = new_cluster_covariance;
    mixing = new_mixing;
end

return;

function y = gaussian(x, mu, sigma, d)
diff = bsxfun(@minus, x, mu);
expo = sum((diff/sigma).*diff,2);
y = 1/((2*pi)^(0.5*d)*sqrt(det(sigma)))*exp(-expo);
return;