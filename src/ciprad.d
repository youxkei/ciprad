module ciprad;

version(all){
    pragma(lib, "DerelictUtil.lib");
    pragma(lib, "DerelictSDL2.lib");

    import derelict.sdl2.sdl;
    import std.stdio;
    import std.file: chdir;

    void main(){
        chdir("slib");
        DerelictSDL2.load();
        chdir("..");
        scope(exit) DerelictSDL2.unload();

        SDL_Init(SDL_INIT_VIDEO);
        SDL_GL_DOUBLEBUFFER.SDL_GL_SetAttribute(1);
        scope(exit) SDL_Quit();
        SDL_Window* window = SDL_CreateWindow("test", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, 640, 480, SDL_WINDOW_OPENGL);
        SDL_GLContext context = SDL_GL_CreateContext(window);

        SDL_Event ev;
        while(true){
            SDL_PollEvent(&ev);
            switch(ev.type){
                case SDL_QUIT:{
                    return;
                }
                default:{
                }
            }
            SDL_GL_SwapWindow(window);
        }
    }
}

version(none){
    template a(alias b){
        enum a = 2;
    }
    template b(){
    }
    void main(){
        auto i = a!(#line 5
c!());
    }
}

version(none){
    template t(alias f){
        enum t = f.stringof;
    }

    template a(int i){}

    void main(){
        pragma(msg, t!(a));
    }
}

version(none){
    import std.range;
    import std.traits;
    import std.conv;

    struct Result(Range, T){
        public{
            bool match;
            Input!Range rest;

            pure @safe nothrow
            void opAssign(U)(Result!(Range, U) rhs)if(isAssignable!(T, U)){
                match = rhs.match;
                value = rhs.value;
                rest = rhs.rest;
                error = rhs.error;
            }
        }
    }
    struct TestRange(T){
        static assert(isForwardRange!(typeof(this)));
        immutable(T)[] source;
        @property T front(){ return source[0]; }
        @property void popFront(){ source = source[1..$]; }
        @property bool empty(){ return source.length == 0; }
        @property TestRange save(){ return this; }
    }

    TestRange!(T) testRange(T)(immutable(T)[] source){
        return TestRange!T(source);
    }
    struct Input(Range){
        static assert(isForwardRange!Range && isSomeChar!(ElementType!Range));

        invariant(){}

        public{
            Range range;

            //cannot apply some qualifiers due to unclearness of Range
            Input save(){
                return this;
            }
        }
    }

    Input!Range makeInput(Range)(Range range){
        return Input!Range(range);
    }
    template parseSpace(){
        alias string ResultType;
        Result!(Range, ResultType) parse(Range)(Input!Range input){
        typeof(return) result;
            if(!input.range.empty){
                Unqual!(ElementType!Range) c = input.range.front;
                if(c == ' ' || c == '\n' || c == '\t' || c == '\r' || c == '\f'){
                    result.match = true;
                    input.range.popFront;
                    result.rest.range = input.range;
                    return result;
                }
            }
            return result;
        }
    }

    template combinateMore(alias parser){
        Result!(Range, string[]) parse(Range)(Input!Range input){
            typeof(return) result;
            Input!Range rest = input;
            while(true){
                auto r = rest.save;
                auto r1 = parser.parse(r);
                if(r1.match){
                    rest = r1.rest;
                }else{
                    break;
                }
            }
            result.match = true;
            result.rest = rest;
            return result;
        }
    }

    static assert({
        auto r = combinateMore!(parseSpace!()).parse(makeInput(testRange("\t"))); 
        return true;
    }());

    void main(){}
}

version(none){
    struct S{
        int i;
        int j;
        int k;
        int l;
    }

    void main(){
        assert(S(1, 2, 3, 4) == S(1, 2, 3, 4));
        assert(S(1, 2, 3, 4) != S(1, 2, 4, 8));
    }
}

version(none){
    class S{
        int i;
        this(int i){
            this.i = i;
        }
    }

    void f(S s){
        import std.stdio; writeln(s.i);
    }

    void main(){
        auto s = new S(6);
        s.f();
    }
}

version(none){
    struct Range{
        string[] str;
        this(string str){
            this.str ~= str;
        }
        char front(){
            return str[0][0];
        }
        void popFront(){
            str[0] = str[0][1..$];
        }
        typeof(this) save(){
            return Range(str[0]);
        }
    }

    static assert({
        Range range = Range("hello");
        auto range2 = range;
        assert(range.front == 'h');
        assert(range2.front == 'h');
        range.popFront;
        assert(range.front == 'e');
        assert(range2.front == 'e');
        return true;
    }());

    void main(){}
}

version(none){
    pragma(msg, __traits(compiles, error));
    template error(bool b, alias a){
        static if(b){
            alias b error;
        }else{
            static assert(false);
        }
    }
    template t(a...){
        enum t = a[0].stringof;
    }

    pragma(msg, f());

    @property int f(){
        return 2;
    }


    void main(){}
}

version(none){
    void main(){
        Hoge a;
        import std.stdio; writeln(a);
    }

    struct Hoge{
        int[2] _val;
        alias _val this;
    }
}

version(none){
    struct None{
        bool i;
    }
    void main(){
        import std.typecons; import std.stdio; writeln(None.sizeof);
    }
}

version(none){
    void result(T)(T a){}

    void main(){
        int result = 0;
        .result!int(result);
    }
}

version(none){
    import std.array;
    static assert({
        enum size = 1024 * 1024;
        pragma(msg, size);
        char[size] data;
        char* str = data.ptr;
        foreach(idx; 0..size/2){
            str[idx*2..idx*2+2] = ['a', 'b'];
        }
        return true;
    }());

    void main(){}
}

version(none){
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
