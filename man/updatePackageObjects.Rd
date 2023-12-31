\name{updatePackageObjects}

\alias{updatePackageObjects}
\alias{updateAllPackageObjects}

\title{Update the serialized objects contained in a package
       or in a set of packages}

\description{
  Use \code{updatePackageObjects()} to update all the serialized objects
  contained in a package.

  Use \code{updateAllPackageObjects()} to update all the serialized objects
  contained in a set of packages.
}

\usage{
updatePackageObjects(pkgpath=".", filter=NULL,
                     dry.run=FALSE, bump.Version=FALSE)

updateAllPackageObjects(all_pkgpaths, skipped_pkgs=NULL, filter=NULL,
                     dry.run=FALSE, bump.Version=FALSE)
}

\arguments{
  \item{pkgpath}{
    The path (as a single string) to the top-level directory
    of an R package source tree.
  }
  \item{filter, dry.run}{
    These arguments are passed down to \code{updateSerializedObjects()}.
    See \code{?\link{updateSerializedObjects}} for the details.
  }
  \item{bump.Version}{
    \code{TRUE} or \code{FALSE}. If \code{TRUE} and if some RDS or RDA files
    in the package actually get updated by \code{updateSerializedObjects()},
    then the package version will get bumped, that is, the Version field in
    its DESCRIPTION file will get bumped from X.Y.Z to X.Y.(Z+1).
    For example, version 2.0.9 will become 2.0.10.

    Additionally, the Date field (if present) will get updated to the
    current date.
  }
  \item{all_pkgpaths}{
    Character vector of package paths.
  }
  \item{skipped_pkgs}{
    Character vector of package paths to ignore.
  }
}

\value{
  \code{updatePackageObjects()} returns the value returned by its call to
  \code{updateSerializedObjects()}. See \code{?\link{updateSerializedObjects}}
  for the details.

  \code{updateAllPackageObjects()} returns a named integer vector
  \emph{parallel} to \code{all_pkgpaths}.
}

\seealso{
  \itemize{
    \item The \code{\link{updateSerializedObjects}} function which
          is the workhorse behind \code{updatePackageObjects}.

    \item \code{\link{updateBiocPackageRepoObjects}} and
          \code{\link{updateAllBiocPackageRepoObjects}} which are
          wrapper functions that also take care of committing and
          pushing the changes made to the packages.

    \item The \code{\link{bump_pkg_version}} function which is
          used internally by \code{updatePackageObjects} and
          \code{updateAllPackageObjects} when \code{bump.Version=TRUE}.
  }
}

\examples{
## ---------------------------------------------------------------------
## A SIMPLE updatePackageObjects() EXAMPLE
## ---------------------------------------------------------------------

## DemoPackage is a small demo package (contained in the updateObject
## package) with some old serialized GRanges objects in it.
pkgname <- "DemoPackage"
pkgpath0 <- system.file(pkgname, package="updateObject")

## Let's copy DemoPackage to a writable location.
pkgpath <- file.path(tempdir(), pkgname)
file.copy(pkgpath0, dirname(pkgpath), recursive=TRUE)

## Note that, in order to update the GRanges objects contained in
## DemoPackage, updatePackageObjects() will need to attach the
## GenomicRanges package. That's because this is where the GRanges
## class and updateObject() method for GRanges objects are both
## defined. See '?updateSerializedObjects' for more information.
## Also note that we don't need to perform two passes ("dry run" +
## "real run"), one pass is enough. Here we show the 2-pass procedure
## for illustrative purpose only.

## 1st pass: dry run
code <- updatePackageObjects(pkgpath, dry.run=TRUE)
code  # a non-negative code means everything went fine

## 2nd pass: do it for good!
updatePackageObjects(pkgpath, bump.Version=TRUE)

## An additional run would only confirm that there's nothing left
## to update.
code <- updatePackageObjects(pkgpath)
code  # 0 (no files to update)

unlink(pkgpath, recursive=TRUE)

## ---------------------------------------------------------------------
## FIND CANDIDATE PACKAGES IN CURRENT DIRECTORY
## ---------------------------------------------------------------------
\dontrun{
## In this example we perform a "dry run" with updateAllPackageObjects()
## to find all the packages in a directory that contain old serialized
## objects.

## Let's assume that the current directory is populated with package
## git clones:
all_pkgs <- dir()  # get list of packages

## If we know that some packages are going to cause problems, we should
## skip them. Note that we could just do
##
##   all_pkgs <- setdiff(all_pkgs, SKIPPED_PKGS)
##
## for this. However, by using the 'skipped_pkgs' argument, all the
## packages in the original 'all_pkgs' will be represented in the
## returned vector, including the skipped packages:
SKIPPED_PKGS <- c(
    "BaalChIP", "BiGGR", "CytoTree", "gwascat",
    "mirIntegrator", "oposSOM", "PFP", "ROntoTools", "SLGI"
)

## --- Without a filter ---

## updateAllPackageObjects() will stop with an error if a package is
## required but not installed. The user is responsible for installing
## all the required packages (this is admittedly hard to know in advance).
codes <- updateAllPackageObjects(all_pkgs, skipped_pkgs=SKIPPED_PKGS,
                                 dry.run=TRUE)

sessionInfo()  # many packages
table(codes)

## The above code was successfully run in the MEAT0 folder on nebbiolo1
## (BioC 3.15, 2067 packages) on Nov 18, 2021:
## - took about 14 min
## - loaded 1190 packages (as reported by sessionInfo())
## - required about 9GB of RAM
##
## > table(codes)
## codes
## codes
##   -3   -2   -1    0    1    2    3    4    5    6    7    8    9   10
##    4   15   66 1549  240   90   46   28    7    5    4    3    3    1
##   13   18   20   23  125
##    2    1    1    1    1
##
## > sum(codes > 0) / length(codes)
## [1] 0.2094823
## 21% packages with old S4 instances!

## --- With a filter ---

## We want to filter on the presence of the **word** "DataFrame" in
## the output of 'updateObject( , check=FALSE, verbose=TRUE)'. We can't
## just set 'filter' to '"DataFrame" for that as this would also produce
## matches in the presence of strings like "AnnotatedDataFrame":
filter <- "\\bDataFrame\\b"

codes <- updateAllPackageObjects(all_pkgs, skipped_pkgs=SKIPPED_PKGS,
                                 filter=filter,
                                 dry.run=TRUE)

}
}
\keyword{utilities}
