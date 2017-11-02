#load gitSemVersion.cake
#load pathUtils.cake

var target              = Argument("target", "Default");
var configuration       = Argument("configuration", "Release");

var buildDir            = AbsDirectory("./build");
var buildBinDir         = buildDir + Directory("bin");
var buildArtifactsDir   = buildDir + Directory("artifacts");

var packagesDir         = AbsDirectory("./packages");
var srcDir              = AbsDirectory("./src");

SemVersion version;
DotNetCoreMSBuildSettings msbuildProps;

Task("Default")
    .IsDependentOn("Test");

Task("Clean")
    .Does(() =>
{
    CleanDirectory(buildDir);
});

Task("Restore-NuGet-Packages")
    .IsDependentOn("Clean")
    .Does(() =>
{   
    DotNetCoreRestore(srcDir);
});

Task("Get-Version")
    .Does(() =>
{
    version = GetGitSemVersion();
    Information($"Version: {version.Full}");
});

Task("Build")
    .IsDependentOn("Get-Version")
    .IsDependentOn("Restore-NuGet-Packages")
    .Does(() =>
{
    msbuildProps = new DotNetCoreMSBuildSettings();
    msbuildProps.WithProperty("Version", version.Standard)
                .WithProperty("AssemblyVersion", version.Standard)
                .WithProperty("FileVersion", version.Full)
                .WithProperty("OutputPath", buildBinDir)
                .WithProperty("PackageVersion", version.StandardWithDirty);

    DotNetCoreBuild(srcDir, new DotNetCoreBuildSettings
    {
         Configuration = configuration,
         OutputDirectory = buildBinDir,
         MSBuildSettings = msbuildProps
    });
});

Task("Test")
    .IsDependentOn("Build")
    .Does(() =>
{
    var settings = new DotNetCoreTestSettings
    {
        NoBuild = true
    };
    DotNetCoreTest(srcDir, settings);
});

Task("Pack")
    .IsDependentOn("Test")
    .Does(() =>
{
    var settings = new DotNetCorePackSettings
    {
        NoBuild = true,
        IncludeSymbols = true,
        OutputDirectory = buildBinDir,
        MSBuildSettings = msbuildProps
    };
    DotNetCorePack(srcDir, settings);

    // rename *.symbols.nupkg to *.nupkg
    CreateDirectory(buildArtifactsDir);
    var packagesGlob = buildBinDir.Path + "/*.symbols.nupkg";
    var packages = GetFiles(packagesGlob);
    foreach(var package in packages)
    {
        var name = File(package.GetFilename().FullPath.Replace(".symbols.nupkg", ".nupkg"));
        CopyFile(package, buildArtifactsDir + name);
    }
});

Task("Publish")
    .IsDependentOn("Pack")
    .Does(() =>
{
    var publishUrl = Argument<string>("PublishUrl");
    var publishKey = Argument<string>("PublishKey");
    var settings = new NuGetPushSettings
    {
        Source = publishUrl,
        ApiKey = publishKey
    };

    var packagesGlob = buildArtifactsDir.Path + "/*.nupkg";
    var packages = GetFiles(packagesGlob);
    foreach (var package in packages)
    {
        NuGetPush(package, settings);
    }
});

RunTarget(target);
