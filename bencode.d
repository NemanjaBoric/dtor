module bencode;

import std.stdio;
import std.string;
import std.variant;
import std.conv;
import std.exception;
import std.c.stdlib;
import std.utf;
int indexOf(ubyte[] data, ubyte c)
{
    for(int i = 0; i < data.length; i++)
    {
        if(data[i] == c)
            return i;
    }

    return -1;
}



ubyte[] bdecode_string(ref ubyte[] segment)
{
    auto colon = segment.indexOf(':');


    if(colon == -1)
    {
        // invalid string, throw exception
        throw new Exception("Invalid data");
    }

    auto i = 0;

    i = to!(int)(cast(string)(cast(char[])(segment[0 .. colon])));


    // slicing creates new array
    auto ret =  segment[colon + 1 .. colon + 1 + i];

    segment = segment[colon + 1 + i .. $];
    return ret;
}

int bdecode_int(ref ubyte[] segment)
{
    auto i = segment.indexOf('i');
    auto e = segment.indexOf('e');

    if(i == -1 || e == -1)
    {
        throw new Exception("Invalid data");
    }

    auto seg = segment[i + 1 .. e];

    // leading zero not allowed
    if(seg.length > 1 && seg[0] == '0')
    {
        throw new Exception("Leading zero not allowed");
    }

    if(seg == "-0")
    {
        throw new Exception("Negative zero not allowed");
    }
    
    auto ret = to!(int)(cast(string)(cast(char[])(seg)));

    segment = segment[e + 1 .. $];

    return ret;

}

Variant[] bdecode_list(ref ubyte[] segment)
{
    Variant[] lst;

    segment = segment[1 .. $];
    auto i = 0;
    while(segment.length > 0 && segment[0] != 'e')
    {
       if(segment[i] == 'i')
           lst ~= Variant(bdecode_int(segment));
       else if(segment[i] == 'l')
           lst ~= Variant(bdecode_list(segment));
       else if(segment[i] == 'd')
           lst ~= Variant(bdecode_dict(segment));
       else
           lst ~= Variant(bdecode_string(segment));

    }

    segment = segment[1 .. $];

    return lst;
}

Variant[string] bdecode_dict(ref ubyte[] segment)
{
    Variant[string] lst;

    segment = segment[1 .. $];
    auto i = 0;
    while(segment.length > 0 && segment[0] != 'e')
    {
        auto key = cast(string)(cast(char[])(bdecode_string(segment)));

        if(segment[i] == 'i')
           lst[key] = Variant(bdecode_int(segment));
        else if(segment[i] == 'l')
           lst[key] = Variant(bdecode_list(segment));
        else if(segment[i] == 'd')
           lst[key] = Variant(bdecode_dict(segment));
        else
           lst[key] = Variant(bdecode_string(segment));

    }

    segment = segment[1 .. $];

    return lst;

}


Variant bdecode(ref ubyte[] segment)
{
    Variant lst;
    auto i = 0;
    if(segment.length > 0)
    {
        if(segment[i] == 'i')
           lst = Variant(bdecode_int(segment));
        else if(segment[i] == 'l')
           lst = Variant(bdecode_list(segment));
        else if(segment[i] == 'd')
           lst = Variant(bdecode_dict(segment));
        else
           lst = Variant(bdecode_string(segment));
    }

    return lst;

}

unittest
{
/*    ubyte data = "5:hello5:trust6:twiste0:i42ei0ei-42eli21e5:helloli10e3:tstei-5ed9:publisher3:bob17:publisher-webpage15:www.example.com18:publisher.location4:homeee";

    assert(bdecode_string(data) == "hello");
    assert(bdecode_string(data) == "trust");
    assert(bdecode_string(data) == "twiste");

    assert(bdecode_int(data) == 42);
    assert(bdecode_int(data) == 0);
    assert(bdecode_int(data) == -42);
    
    string mal_data1 = "i042e";
    string mal_data2 = "i-0e";

    assertThrown(bdecode_int(mal_data1));
    assertThrown(bdecode_int(mal_data2));


    writeln(bdecode(data));

    
*/

}


