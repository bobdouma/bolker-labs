


setwd("C:\\Users\\douma002\\OneDrive - WageningenUR\\Education\\CSA-34306 Ecological Models and Data in R\\2019-2020\\labs\\bolker-labs")

dat <- read.csv("shapes6.csv")

plot(da$y ~ da$x)

a <- 1
d.jonas <- 8
d.joost <- 5
d.nikolas <- 3
mu <- 5
curve(a*exp(-((x-mu)^2)/d.jonas),add=T)
curve(a*exp(-((x-mu)^2)/d.joost),add=T,col="red")
curve(a*exp(-((x-mu)^2)/d.nikolas),add=T,col="green",lwd=2)

library(fields)
stats.bin(dat$y,N=6)
?breaks


dat$p <- a*exp(-((dat$x-mu)^2)/d.joost)
dat$p.jonas <- a*exp(-((dat$x-mu)^2)/d.jonas)
dat$lik <- dbinom(dat$y,size=1,prob=dat$p)
dat$lik.jonas <- dbinom(dat$y,size=1,prob=dat$p.jonas)

prod(dat$lik)
prod(dat$lik.jonas)
