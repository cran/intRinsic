#' Stratification of the \code{id} by an external categorical variable
#'
#' The function computes summary statistics (mean, median, and standard
#' deviation) of the post-processed chains of the intrinsic dimension stratified
#' by an external categorical variable.
#'
#' @param object object of class \code{Hidalgo}, the output of the
#' \code{Hidalgo()} function.
#' @param class factor according to the observations should be stratified by.
#'
#' @return a \code{data.frame} containing the posterior \code{id} means,
#' medians, and standard deviations stratified by the levels of the variable
#' \code{class}.
#' @export
#'
#' @seealso \code{\link{Hidalgo}}
#'
#' @examples
#' \donttest{
#' X            <- replicate(5,rnorm(500))
#' X[1:250,1:2] <- 0
#' oracle       <- rep(1:2,rep(250,2))
#' h_out        <- Hidalgo(X)
#' id_by_class(h_out,oracle)
#' }
#'
id_by_class <- function(object, class) {

  if (class(object)[1] != "Hidalgo") {
    stop("object is not of class 'Hidalgo'", call. = FALSE)
  }

  class <- factor(class)
  REV   <- object$id_summary

  means    <- tapply(REV$MEAN, class, mean)
  medians  <- tapply(REV$MEAN, class, stats::median)
  sds      <- tapply(REV$MEAN, class, stats::sd)

  Res <- data.frame(
    class = levels(class),
    mean = means,
    median = medians,
    sd = sds
  )

  structure(Res, class = c("hidalgo_class", class(Res)))
}

#' @name id_by_class
#'
#' @param x object of class \code{hidalgo_class}, the output of the \code{id_by_class()} function.
#' @param ... other arguments passed to specific methods.
#'
#' @export
#'
print.hidalgo_class <- function(x, ... ){
  cat("Posterior ID by class:")
  rownames(x) <- NULL
  print(knitr::kable(x))
  cat("\n")
  invisible(x)
}

#' Posterior similarity matrix and partition estimation
#'
#' The function computes the posterior similarity (coclustering) matrix (psm)
#' and estimates a representative partition of the observations from the MCMC
#' output. The user can provide the desired number of clusters or estimate a
#' optimal clustering solution by minimizing a loss function on the space
#' of the partitions.
#' In the latter case, the function uses the package \code{salso}
#' (\href{https://cran.r-project.org/package=salso}{Dahl et al., 2021}),
#' that the user needs to load.
#'
#' @param object object of class \code{Hidalgo}, the output of the
#' \code{Hidalgo} function.
#' @param clustering_method character indicating the method to use to perform
#' clustering. It can be
#' \describe{
#'        \item{"dendrogram"}{thresholding the adjacency dendrogram with a given
#'         number (\code{K});}
#'        \item{"salso"}{estimation via minimization of several partition
#'        estimation criteria.
#'        The default loss function is the variation of information.}
#'        }
#' @param K number of clusters to recover by thresholding the
#' dendrogram obtained from the psm.
#' @param nCores parameter for the \code{salso} function: the number of CPU
#' cores to use. A value of zero indicates to use all cores on the system.
#' @param ... optional additional parameter to pass to \code{salso()}.
#'
#' @return list containing the posterior similarity matrix (\code{psm}) and
#' the estimated partition \code{clust}.
#' @export
#'
#' @seealso \code{\link{Hidalgo}}, \code{\link[salso]{salso}}
#'
#' @references
#' D. B. Dahl, D. J. Johnson, and P. Müller (2022),
#' "Search Algorithms and Loss Functions for Bayesian Clustering",
#' Journal of Computational and Graphical Statistics,
#' \doi{10.1080/10618600.2022.2069779}.
#'
#' David B. Dahl, Devin J. Johnson and Peter Müller (2022). "salso: Search
#' Algorithms and Loss Functions for Bayesian Clustering".
#' R package version
#' 0.3.0. \url{https://CRAN.R-project.org/package=salso}
#'
#' @examples
#' \donttest{
#' library(salso)
#' X            <- replicate(5,rnorm(500))
#' X[1:250,1:2] <- 0
#' h_out        <- Hidalgo(X)
#' clustering(h_out)
#' }
clustering <- function(object,
                       clustering_method = c("dendrogram", "salso"),
                       K = 2,
                       nCores = 1,
                       ...) {

  if (class(object)[1] != "Hidalgo") {
    stop("object is not of class 'Hidalgo'", call. = FALSE)
  }

  clustering_method <- match.arg(clustering_method)

  psm <- salso::psm(object$membership_labels,
                    nCores = nCores)

  clust <- switch(clustering_method,
                  "dendrogram" =   {
                    dendr <-  stats::hclust(stats::as.dist(1 - psm))
                    stats::cutree(dendr, k = K)
                  },
                  "salso" = {
                    salso::salso(object$membership_labels, ...)
                  })

  Res <-
    list(
      clust = factor(clust),
      psm = psm,
      chosen_method = clustering_method,
      K = length(unique(clust))
    )
  structure(Res, class = c("hidalgo_psm", class(Res)))
}


#' @name clustering
#'
#' @param x object of class \code{hidalgo_psm}, obtained from the function
#' \code{clustering()}.
#' @param ... ignored.
#'
#' @export
print.hidalgo_psm <- function(x, ...) {
  cat("Estimated clustering solution summary:\n\n")
  cat(paste0("Method: ", x$chosen_method, "\n"))

  if (x$chosen_method == "dendrogram") {
    cat(paste0("Retrieved clusters: ", x$K, "\n"))
  } else{
    cat(paste0("Retrieved clusters: ", length(unique(x$clust)), "\n"))
  }

  cat("Clustering frequencies:")
  tab           <- t(table(Cluster = x$clust))
  colnames(tab) <- paste("Cluster", colnames(tab))
  print(knitr::kable(tab))
  cat("\n")
  invisible(x)
}

#' @name clustering
#'
#'
#' @param x object of class \code{hidalgo_psm}, obtained from the function
#' \code{clustering()}.
#' @param ... ignored.
#'
#' @export
#'
plot.hidalgo_psm <- function(x, ...) {

  psm <- x$psm
  stats::heatmap(psm)
  invisible()
}




