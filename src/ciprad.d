module ciprad;

version(all){
    void main(){
        const(char)[3] ary = ['a', 'b', 'c'];
        char[3] ary2;
        ary2 = ary;
    }
}

version(none){
    struct S{}
    pragma(msg, S.stringof);
    void main(){}
}

version(none){
    unittest{
        enum dg = {
            cast(void)__LINE__;
            /* \0 <= "hoge" */ mixin(generateUnittest(q{
                auto result = getResult!(parseNone!())(@1);
                assert(result.match);
                assert(result.rest == positional(@2, 1, 1));
            }, "hoge", "hoge"));
        };
    }

    string generateUnittest(string file = __FILE__, int line = __LINE__)(string src, string input, string rest){
        pragma(msg, line);
        return "";
    }

    void main(){}
}

version(none){
    void main(){
        mixin(q{mixin("pragma(msg, __LINE__);\npragma(msg, __LINE__);");mixin("pragma(msg, __LINE__);\npragma(msg, __LINE__);");});
    }
}

version(none){
    bool func(int line = __LINE__)(string str, int i){
        pragma(msg, line);
        return true;
    }

    string func2(int line = __LINE__)(string str, int i){
        pragma(msg, line);
        return "{}";
    }

    void main(){
        mixin(func2(q{

        }, 0));

        static assert(func(q{

        }, 0));

        assert(func(q{

        }, 0));
        
        static assert(func(q{

        }, 0));
    }
}

version(none){
    import std.stdio;

    struct Code(T, string src){
    }

    final class Hoge{
      void exec(T)() {
        static if(is(T Unused == Code!(S, src), S, string src) && is(S == typeof(this))){
          mixin(src);
        }else static assert(false);
      }
    }

    void main() {
      auto h = new Hoge;
      h.exec!(Code!(Hoge,"writeln(13);"))();
    }
}

version(none){
    enum str = "pragma(msg, __LINE__);\npragma(msg, __LINE__);\npragma(msg, __LINE__);\npragma(msg, __LINE__);\npragma(msg, __LINE__);";
    mixin(str);
    static assert(false);
}

version(none){
    string testMaker(string src, string input, string rest, string file = __FILE__, int line = __LINE__){
        import std.array;
        auto result = appender!string();
        foreach(idx; 0..6){
            import std.conv; result.put("#line " ~ to!string(line) ~ " \"" ~ file ~ ": ");
            final switch(idx){
                case 0:{
                    result.put("string\"\n");
                    result.put(src.replace("@", "\"" ~ input ~ "\"").replace("#", "\"" ~ rest ~ "\""));
                    break;
                }
                case 1:{
                    result.put("wstring\"\n");
                    result.put(src.replace("@", "\"" ~ input ~ "\"w").replace("#", "\"" ~ input ~ "\"w"));
                    break;
                }
                case 2:{
                    result.put("dstring\"\n");
                    result.put(src.replace("@", "\"" ~ input ~ "\"d").replace("#", "\"" ~ input ~ "\"d"));
                    break;
                }
                case 3:{
                    result.put("TestRange!char\"\n");
                    result.put(src.replace("@", "testRange(\"" ~ input ~ "\")").replace("#", "testRange(\"" ~ input ~ "\")"));
                    break;
                }
                case 4:{
                    result.put("TestRange!wchar\"\n");
                    result.put(src.replace("@", "testRange(\"" ~ input ~ "\"w)").replace("#", "testRange(\"" ~ input ~ "\"w)"));
                    break;
                }
                case 5:{
                    result.put("TestRange!dchar\"\n");
                    result.put(src.replace("@", "testRange(\"" ~ input ~ "\"d)").replace("#", "testRange(\"" ~ input ~ "\"d)"));
                    break;
                }
            }
        }
        return result.data;
    }
    void main(){
        import std.stdio; writeln(test(`
            assert(@);
            assert(#);
        `, "hello", "world"));
    }
}

version(none){
    template temp(T){
        void temp(U)(U u){
            import std.stdio;writeln(u);
        }
    }
    template hoge(){
        template hoge2(){
            enum hoge2 = "hello";
        }
    }
    void main(){
        temp!int("hello");
        auto s = hoge!().hoge2!();
    }
}

version(none){
    import std.typecons;
    void main(){
        bool[Tuple!(int, int, string)] aa;
        aa[tuple(1, 1, "hello")] = true;
        assert(tuple(1, 1, "hello") in aa);
    }

    static assert({
        main();
        return true;
    }());
}

version(none){
    struct S{
        int i;
    }

    static assert({
        S s = S(1);
        assert(s.i == 1);
        fun(s);
        assert(s.i == 1); // fails!!
        return true;
    }());

    void fun(S s){
        s.i = 2;
    }
}
