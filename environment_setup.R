############# Set up environments ##########

rm(list = ls())

library(renv)

getwd()

# Set up r environment

renv::init()
renv::snapshot()
