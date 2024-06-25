package main

import (
	"context"
	"fmt"
	"io"
	"os"
	"regexp"
	"text/template"

	"github.com/google/go-github/v54/github"
	"github.com/rs/zerolog"
	"github.com/rs/zerolog/log"
	"golang.org/x/oauth2"
	"github.com/Masterminds/semver/v3"
)

const RepoOwner = "camunda"
const CloudRepoOwner = "camunda-cloud"
const MainRepoName = "camunda-platform"
const ZeebeRepoName = "camunda"
const TasklistRepoName = "tasklist"
const IdentityRepoName = "identity"
const ReleaseNotesTemplateFileName = "release-notes-template.txt"

type CamundaPlatformRelease struct {
	Overview             string
	ZeebeReleaseNotes    string
	OperateReleaseNotes  string
	TasklistReleaseNotes string
	IdentityReleaseNotes string
}

type camundaAppVersions struct {
	Zeebe    string
	Operate  string
	Tasklist string
	Identity string
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

func getEnv(key, fallback string) string {
	if value, ok := os.LookupEnv(key); ok {
		return value
	}
	return fallback
}

func releaseOverview(cav camundaAppVersions) string {
	releaseOverview := `
Camunda application in this release generation:
- Identity: %s
- Operate: %s
- Tasklist: %s
- Zeebe: %s
`
	return fmt.Sprintf(releaseOverview,
		cav.Identity,
		cav.Operate,
		cav.Tasklist,
		cav.Zeebe,
	)
}

func main() {
	var temp = template.Must(template.ParseFiles(ReleaseNotesTemplateFileName))

	camundaTokenSource := oauth2.StaticTokenSource(
		&oauth2.Token{AccessToken: os.Getenv("GITHUB_CAMUNDA_ACCESS_TOKEN")},
	)

	camundaReleaseVersion := getEnv("CAMUNDA_RELEASE_NAME", os.Getenv("GITHUB_REF_NAME"))
	camundaAppVersions := camundaAppVersions{
		Identity: getEnv("IDENTITY_GITREF", camundaReleaseVersion),
		Operate:  getEnv("OPERATE_GITREF", camundaReleaseVersion),
		Tasklist: getEnv("TASKLIST_GITREF", camundaReleaseVersion),
		Zeebe:    getEnv("ZEEBE_GITREF", camundaReleaseVersion),
	}

	ctx := context.TODO()
	camundaOAuthClient := oauth2.NewClient(ctx, camundaTokenSource)

	zerolog.TimeFieldFormat = zerolog.TimeFormatUnix
	log.Logger = log.Output(zerolog.ConsoleWriter{Out: os.Stderr})

	camundaGithubClient := github.NewClient(camundaOAuthClient)

	camundaRepoService := camundaGithubClient.Repositories

	log.Debug().Msg("Camunda Github ref = " + camundaReleaseVersion)
	log.Debug().Msg("Zeebe Github ref = " + camundaAppVersions.Zeebe)
	log.Debug().Msg("Tasklist Github ref = " + camundaAppVersions.Tasklist)
	log.Debug().Msg("Operate Github ref = " + camundaAppVersions.Operate)
	log.Debug().Msg("Identity Github ref = " + camundaAppVersions.Identity)

	zeebeReleaseNotes := GetLatestReleaseContents(
		ctx,
		RepoOwner,
		ZeebeRepoName,
		camundaRepoService,
		camundaAppVersions.Zeebe,
	)

	operateMonoRepoVersion, operateMonoErr := semver.NewVersion("8.5.0")
	if operateMonoErr != nil {
		log.Error().Stack().Err(operateMonoErr).Msg("Error parsing 8.5.0 version:")
		return
	}

	operateCurrentVersion, err1 := semver.NewVersion(camundaAppVersions.Operate)
	if err1 != nil {
		log.Error().Stack().Err(err1).Msg("Error parsing operate version:")
		return
	}

	var OperateRepoTag = ""
	var OperateRepoName = ""
	if(operateCurrentVersion.LessThan(operateMonoRepoVersion)) {
		OperateRepoName = "operate"
		OperateRepoTag = camundaAppVersions.Operate
	}else {
		OperateRepoName = "camunda"
		OperateRepoTag = "operate-" + camundaAppVersions.Operate
	}

	operateReleaseNotesContents := GetLatestReleaseContents(
		ctx,
		RepoOwner,
		OperateRepoName,
		camundaRepoService,
		OperateRepoTag,
	)


	tasklistReleaseNotesContents := GetChangelogReleaseContents(
		ctx,
		TasklistRepoName,
		"CHANGELOG.md",
		camundaRepoService,
		camundaAppVersions.Tasklist,
	)

	camundaCloudTokenSource := oauth2.StaticTokenSource(
		&oauth2.Token{AccessToken: os.Getenv("GITHUB_CAMUNDA_CLOUD_ACCESS_TOKEN")},
	)
	camundaCloudOAuthClient := oauth2.NewClient(ctx, camundaCloudTokenSource)
	camundaCloudGithubClient := github.NewClient(camundaCloudOAuthClient)
	camundaCloudRepoService := camundaCloudGithubClient.Repositories

	identityReleaseNotesContents := GetLatestReleaseContents(
		ctx,
		CloudRepoOwner,
		IdentityRepoName,
		camundaCloudRepoService,
		camundaAppVersions.Identity,
	)

	// Remove the Zeebe version at the beginning of Zeebe release notes to avoid confusion.
	zeebeRegex := regexp.MustCompile(`# Release 8\..+\n`)
	zeebeReleaseNotes = zeebeRegex.ReplaceAllString(zeebeReleaseNotes, "")

	platformRelease := CamundaPlatformRelease{
		Overview:             releaseOverview(camundaAppVersions),
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
