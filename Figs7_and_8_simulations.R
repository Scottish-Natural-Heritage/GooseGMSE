# source('ggmse_default_test_pars.R')
# 
# blocks <- 50
# 
# ## Non-parallel version of the below:
# for (b in 1:blocks) {
#   for(i in 1:iterations) {
#     cat(sprintf("Block %d, Iteration %d",b,i))
#     years <- proj_yrs
#     prev_params <- NULL
#     goose_multidata[[i]] <- gmse_goose(data_file = data_file,
#                                        obs_error = obs_error,
#                                        years = proj_yrs,
#                                        manage_target = manage_target,
#                                        max_HB = max_HB, plot = FALSE,
#                                        use_est = 0)
#   cat('\n')
#   }
#   save(goose_multidata, file=paste0("out/goose_multidata_",format(Sys.time(),"%Y%m%d%_H%M%S"),"_block",b,".Rdata"))
# }


## Parellelised runs:

cl <- parallel::makeForkCluster(8, outfile="out/cl_log.txt")
doParallel::registerDoParallel(cl)

for(z in 1:10) {
  source('ggmse_default_test_pars.R')



  system.time({
    goose_multidata <- foreach(i=1:iterations) %dopar% {
      cat(sprintf("%s: Iteration %d\n", as.character(Sys.time()), i))
      years <- proj_yrs
      gmse_goose(data_file = data_file,
                 obs_error = obs_error,
                 years = proj_yrs,
                 manage_target = manage_target,
                 max_HB = max_HB, plot = FALSE,
                 use_est = 0)
    }

  })
  # user  system elapsed
  # 3.252   8.403 326.707   ### 100 runs, 8-core cluster
  # user  system elapsed
  # 2.986   7.830 317.803   ### 100 runs, 6-core
  # user  system elapsed
  # 2.948   8.440 343.354   ### 100 runs, 4-core
  # user  system elapsed
  # 3.640   7.753 543.525   ### 100 runs, 2-core

  save(goose_multidata, file=paste0("out/goose_multidata_",format(Sys.time(),"%Y%m%d%_H%M%S"),".Rdata"))
}
stopCluster(cl)
gc()


