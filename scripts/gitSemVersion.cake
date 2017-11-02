public class SemVersion 
{
    public string Major {get; set;}
    public string Minor {get; set;}
    public string Patch {get; set;}
    public string Hash {get; set;}
    public string Dirty {get; set;}

    public string Standard
    {
        get { return string.Format("{0}.{1}.{2}", Major, Minor, Patch); }
    }

    public string StandardWithDirty
    {
        get 
        {
            return string.IsNullOrWhiteSpace(Dirty)
                    ? Standard
                    : string.Format("{0}-{1}", Standard, Dirty); 
        }
    }

    public string Full
    {
        get 
        {
            var full = string.Format("{0}-{1}", Standard, Hash);
            return string.IsNullOrWhiteSpace(Dirty)
                    ? full
                    : string.Format("{0}-{1}", full, Dirty); 
        }
    }
}

public SemVersion GetGitSemVersion()
{
    var command = new ProcessSettings
    {
        Arguments = "describe --abbrev=7 --first-parent --long --dirty --always",
        RedirectStandardOutput = true
    };

    IEnumerable<string> output;
    var exitCode = StartProcess("git", command, out output);
    if (exitCode != 0) 
    {
        throw new Exception(string.Format("Failed to define version with Git. ErrorCode {0}", exitCode));
    }

    var describe = output.Single();
    Verbose("Executing 'git describe' command: {0}", describe);

    var annotatedTagPattern = @"(?<major>[0-9]+).(?<minor>[0-9]+)-(?<patch>[0-9]+)-g(?<hash>[\w]+)-?(?<dirty>[\w]+)*";
    var parts = System.Text.RegularExpressions.Regex.Match(describe, annotatedTagPattern);

    var major = "0";
    var minor = "0";
    var patch = "0";
    var hash = string.Empty;
    var dirty = string.Empty;

    if (parts.Success)
    {
        major = parts.Groups["major"].Value;
        minor = parts.Groups["minor"].Value;
        patch = parts.Groups["patch"].Value;
        hash = parts.Groups["hash"].Value;
        dirty = parts.Groups["dirty"].Value;
    }
    else
    {
        var tokens = describe.Split('-');
        hash = tokens[0];
        if (tokens.Length > 1)
            dirty = tokens[1];
    }

    return new SemVersion
    {
        Major = major,
        Minor = minor,
        Patch = patch,
        Hash = hash,
        Dirty = dirty
    };
}