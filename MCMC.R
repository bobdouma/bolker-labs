# This script includes all the code blocks from section 6.3 of Lab 6 on 
# Bayesian parameter estimation

# The function computing values proportional to the log-posterior density
LPfun1 = function(p, dat = x) {
  # Mean and size of the negative binomial (use exp to force them to be positive)
  mu = exp(p[1])
  k  = exp(p[2])
  # Logarithm of the prior distributions on mu and k 
  # (0 and 2 are parameters chosen by the user, they represent prior beliefs)
  lp_mu = dnorm(mu, 0, 2, log = TRUE)
  lp_k = dnorm(k, 0, 2, log = TRUE)
  log_prior = lp_mu + lp_k
  # Log-likelihood of the data under the model
  LL = sum(dnbinom(dat,mu=mu,size=k,log=TRUE))
  # Sum of the log-likelihood and the log-prior
  LL + log_prior
}


# An implementation of the Metropolis-Hastings algorithm with a multivariate
# normal distribution as the proposal distribution
library(mvtnorm)
MH = function(model, init, Sigma = diag(init/10), niter = 3e4, burn = 0.5,
              seed = 1134, ...) {
  # To make results reproducible you should set a seed (change among chains!!!)
  set.seed(seed)
  # Pre-allocate chain of values
  chain = matrix(NA, ncol = length(init), nrow = niter)
  # Chain starts at init
  current = init
  lp_current = model(current, ...)
  # Iterate niter times and update chain
  for(iter in 1:niter) {
    # Generate proposal values from multivariate Normal distribution
    proposal = rmvnorm(1, mean = current, sigma = Sigma)
    # Calculate probability of acceptance (proposal distribution is symmetric)
    lp_proposal = model(proposal, ...)
    paccept = min(1, exp(lp_proposal - lp_current))
    # Accept the proposal... or not!
    # If accept, update the current and lp_current values
    accept = runif(1) < paccept
    if(accept) {
      chain[iter,] = proposal
      lp_current = lp_proposal
      current = chain[iter,]
    } else {
      chain[iter,] = current
    }
  }
  # Calculate the length of burn-in
  nburn = floor(niter*burn)
  # Calculate final acceptance probability after burn-in (fraction of proposals accepted)
  acceptance = 1 - mean(duplicated(chain[-(1:nburn),]))
  # Package the results
  list(burnin = chain[1:nburn,], sample = chain[-(1:nburn),],
       acceptance = acceptance, nburn = nburn)
}


# Generate synthetic data from the negative binomial
set.seed(1001)
mu.true=1
k.true=0.4
x = rnbinom(50,mu=mu.true,size=k.true)


# Run the algorithm to obtain a sample from the posterior
Sigma = diag(c(10,10))
init = log(c(1,1))
bay1 = MH(LPfun1, init, Sigma, burn = 0.3, dat = x)


# The acceptance probability of the Markov chain
bay1$acceptance

# Visualize the traces from the chain (squiggly lines)
par(mfrow = c(2,1), mar = c(4,4,0.5,0.5), las = 1)
plot(bay1$sample[,1], t = "l", ylab = "Trace of log(mu)")
plot(bay1$sample[,2], t = "l", ylab = "Trace of log(k)")


# Maximum a posteriori estimate + variance-covariance matrix
mapfit = optim(fn = LPfun1, par = log(c(1,1)),
               hessian = TRUE, method = "BFGS",
               control = list(fnscale = -1), dat = x)
Sigma = solve(-mapfit$hessian)
Sigma
init = mapfit$par
bay2 = MH(LPfun1, init, Sigma, burn = 0.3)


# The acceptance probability of the new Markov chain
bay2$acceptance


# Visualize the traces from the chain (squiggly lines)
par(mfrow = c(2,1), mar = c(4,4,0.5,0.5), las = 1)
plot(bay2$sample[,1], t = "l", ylab = "Trace of log(mu)")
plot(bay2$sample[,2], t = "l", ylab = "Trace of log(k)")

# Posterior distribution for each parameter
bay2sample = exp(bay2$sample)
par(mfrow = c(1,2), mar = c(4,4,1.5,1))
hist(bay2sample[,1], main = "Density of mu", freq = F, xlim = c(0,4))
hist(bay2sample[,2], main = "Density of k", freq = F, xlim = c(0,1))


# Compare different values (this assumes you ran the previous sections in the lab)
map = exp(mapfit$par)
meanp = colMeans(bay2sample)
medianp = c(median(bay2sample[,1]), median(bay2sample[,2]))
cbind(map, meanp, medianp,
      mom = c(mu.mom, k.mom),
      mle = opt1$par,
      true = c(mu.true, k.true))

# Compute the 95% probability intervals on the posterior distribution
t(apply(bay2sample, 2, quantile, probs = c(0.025, 0.975)))









