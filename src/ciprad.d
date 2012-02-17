module ciprad;
version(all){
    template temp(T){
        void temp(U)(U u){
            import std.stdio;writeln(u);
        }
    }
    void main(){
        temp!int("hello");
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

version(all){
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
        auto s2 = s;
        s2.i = 2;
    }
}
