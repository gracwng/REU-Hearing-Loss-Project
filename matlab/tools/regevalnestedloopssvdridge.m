%> @file regevalnestedloopssvdridge.m
%> @brief Fits Ridge regression models using <regfitsvdridge> and evaluates the predictive power using nested cross-validation procedures
%> @param opts configuration struct
%> @param opts.lambda Ridge regularization hyperparameters of interest. Default: [10 100 1000]
%> @param opts.znormd Should the data be Z-scored?. Default: 1 (yes). Alternatively set it to 0 (no)
%> @param opts.gof What goodness-of-fit metric is considered? default:
%> 'estcorr'. Please note that this is an advanced field and should most often be left
%> as is.
%> @param opts.kouter Number of outer folds. Default: 10
%> @param opts.kinner Number of inter folds. Default: 5
%> @param opts.storew Do you wish to store the model coefficients? Default: 0 (no), alternatively set it to 1 (yes)
%> @param opts.phaserand a configuration struct for evaluating model performance on surrogate data
%> @param opts.phaserand.nperm number of times to evaluate goodness-of-fit on surrogate data for each outer fold  
%> @param opts.phaserand.roi should the goodness-of-fit be averaged over
%> certain columns in yy? Default was for this project set to a cluster of
%> fronto-central electrodes
%> @param xx regressor matrix of size (time x features x trials)
%> @param yy target matrix of size (time x features x trials)
%> @retval vlog a cellstruct containing information about model fit and performance
%> @retval vlog{i}.acci model accuracy over each inner loop < number of lambda paramaters x dimensions in yy x inner folds>
%> @retval vlog{i}.acco model accuracy on the test data for outer loop i
%> @retval vlog{i}.opts a structure containing information about <opts> and the cross-validation splits
%> @retval vlog{i}.opts.phaserand a structure containing model accuracies on surrogate data
%> @retval vlog{i}.opts.phaserand.accsurr model accuracies over all permutations
%> @retval vlog{i}.opts.phaserand.roi input roi specified. this may however not be fulfilled, in which case it is set to the average over all dimensions in yy
%> @retval vlog{i}.opts.phaserand.surroi the actual roi considered for the analysis


function [vlog] = regevalnestedloopssvdridge(opts,xx,yy)

if nargin < 1 || isempty(opts);        opts = struct; end
if isfield(opts,'kouter')==0;          opts.kouter = 10; end
if isfield(opts,'kinner')==0;          opts.kinner = 5; end
if isfield(opts,'lambda')==0;          opts.lambda = [10 100 1000]; end
if isfield(opts,'znormd')==0;          opts.znormd = 1; end
if isfield(opts,'storew')==0;          opts.storew = 0; end
if isfield(opts,'gof')==0;             opts.gof = 'estcorr'; end
if isfield(opts,'phaserand')==0;       opts.phaserand = struct; end
if isfield(opts.phaserand,'roi')==0;   opts.phaserand.roi = [4 5 6 9 10 11 39 40 41 44 45 46  38 47]; end
if isfield(opts.phaserand,'nperm')==0; opts.phaserand.nperm = 0; end

nt      = size(xx,3);
ko      = opts.kouter;
ki      = opts.kinner;
lambda  = opts.lambda;
vlog    = cell(1,ko);
co      = cvpartition(nt,'KFold',ko);

for jo  = 1 : ko
    
    traino  = find(training(co,jo)==1);
    testo   = find(training(co,jo)==0);
    
    xtr     = xx(:,:,traino);
    ytr     = yy(:,:,traino);
    
    
    ni      = size(xtr,3);
    ci      = cvpartition(ni,'KFold',ki);
    
    
    acci    = [];
    acco    = [];
    ww      = [];
    
    for ji = 1 : ki
        
        traini  = find(training(ci,ji)==1);
        testi   = find(training(ci,ji)==0);
        
        xitr    = matsqueeze3d2d(xtr(:,:,traini));
        yitr    = matsqueeze3d2d(ytr(:,:,traini));
        
        xits    = matsqueeze3d2d(xtr(:,:,testi));
        yits    = matsqueeze3d2d(ytr(:,:,testi));
        
        
        acci(:,:,ji) = regfitsvdridge(xitr,yitr,xits,yits,lambda,opts.znormd,opts.gof);
    end
    
    [~,acciopt] = max(mean(acci,3),[],1);
    
    
    xtr     = matsqueeze3d2d(xtr);
    ytr     = matsqueeze3d2d(ytr);
    
    xts     = matsqueeze3d2d(xx(:,:,testo));
    yts     = matsqueeze3d2d(yy(:,:,testo));
    
    
    [acco,ww] = regevaloptimallambdasvdridge(xtr,ytr,xts,yts,acciopt,lambda,opts.znormd,opts.gof);
    
    
    
    
    vlog{jo} = struct;
    vlog{jo}.acci = acci;
    vlog{jo}.acco = acco;
    vlog{jo}.opts = opts;
    
    if opts.storew
        vlog{jo}.ww = ww;
    end
    
    
    
    
    
    
    if opts.phaserand.nperm > 0 
        if opts.znormd
        [~,xts] = matznormxt(xtr,xts);
        [~,yts] = matznormxt(ytr,yts);
        end
        
        [accsurr,surrroi] = regevalsurrdata(xts,yts,ww,opts.phaserand.nperm,opts.gof,opts.phaserand.roi);
        vlog{jo}.opts.phaserand.accsurr = accsurr;
        vlog{jo}.opts.phaserand.surrroi = surrroi;
    end
    vlog{jo}.opts.ci = ci;
    vlog{jo}.opts.co = co;
    
    
end