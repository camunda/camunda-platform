package main

import (
	"context"
	"fmt"
	"github.com/go-logr/logr"
	"github.com/go-logr/logr/funcr"
	"github.com/google/go-github/v51/github"
	"golang.org/x/oauth2"
	"io"
	"os"
	"regexp"
	"text/template"
)

const RepoOwner = "camunda"
const CloudRepoOwner = "camunda-cloud"
const MainRepoName = "camunda-platform"
const ZeebeRepoName = "zeebe"
const OperateRepoName = "operate"
const TasklistRepoName = "tasklist"
const IdentityRepoName = "identity"
const ReleaseNotesTemplateFileName = "release-notes-template.txt"

// NewStdoutLogger returns a logr.Logger that prints to stdout.
func NewStdoutLogger() logr.Logger {
	return funcr.New(func(prefix, args string) {
		if prefix != "" {
			fmt.Printf("%s: %s\n", prefix, args)
		} else {
			fmt.Println(args)
		}
	}, funcr.Options{})
}

type CamundaPlatformRelease struct {
	ZeebeReleaseNotes    string
	OperateReleaseNotes  string
	TasklistReleaseNotes string
	IdentityReleaseNotes string
}

func GetChangelogReleaseContents(ctx context.Context,
	logger logr.Logger,
	repoName string,
	changelogFileName string,
	repoService *github.RepositoriesService) string {
	opts := github.RepositoryContentGetOptions{}
	operateChangeLogReader, response, err := repoService.DownloadContents(ctx,
		RepoOwner,
		repoName,
		changelogFileName,
		&opts)
	if err != nil || response.StatusCode != 200 {
		logger.Error(err, "error", err, "StatusCode", response.StatusCode)
	}

	bytes, err := io.ReadAll(operateChangeLogReader)
	if err != nil {
		logger.Error(fmt.Errorf("an error has occurred"), "error", err)
	}
	// operateChangeLogString := string(bytes)
	latestReleaseRegex, err := regexp.Compile(`(?s)(?m)# .*?(?:^# )`)
	if err != nil {
		logger.Error(fmt.Errorf("an error has occurred"), "error", err)
	}
	mostRecentChangeLog := latestReleaseRegex.Find(bytes)
	mostRecentChangeLogString := string(mostRecentChangeLog[0 : len(mostRecentChangeLog)-2])
	return mostRecentChangeLogString
}

func GetLatestReleaseContents(ctx context.Context,
	logger logr.Logger,
	orgName string,
	repoName string,
	repoService *github.RepositoriesService) string {
	latestRelease, response, err := repoService.GetLatestRelease(ctx, orgName, repoName)
	if err != nil || response.StatusCode != 200 {
		logger.Error(err, "status_code", response.StatusCode)
	}
	logger.Info("Latest release is: ", "latestRelease.name", latestRelease.Name)

	githubRelease, response, err := repoService.GetLatestRelease(ctx, orgName, repoName)
	if err != nil || response.StatusCode != 200 {
		logger.Error(fmt.Errorf("Error"), "statusCode", "status code", response.StatusCode)
		logger.Error(fmt.Errorf("an error has occurred"), "error", "errormsg", err)
	}
	return *githubRelease.Body
}

func main() {
	var temp = template.Must(template.ParseFiles(ReleaseNotesTemplateFileName))

	ts := oauth2.StaticTokenSource(
		&oauth2.Token{AccessToken: os.Getenv("GITHUB_PERSONAL_ACCESS_TOKEN")},
	)
	ctx := context.TODO()
	tc := oauth2.NewClient(ctx, ts)

	logger := NewStdoutLogger()
	client := github.NewClient(tc)
	repoService := client.Repositories

	zeebeReleaseNotes := GetLatestReleaseContents(
		ctx,
		logger,
		RepoOwner,
		ZeebeRepoName,
		repoService,
	)

	operateReleaseNotesContents := GetChangelogReleaseContents(
		ctx,
		logger,
		OperateRepoName,
		"CHANGELOG.md",
		repoService,
	)

	tasklistReleaseNotesContents := GetChangelogReleaseContents(
		ctx,
		logger,
		TasklistRepoName,
		"CHANGELOG.md",
		repoService,
	)

	identityReleaseNotesContents := GetLatestReleaseContents(
		ctx,
		logger,
		CloudRepoOwner,
		IdentityRepoName,
		repoService,
	)

	platformRelease := CamundaPlatformRelease{
		ZeebeReleaseNotes:    zeebeReleaseNotes,
		OperateReleaseNotes:  operateReleaseNotesContents,
		TasklistReleaseNotes: tasklistReleaseNotesContents,
		IdentityReleaseNotes: identityReleaseNotesContents,
	}

	err := temp.Execute(os.Stdout, platformRelease)
	if err != nil {
		logger.Error(fmt.Errorf("could not parse template file"), "error", err)
	}
}
