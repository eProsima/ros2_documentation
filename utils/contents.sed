/^\.\. contents::/ {
    N
    /^\.\. contents::.*\n\s*:/ {
        :loop
        N
        /\n\s*$/!b loop
        d
    }
}
