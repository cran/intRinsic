% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/twonn_dec_depr.R
\name{twonn_decimated}
\alias{twonn_decimated}
\title{Estimate the decimated \code{TWO-NN} evolution with halving steps or vector of
proportions}
\usage{
twonn_decimated(
  X,
  method = c("steps", "proportions"),
  steps = 0,
  proportions = 1,
  seed = NULL
)
}
\arguments{
\item{X}{data matrix with \code{n} observations and \code{D} variables.}

\item{method}{method to use for decimation:
\describe{
  \item{\code{"steps"}}{the number of times the dataset is halved;}
  \item{\code{"proportion"}}{the dataset is subsampled according to a vector
  of proportions.}
}}

\item{steps}{number of times the dataset is halved.}

\item{proportions}{vector containing the fractions of the dataset to be
considered.}

\item{seed}{random seed controlling the sequence of sub-sampled observations.}
}
\value{
list containing the \code{TWO-NN} evolution
(maximum likelihood estimation and confidence intervals), the average
distance from the second NN, and the vector of proportions that were
considered. According to the chosen estimation method, it is accompanied with
the vector of proportions or halving steps considered.
}
\description{
The estimation of the \code{id} is related to the scale of the
dataset. To escape the local reach of the \code{TWO-NN} estimator,
\href{https://www.nature.com/articles/s41598-017-11873-y}{Facco et al. (2017)}
proposed to subsample the original dataset in order to induce greater
distances between the data points. By investigating the estimates' evolution
as a function of the size of the neighborhood, it is possible to obtain
information about the validity of the modeling assumptions and the robustness
of the model in the presence of noise.
}
\references{
Facco E, D'Errico M, Rodriguez A, Laio A (2017). "Estimating the intrinsic
dimension of datasets by a minimal neighborhood information."
Scientific Reports, 7(1).
ISSN 20452322, \doi{10.1038/s41598-017-11873-y}.

Denti F, Doimo D, Laio A, Mira A (2022). "The generalized ratios intrinsic
dimension estimator."
Scientific Reports, 12(20005).
ISSN  20452322, \doi{10.1038/s41598-022-20991-1}.
}
\seealso{
\code{\link{twonn}}
}
