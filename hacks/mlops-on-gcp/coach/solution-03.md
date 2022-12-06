# Challenge 3: You break the build, you buy cake

[< Previous Challenge](solution-02.md) - **[Home](../README.md)** - [Next Challenge >](solution-04.md)

## Notes & Guidance

Any region can be selected to do the build. Users need to point to the right build file, and that's `/build/cloudbuild.yaml`, note the `/build/` prefix.

There's trailing whitespace in one of the files, which causes the linter to fail. That needs to be removed, and when the changes are pushed, the push trigger will yield a succesfull build.

