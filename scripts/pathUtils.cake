public ConvertableDirectoryPath AbsDirectory(string path)
{
    return Directory(MakeAbsolute(Directory(path)).FullPath);
}