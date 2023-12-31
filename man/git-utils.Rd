\name{git-utils}

\alias{git-utils}
\alias{prepare_git_repo_for_work}
\alias{set_git_user_name}
\alias{unset_git_user_name}
\alias{set_git_user_email}
\alias{unset_git_user_email}
\alias{git_commit}

\title{Convenience Git-related utility functions used by
       updateBiocPackageRepoObjects()}

\description{
  \code{prepare_git_repo_for_work()} and \code{git_commit()}
  are used internally by \code{\link{updateBiocPackageRepoObjects}()}
  to perform Git operations.
}

\usage{
prepare_git_repo_for_work(repopath=".", branch=NULL, git=NULL,
                          use.https=FALSE)

git_commit(repopath=".", commit_msg, push=FALSE,
           git=NULL, user_name=NULL, user_email=NULL)
}

\arguments{
  \item{repopath}{
    The path (as a single string) to the local Git repository of a
    Bioconductor package.

    If the specified path exists, \code{prepare_git_repo_for_work()} will
    check that it's a workable Git repo (i.e. contains no uncommitted changes).
    If that's the case then it will call \code{git pull} on it, otherwise
    it will return an error.

    If the specified path does not exist, \code{prepare_git_repo_for_work()}
    will try to infer the package name from \code{repopath} and clone it
    from \url{git.bioconductor.org}.
  }
  \item{branch}{
    The branch (as a single string) of the Git repository to work on.

    If \code{NULL}, then the current branch is used (if \code{repopath}
    already exists) or the default branch is used (if \code{repopath}
    does not exist and needs to be cloned).
  }
  \item{git}{
    The path (as a single string) to the git command if it's not in the
    PATH.
  }
  \item{use.https}{
    By default, \code{git clone git@git.bioconductor.org:packages/MyPackage}
    is used to clone a package repo from the Bioconductor Git server. Note
    that this works only for authorized maintainers of package \pkg{MyPackage}.
    By setting \code{use.https} to \code{TRUE}, the package will be cloned
    instead from \code{https://git.bioconductor.org:packages/MyPackage}, which
    should work for anybody, but then pushing back the changes to the package
    won't be possible.
  }
  \item{commit_msg}{
    The Git commit message.
  }
  \item{push}{
    Whether to push the changes or not. Changes are committed but not
    pushed by default. You need push access to the package Git repository
    at \url{git.bioconductor.org} in order to use \code{push=TRUE}.
  }
  \item{user_name, user_email}{
    Set the Git user name and/or email to use for the commit. This overrides
    the Git user name and/or email that the git command would otherwise use.
    See the COMMIT INFORMATION section in
    \code{system2("git", c("commit", "--help"))}
    for the details about where the git command normally takes
    this information from.
  }
}

\value{
  \code{prepare_git_repo_for_work()} returns \code{FALSE} if the supplied
  path already exists, and \code{TRUE} if it didn't exist and needed
  to be cloned.

  \code{git_commit()} returns an invisible \code{NULL}.
}

\seealso{
  \itemize{
    \item \code{\link{updateBiocPackageRepoObjects}} which uses
          \code{prepare_git_repo_for_work} and \code{git_commit}
          internally.

    \item \code{\link{bump_pkg_version}}.
  }
}

\examples{
repopath <- file.path(tempdir(), "IdeoViz")

## We must use HTTPS access to clone the package because we are
## not maintainers of the IdeoViz package. A more realistic situation
## would be to use prepare_git_repo_for_work() on a package that we
## maintain, in which case 'use.https=TRUE' would not be needed:
prepare_git_repo_for_work(repopath, use.https=TRUE)

bump_pkg_version(repopath, update.Date=TRUE)
\dontshow{
  ## Set fake git user to make git_commit() happy:
  old_names <- set_git_user_name("titi")
  old_emails <- set_git_user_email("titi@gmail.com")
}
git_commit(repopath, commit_msg="version bump", push=FALSE)
\dontshow{
  unset_git_user_name(old_names)
  unset_git_user_email(old_emails)
}
unlink(repopath, recursive=TRUE)
}
\keyword{utilities}
