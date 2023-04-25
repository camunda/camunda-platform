package main

import (
	"context"
	"github.com/google/go-github/v51/github"
	"github.com/rs/zerolog"
	"github.com/rs/zerolog/log"
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

type CamundaPlatformRelease struct {
	ZeebeReleaseNotes    string
	OperateReleaseNotes  string
	TasklistReleaseNotes string
	IdentityReleaseNotes string
}

func GetChangelogReleaseContents(ctx context.Context,
	repoName string,
	changelogFileName string,
	repoService *github.RepositoriesService,
	githubRef string) string {
	opts := github.RepositoryContentGetOptions{
		Ref: githubRef,
	}
	operateChangeLogReader, response, err := repoService.DownloadContents(ctx,
		RepoOwner,
		repoName,
		changelogFileName,
		&opts)
	if err != nil || response.StatusCode != 200 {
		log.Error().Stack().Err(err).Msg("an error has occurred")
		os.Exit(1)
	}

	bytes, err := io.ReadAll(operateChangeLogReader)
	if err != nil {
		log.Error().Stack().Err(err).Msg("an error has occurred")
		os.Exit(1)
	}
	// operateChangeLogString := string(bytes)
	latestReleaseRegex, err := regexp.Compile(`(?s)(?m)# .*?(?:^# )`)
	if err != nil {
		log.Error().Stack().Err(err).Msg("an error has occurred")
		os.Exit(1)
	}
	mostRecentChangeLog := latestReleaseRegex.Find(bytes)
	var firstNewlineIndex int
	for i, s := range mostRecentChangeLog {
		if s == '\n' {
			firstNewlineIndex = i
			break
		}
	}
	mostRecentChangeLogString := string(mostRecentChangeLog[firstNewlineIndex : len(mostRecentChangeLog)-2])
	return mostRecentChangeLogString
}

func GetLatestReleaseContents(ctx context.Context,
	orgName string,
	repoName string,
	repoService *github.RepositoriesService,
	githubRef string) string {

	githubRelease, response, err := repoService.GetReleaseByTag(ctx, orgName, repoName, githubRef)
	if err != nil || response.StatusCode != 200 {
		log.Error().Stack().Err(err).Msg("An error has occurred")
		os.Exit(1)
	}
	return *githubRelease.Body
}

func main() {
	var temp = template.Must(template.ParseFiles(ReleaseNotesTemplateFileName))

	ts := oauth2.StaticTokenSource(
		&oauth2.Token{AccessToken: os.Getenv("GITHUB_PERSONAL_ACCESS_TOKEN")},
	)
	githubRef := os.Getenv("GITHUB_REF_NAME")
	ctx := context.TODO()
	tc := oauth2.NewClient(ctx, ts)

	zerolog.TimeFieldFormat = zerolog.TimeFormatUnix
	log.Logger = log.Output(zerolog.ConsoleWriter{Out: os.Stderr})

	client := github.NewClient(tc)
	repoService := client.Repositories
	log.Debug().Msg("Github ref = " + githubRef)

	zeebeReleaseNotes := GetLatestReleaseContents(
		ctx,
		RepoOwner,
		ZeebeRepoName,
		repoService,
		githubRef,
	)

	operateReleaseNotesContents := GetChangelogReleaseContents(
		ctx,
		OperateRepoName,
		"CHANGELOG.md",
		repoService,
		githubRef,
	)

	tasklistReleaseNotesContents := GetChangelogReleaseContents(
		ctx,
		TasklistRepoName,
		"CHANGELOG.md",
		repoService,
		githubRef,
	)

	identityReleaseNotesContents := GetLatestReleaseContents(
		ctx,
		CloudRepoOwner,
		IdentityRepoName,
		repoService,
		githubRef,
	)

	platformRelease := CamundaPlatformRelease{
		ZeebeReleaseNotes:    zeebeReleaseNotes,
		OperateReleaseNotes:  operateReleaseNotesContents,
		TasklistReleaseNotes: tasklistReleaseNotesContents,
		IdentityReleaseNotes: identityReleaseNotesContents,
	}

	err := temp.Execute(os.Stdout, platformRelease)
	if err != nil {
		log.Error().Stack().Err(err).Msg("could not parse template file")
		os.Exit(1)
	}
}
