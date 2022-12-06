# Challenge 2: If it isn’t in version control, it doesn’t exist

[< Previous Challenge](solution-01.md) - **[Home](./README.md)** - [Next Challenge >](solution-03.md)

## Notes & Guidance

Keep in mind that the users need the _Owner_ permission to create a new Cloud Source Repository.

Git requires users to set up their identity before anything can be committed. So users need do the following:

```shell
git config --global user.name "FIRST_NAME LAST_NAME"
git config --global user.email "MY_NAME@example.com"
```

If users miss this step, they'll be prompted the first time they want to do a commit and they can complete it by that time.

After that a local git repository in the root of the extracted archive needs to be created, cd to `gcp-mlops-demo-main` (if the archive is downloaded as a zip file and extracted with default options) and run the following commands.

```shell
git init .
git add .
git commit -m "initial commit"
```

If users ignored the instructions and cloned the repo, they can skip the local Git repo creation, but they'll have to do the following steps.

Creating a Cloud Source Repository should be trivial, it should be created in the lab project. And then an SSH key should be added (see the vertical ellipsis on the right side of the top bar for Cloud Source Repositories).

The following command will generate an SSH key pair and show the contents of the public key to be copied to the Cloud Source Repositories.

```shell
ssh-keygen -t rsa -b 4096
cat ~/.ssh/id_rsa.pub
```

Then users need to add the Cloud Source Repository as a remote. This is all documented on the landing page of the newly created repository if users choose the _Push code from a local Git repository_ option.

```shell
git remote add google ssh://STUDENT...@ORGANIZATION...@source.developers.google.com:2022/p/PROJECT/r/gcp-mlops-demo
```

And finally push the changes.

```shell
git push --all google
```

> The Cloud Source Repositories still defaults to `master` branch, you might need to switch to a different branch to see the contents if you've used `main` as your default branch.

Note also that it's possible to use `gcloud` authentication instead of SSH but that's not the challenge :)

