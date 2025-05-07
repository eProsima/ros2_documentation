/\.\. tabs::/ {
    s/\.\. tabs::/.. tab-set::/
    }

/\.\. tab::/ {
    s/\.\. tab::/.. tab-item::/
    }

/\.\. group-tab::/ {
    s/\(\s*\)\.\. group-tab::\(.*\)/\1.. tab-item::\2\n:sync:\2/
    }
