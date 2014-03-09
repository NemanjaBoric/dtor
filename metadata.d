import std.file, std.stdio;
import bencode;
import std.variant;

Variant decodeMetafile(string path)
{
    auto data = cast(ubyte[])read(path);
    return bencode.bdecode(data);
}

string print(Variant data)
{
    return cast(string)(cast(char[])*data.peek!(ubyte[]));
}

Variant[string] toDict(Variant data)
{
    return *data.peek!(Variant[string]);
}


unittest
{
    auto data = decodeMetafile("test.torrent");
    writeln(data["announce"].print());
    writeln(data["comment"].print());
    writeln(data["info"].toDict()["length"]); //.toDict["lenght"].print());

}

