module ciprad;

/* void[] が ubyte[] に暗黙キャストされるかどうか検証 */ version(all){
    void test(ubyte[] a){
    }

    void main(){
        void[] a;
        test(a);
    }
}

/+ 構造体内のaliasはstaticを付けなくても参照可能かどうか検証 +/ version(all){
    struct S{
        alias int i;
    }
    S.i i;
    void main(){}
}

/+ AAがCTFEで参照型かどうか検証 +/ version(none){
    void func()(auto ref int[int] aa){
        aa[0] = 2;
    }

    static assert({
        int[int] aa;
        func(aa);
        assert(aa[0] == 2);
        return true;
    }());

    void main(){}
}

/* 引数のauto refが動くかどうか検証 */ version(none){
    alias Object[size_t][string] memo_t;
    void func()(auto ref memo_t aa){
        aa["hoge"][0] = new Object;
    }

    void main(){
        memo_t aa;
        func(aa);
        import std.stdio; writeln(aa);
        func(null);
    }
}

/* std.array.joinがCTFEableかどうか検証 */ version(none){
    import std.array: join;
    pragma(msg, join(["hello", "world"], " "));
    void main(){}
}
/* T!typeof(0) が出来るかどうか検証 */ version(none){
    template temp(T){
        alias T temp;
    }

    temp!(typeof(0)) i;
    void main(){}
}

/* コピーコンストラクタをCTFEするとクラッシュするバグの検証 */ version(none){
    struct S{
        int i;
        this(this){}
    }
    static assert({
        S s1;
        S s2;
        s1 = s2;
        return true;
    }());
    void main(){}
}

/* CTFEできるPhobosモジュール調査 */ version(none){
    /* std.algorithm */ version(all){
        /* map */ version(none){
            import std.algorithm:  map;
            import std.conv:       to;
            import std.functional: adjoin;
            import std.range:      equal, chain, recurrence, repeat, isInfinite, iota,
                                   isRandomAccessRange, AllDummyRanges, propagatesRangeType;

            static assert({
                alias map!(to!string) stringize;
                assert(equal(stringize([ 1, 2, 3, 4 ]), [ "1", "2", "3", "4" ]));
                uint counter;
                alias map!((a) { return counter++; }) count;
                assert(equal(count([ 10, 2, 30, 4 ]), [ 0, 1, 2, 3 ]));
                counter = 0;
                adjoin!((a) { return counter++; }, (a) { return counter++; })(1);
                alias map!((a) { return counter++; }, (a) { return counter++; }) countAndSquare;

                int[] arr1 = [ 1, 2, 3, 4 ];
                const int[] arr1Const = arr1;
                int[] arr2 = [ 5, 6 ];
                auto squares = map!("a * a")(arr1Const);
                assert(equal(squares, [ 1, 4, 9, 16 ][]));
                assert(equal(map!("a * a")(chain(arr1, arr2)), [ 1, 4, 9, 16, 25, 36 ][]));

                // Test the caching stuff.
                assert(squares.back == 16);
                auto squares2 = squares.save;
                assert(squares2.back == 16);

                assert(squares2.front == 1);
                squares2.popFront();
                assert(squares2.front == 4);
                squares2.popBack();
                assert(squares2.front == 4);
                assert(squares2.back == 9);

                assert(equal(map!("a * a")(chain(arr1, arr2)), [ 1, 4, 9, 16, 25, 36 ][]));

                uint i;
                foreach (e; map!("a", "a * a")(arr1))
                {
                    assert(e[0] == ++i);
                    assert(e[1] == i * i);
                }

                // Test length.
                assert(squares.length == 4);
                assert(map!"a * a"(chain(arr1, arr2)).length == 6);

                // Test indexing.
                assert(squares[0] == 1);
                assert(squares[1] == 4);
                assert(squares[2] == 9);
                assert(squares[3] == 16);

                // Test slicing.
                auto squareSlice = squares[1..squares.length - 1];
                assert(equal(squareSlice, [4, 9][]));
                assert(squareSlice.back == 9);
                assert(squareSlice[1] == 9);

                // Test on a forward range to make sure it compiles when all the fancy
                // stuff is disabled.
                auto fibsSquares = map!"a * a"(recurrence!("a[n-1] + a[n-2]")(1, 1));
                assert(fibsSquares.front == 1);
                fibsSquares.popFront();
                fibsSquares.popFront();
                assert(fibsSquares.front == 4);
                fibsSquares.popFront();
                assert(fibsSquares.front == 9);

                auto repeatMap = map!"a"(repeat(1));
                static assert(isInfinite!(typeof(repeatMap)));

                auto intRange = map!"a"([1,2,3]);
                static assert(isRandomAccessRange!(typeof(intRange)));

                foreach(DummyType; AllDummyRanges)
                {
                    DummyType d;
                    auto m = map!"a * a"(d);

                    static assert(propagatesRangeType!(typeof(m), DummyType));
                    assert(equal(m, [1,4,9,16,25,36,49,64,81,100]));
                }

                auto LL = iota(1L, 4L);
                auto m = map!"a*a"(LL);
                assert(equal(m, [1L, 4L, 9L]));

                return true;
            }());
        }

        /* reduce */ version(none){
            import std.algorithm:  reduce, min, max;
            import std.range:      chain, iota;
            import std.typecons:   tuple;

            static assert({
                {
                    int[] a = [ 3, 4 ];
                    auto r = reduce!("a + b")(0, a);
                    assert(r == 7);
                    r = reduce!("a + b")(a);
                    assert(r == 7);
                    r = reduce!(min)(a);
                    assert(r == 3);
                    double[] b = [ 100 ];
                    auto r1 = reduce!("a + b")(chain(a, b));
                    assert(r1 == 107);

                    // two funs
                    version(none){
                        auto r2 = reduce!("a + b", "a - b")(tuple(0, 0), a);
                        assert(r2[0] == 7 && r2[1] == -7);
                        auto r3 = reduce!("a + b", "a - b")(a);
                        assert(r3[0] == 7 && r3[1] == -1);
                    }

                    a = [ 1, 2, 3, 4, 5 ];
                    // Stringize with commas
                    string rep = reduce!("a ~ `, ` ~ to!(string)(b)")("", a);
                    assert(rep[2 .. $] == "1, 2, 3, 4, 5", "["~rep[2 .. $]~"]");

                    // Test the opApply case.
                    static struct OpApply
                    {
                        bool actEmpty;

                        int opApply(int delegate(ref int) dg)
                        {
                            int res;
                            if(actEmpty) return res;

                            foreach(i; 0..100)
                            {
                                res = dg(i);
                                if(res) break;
                            }
                            return res;
                        }
                    }

                    OpApply oa;
                    auto hundredSum = reduce!"a + b"(iota(100));
                    assert(reduce!"a + b"(5, oa) == hundredSum + 5);
                    version(none){
                        assert(reduce!"a + b"(oa) == hundredSum);
                        assert(reduce!("a + b", max)(oa) == tuple(hundredSum, 99));
                        assert(reduce!("a + b", max)(tuple(5, 0), oa) == tuple(hundredSum + 5, 99));
                    }

                    // Test for throwing on empty range plus no seed.
                    try {
                        reduce!"a + b"([1, 2][0..0]);
                        assert(0);
                    } catch(Exception) {}

                    oa.actEmpty = true;
                    try {
                        reduce!"a + b"(oa);
                        assert(0);
                    } catch(Exception) {}
                }{
                    const float a = 0;
                    const float[] b = [ 1.2, 3, 3.3 ];
                    float[] c = [ 1.2, 3, 3.3 ];
                    auto r = reduce!"a + b"(a, b);
                    r = reduce!"a + b"(a, c);
                }

                return true;
            }());
        }

        /* fill */ version(none){
            import std.algorithm:  fill;
            import std.conv:       text;
            static assert({
                version(none){
                    int[] a = [ 1, 2, 3 ];
                    fill(a, 6);
                    assert(a == [ 6, 6, 6 ], text(a));
                    void fun0()
                    {
                        foreach (i; 0 .. 1000)
                        {
                            foreach (ref e; a) e = 6;
                        }
                    }
                    void fun1() { foreach (i; 0 .. 1000) fill(a, 6); }
                }{
                    int[] a = [ 1, 2, 3, 4, 5 ];
                    int[] b = [1, 2];
                    fill(a, b);
                    assert(a == [ 1, 2, 1, 2, 1 ]);
                }

                return true;
            }());
        }

        /* filter */ version(none){
            import std.algorithm:  filter, AllDummyRanges, map;
            import std.functional: compose, pipe;
            import std.range:      isForwardRange, equal, repeat, isInfinite, chain;
            static assert({
                {
                    int[] a = [ 3, 4, 2 ];
                    auto r = filter!("a > 3")(a);
                    static assert(isForwardRange!(typeof(r)));
                    assert(equal(r, [ 4 ][]));

                    a = [ 1, 22, 3, 42, 5 ];
                    auto under10 = filter!("a < 10")(a);
                    assert(equal(under10, [1, 3, 5][]));
                    static assert(isForwardRange!(typeof(under10)));
                    under10.front() = 4;
                    assert(equal(under10, [4, 3, 5][]));
                    under10.front() = 40;
                    assert(equal(under10, [40, 3, 5][]));
                    under10.front() = 1;

                    auto infinite = filter!"a > 2"(repeat(3));
                    static assert(isInfinite!(typeof(infinite)));
                    static assert(isForwardRange!(typeof(infinite)));

                    foreach(DummyType; AllDummyRanges) {
                        DummyType d;
                        auto f = filter!"a & 1"(d);
                        assert(equal(f, [1,3,5,7,9]));

                        static if (isForwardRange!DummyType) {
                            static assert(isForwardRange!(typeof(f)));
                        }
                    }

                    // With delegates
                    int x = 10;
                    int overX(int a) { return a > x; }
                    typeof(filter!overX(a)) getFilter()
                    {
                        return filter!overX(a);
                    }
                    auto r1 = getFilter();
                    assert(equal(r1, [22, 42]));

                    // With chain
                    auto nums = [0,1,2,3,4];
                    assert(equal(filter!overX(chain(a, nums)), [22, 42]));

                    // With copying of inner struct Filter to Map
                    auto arr = [1,2,3,4,5];
                    auto m = map!"a + 1"(filter!"a < 4"(arr));
                }{
                    int[] a = [ 3, 4 ];
                    const aConst = a;
                    auto r = filter!("a > 3")(aConst);
                    assert(equal(r, [ 4 ][]));

                    a = [ 1, 22, 3, 42, 5 ];
                    auto under10 = filter!("a < 10")(a);
                    assert(equal(under10, [1, 3, 5][]));
                    assert(equal(under10.save, [1, 3, 5][]));
                    assert(equal(under10.save, under10));

                    // With copying of inner struct Filter to Map
                    auto arr = [1,2,3,4,5];
                    auto m = map!"a + 1"(filter!"a < 4"(arr));
                }{
                    assert(equal(compose!(map!"2 * a", filter!"a & 1")([1,2,3,4,5]),
                                    [2,6,10]));
                    assert(equal(pipe!(filter!"a & 1", map!"2 * a")([1,2,3,4,5]),
                            [2,6,10]));
                }{
                    int x = 10;
                    int underX(int a) { return a < x; }
                    const(int)[] list = [ 1, 2, 10, 11, 3, 4 ];
                    assert(equal(filter!underX(list), [ 1, 2, 3, 4 ]));
                }
                return true;
            }());
        }

        /* move */ version(none){
            import std.algorithm:  move, hasElaborateDestructor, hasElaborateCopyConstructor;
            static assert({
                Object obj1 = new Object;
                Object obj2;
                move(obj1, obj2);
                assert(obj1 is obj2);

                static struct S1 { int a = 1, b = 2; }
                S1 s11 = { 10, 11 };
                S1 s12;
                version(none){
                    move(s11, s12);
                    assert(s11.a == 10 && s11.b == 11 && s12.a == 10 && s12.b == 11);
                }

                static struct S2 { int a = 1; int * b; }
                S2 s21 = { 10, null };
                s21.b = new int;
                S2 s22;
                move(s21, s22);
                assert(s21 == s22);

                // Issue 5661 test(1)
                static struct S3
                {
                    static struct X { int n = 0; ~this(){n = 0;} }
                    X x;
                }
                static assert(hasElaborateDestructor!S3);
                S3 s31, s32;
                s31.x.n = 1;
                move(s31, s32);
                assert(s31.x.n == 0);
                assert(s32.x.n == 1);

                // Issue 5661 test(2)
                static struct S4
                {
                    static struct X { int n = 0; this(this){n = 0;} }
                    X x;
                }
                static assert(hasElaborateCopyConstructor!S4);
                S4 s41, s42;
                s41.x.n = 1;
                move(s41, s42);
                assert(s41.x.n == 0);
                assert(s42.x.n == 1);
            }());
        }

        /* moveAll, moveSome */ version(none){
            import std.algorithm:  moveAll, moveSome;
            import std.conv:       to;
            static assert({
                {
                    int[] a = [ 1, 2, 3 ];
                    int[] b = [0, 0, 0, 0, 0];
                    moveAll(a, b);
                    //assert(a == b[0..3]);
                }{
                    int[] a = [1, 2, 3, 4, 5];
                    int[] b = [0, 0, 0];
                    moveSome(a, b);
                    //assert(a[0..3] == b);
                }
                return true;
            }());
        }

        /* swap */ version(none){
            import std.algorithm:  swap;
            static assert({
                int a = 42, b = 34;
                swap(a, b);
                assert(a == 34 && b == 42);

                static struct S { int x; char c; int[] y; }
                S s1 = { 0, 'z', [ 1, 2 ] };
                S s2 = { 42, 'a', [ 4, 6 ] };
                swap(s1, s2);
                assert(s1.x == 42);
                assert(s1.c == 'a');
                assert(s1.y == [ 4, 6 ]);

                assert(s2.x == 0);
                assert(s2.c == 'z');
                assert(s2.y == [ 1, 2 ]);

                immutable int imm1, imm2;
                static assert(!__traits(compiles, swap(imm1, imm2)));

                static struct NoCopy
                {
                    this(this){ assert(0); }
                    int n;
                    string s;
                }
                NoCopy nc1, nc2;
                nc1.n = 127; nc1.s = "abc";
                nc2.n = 513; nc2.s = "uvwxyz";
                version(none){
                swap(nc1, nc2);
                assert(nc1.n == 513 && nc1.s == "uvwxyz");
                assert(nc2.n == 127 && nc2.s == "abc");
                swap(nc1, nc1);
                swap(nc2, nc2);
                assert(nc1.n == 513 && nc1.s == "uvwxyz");
                assert(nc2.n == 127 && nc2.s == "abc");
                }

                version(none){
                static struct NoCopyHolder
                {
                    NoCopy noCopy;
                }
                NoCopyHolder h1, h2;
                h1.noCopy.n = 31; h1.noCopy.s = "abc";
                h2.noCopy.n = 65; h2.noCopy.s = null;
                swap(h1, h2);
                assert(h1.noCopy.n == 65 && h1.noCopy.s == null);
                assert(h2.noCopy.n == 31 && h2.noCopy.s == "abc");
                swap(h1, h1);
                swap(h2, h2);
                assert(h1.noCopy.n == 65 && h1.noCopy.s == null);
                assert(h2.noCopy.n == 31 && h2.noCopy.s == "abc");

                const NoCopy const1, const2;
                static assert(!__traits(compiles, swap(const1, const2)));
                }
                return true;
            }());
        }

        /* splitter */ version(all){
            import std.algorithm:  splitter;
            import std.range:      equal, isForwardRange, retro, array, iota, AllDummyRanges, isRandomAccessRange, isBidirectionalRange;
            static assert({
                assert(equal(splitter("hello  world", ' '), [ "hello", "", "world" ]));
                int[] a = [ 1, 2, 0, 0, 3, 0, 4, 5, 0 ];
                int[][] w = [ [1, 2], [], [3], [4, 5], [] ];
                static assert(isForwardRange!(typeof(splitter(a, 0))));

                // foreach (x; splitter(a, 0)) {
                //     writeln("[", x, "]");
                // }
                assert(equal(splitter(a, 0), w));
                a = null;
                assert(equal(splitter(a, 0), [ (int[]).init ][]));
                a = [ 0 ];
                assert(equal(splitter(a, 0), [ (int[]).init, (int[]).init ][]));
                a = [ 0, 1 ];
                assert(equal(splitter(a, 0), [ [], [1] ][]));

                // Thoroughly exercise the bidirectional stuff.
                auto str = "abc abcd abcde ab abcdefg abcdefghij ab ac ar an at ada";
                assert(equal(
                    retro(splitter(str, 'a')),
                    retro(array(splitter(str, 'a')))
                ));

                // Test interleaving front and back.
                auto split = splitter(str, 'a');
                assert(split.front == "");
                assert(split.back == "");
                split.popBack();
                assert(split.back == "d");
                split.popFront();
                assert(split.front == "bc ");
                assert(split.back == "d");
                split.popFront();
                split.popBack();
                assert(split.back == "t ");
                split.popBack();
                split.popBack();
                split.popFront();
                split.popFront();
                assert(split.front == "b ");
                assert(split.back == "r ");

                foreach(DummyType; AllDummyRanges) {  // Bug 4408
                    static if(isRandomAccessRange!DummyType) {
                        static assert(isBidirectionalRange!DummyType);
                        DummyType d;
                        auto s = splitter(d, 5);
                        assert(equal(s.front, [1,2,3,4]));
                        assert(equal(s.back, [6,7,8,9,10]));


                        auto s2 = splitter(d, [4, 5]);
                        assert(equal(s2.front, [1,2,3]));
                        assert(equal(s2.back, [6,7,8,9,10]));
                    }
                }
                auto L = retro(iota(1L, 10L));
                auto s = splitter(L, 5L);
                assert(equal(s.front, [9L, 8L, 7L, 6L]));
                s.popFront();
                assert(equal(s.front, [4L, 3L, 2L, 1L]));
                s.popFront();
                assert(s.empty);
                return true;
            }());
        }
    }

    void main(){}
}

version(none){
    template t(T, F){
        enum t = 0;
    }

    void main(){
        auto i = t!(
#line 5
A!(),
#line 7
B!());
    }
}

version(none){
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
