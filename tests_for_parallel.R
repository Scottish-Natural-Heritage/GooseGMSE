library(parallel)
library(foreach)

source('ggmse_default_test_pars.R')

cl <- parallel::makeForkCluster(8, outfile="log.txt")
doParallel::registerDoParallel(cl)

system.time({
  goose_multidata <- foreach(i=1:iterations) %dopar% {
    cat(sprintf("Iteration %d\n", i))
    gmse_goose(data_file = data_file,
               obs_error = obs_error,
               years = proj_yrs,
               manage_target = manage_target,
               max_HB = max_HB, plot = FALSE,
               use_est = 0)
  }
})
# user  system elapsed 
# 0.319   0.401  75.560 (10 sims, 10 years)
# 0.268   0.109  45.403   (10 sims, 10 years)
# 0.624   1.296 195.418 (50 sims, 10 years)

# system.time({
#   for(i in 1:iterations) {
#     goose_multidata[[i]] <-  gmse_goose(data_file = data_file,
#                                         obs_error = obs_error,
#                                         years = proj_yrs,
#                                         manage_target = manage_target,
#                                         max_HB = max_HB, plot = FALSE,
#                                         use_est = 0)
#   }
#   
# }) 
#user  system elapsed 
#224.124  68.514 169.981  (10 sims, 10 years)


goose_data <- goose_clean_data(file = data_file)
last_year  <- goose_data[dim(goose_data)[1], 1]

past_years <- goose_multidata[[1]]$Year<=last_year
con_years <- goose_multidata[[1]]$Year==2015 | goose_multidata[[1]]$Year==2016
plot(goose_multidata[[1]]$Year, goose_multidata[[1]]$y, type='n', ylim=c(0,50000), 
     xlab='Year', ylab='Estimated population size')
rect(last_year+1, -10000, last_year+proj_yrs+5, 70000, border=NA, col='grey')
box()
for(i in 1:length(goose_multidata)) {
  lines(goose_multidata[[i]]$Year[!past_years], goose_multidata[[i]]$Npred_mn[!past_years], col = alpha('black', 0.25))
}
#lines(goose_multidata[[1]]$Year[con_years], goose_multidata[[1]]$Count[con_years], lty='dashed')
lines(goose_multidata[[1]]$Year[past_years], goose_multidata[[1]]$Count[past_years], type='b', pch=21, col='black', bg='black')

out_lo <- as.data.frame(NULL)
out_hi <- as.data.frame(NULL)
for(i in 1:length(goose_multidata)) {
  out_lo <- rbind(out_lo, goose_multidata[[i]]$Npred_lo)
  out_hi <- rbind(out_hi, goose_multidata[[i]]$Npred_hi)
}
out_lo_mn <- as.vector(apply(out_lo, 2, mean))
out_hi_mn <- as.vector(apply(out_hi, 2, mean))
out_lo <- as.vector(apply(out_lo, 2, min))
out_hi <- as.vector(apply(out_hi, 2, max))

#lines(goose_multidata[[1]]$Year, out_lo_mn, lty='dotted', col='darkgrey')
#lines(goose_multidata[[1]]$Year, out_hi_mn, lty='dotted', col='darkgrey')
lines(goose_multidata[[1]]$Year, out_lo, lty='dotted')
lines(goose_multidata[[1]]$Year, out_hi, lty='dotted')

abline(h=manage_target, col='darkgrey', lty='dashed')

text(x=goose_multidata[[1]]$Year[length(goose_multidata[[1]]$Year)]-6, y=50000, 'Projected', pos=4)
text(x=goose_multidata[[1]]$Year[1], y=50000, 'Observed', pos=4)
