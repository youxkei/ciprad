module ciprad;

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
