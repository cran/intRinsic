#' #' @keywords internal
#' .mcmc_pack_rdirichlet <- function (n, alpha)
#' {
#'   l <- length(alpha)
#'   x <- matrix(stats::rgamma(l * n, alpha), ncol = l, byrow = TRUE)
#'   sm <- x %*% rep(1, l)
#'   return(x/as.vector(sm))
#' }
