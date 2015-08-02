# Lockfile

Just like a Ruby application that uses [bundler](http://bundler.io/), sometimes it is important
that everyone has the same set of dependencies. For example, if we update
[tundra](http://github.com/robertzk/tundra) with a critical fix that affects production
model objects, we should make sure everyone uses this fix when training new models
that will go into production. The lockfile ensures that everyone is using the same
package versions for those packages that have critical fixes. You can look at the 
precise logic of how this is enforced in [the lockfile helper](lockfile.R).

In particular, we force a restart of R to ensure no lazy-loading corruption happens,
which is bound to occur due to the way R manages package dependencies in a live
session.

A future improvement is to support ranges of versions instead of fixed versions.

