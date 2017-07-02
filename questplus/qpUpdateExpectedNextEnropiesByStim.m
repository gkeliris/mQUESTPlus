function expectedNextEntropiesByStim = qpUpdateExpectedNextEnropiesByStim(questData)
% qpUpdateExpectedNextEnropiesByStim  Update the table of expected entropies for each stimulus
%
% Usage:
%
% Description:
%     Uses posterior and precomputed elements of questData to update the
%     table that gives expected entropy after a trial of each stimulus.
%
%     This is broken out into a separate routine so we can call it both
%     from qpInitialize and qpUpdate.
%
% Inputs:
%
% Outputs:
%
% Optional key/value pairs
%   None
%% Set some internal parameters
unityTolerance = 1e-10;

%% Compute the expected outcomes for each stimulus by averaging over the posterior.
expectedOutcomesByStim = zeros(questData.nStimParamsDomain,questData.nOutcomes);
for ss = 1:questData.nStimParamsDomain
    for pp = 1:questData.nPsiParamsDomain
        expectedOutcomesByStim(ss,:) = expectedOutcomesByStim(ss,:) + questData.posterior(pp)*squeeze(questData.precomputedOutcomeProportions(ss,pp,:))';
    end
    assert(abs(sum(expectedOutcomesByStim(ss,:))-1) < unityTolerance,'Computed expected outcomes do not sum to one');
end

%% Compute the entropy for each outcome
%
% This is the entropy we'd get if we run a trial and update assuming that
% outcome.
nextEntropiesByStimOutcome = zeros(questData.nStimParamsDomain,questData.nOutcomes);
for ss = 1:questData.nStimParamsDomain
    for oo = 1:questData.nOutcomes
        nextPosteriorsByStimOutcome = ...
            qpUnitizeArray(questData.posterior .* squeeze(questData.precomputedOutcomeProportions(ss,:,oo))');
        nextEntropiesByStimOutcome(ss,oo) = qpArrayEntropy(nextPosteriorsByStimOutcome);
    end
end

%% Compute the expected entropy for each stimulus by averaging entropies over each 
expectedNextEntropiesByStim = zeros(questData.nStimParamsDomain,1);
for ss = 1:questData.nStimParamsDomain
    expectedNextEntropiesByStim(ss) = sum(expectedOutcomesByStim(ss,:) .* nextEntropiesByStimOutcome(ss,:));
end

end