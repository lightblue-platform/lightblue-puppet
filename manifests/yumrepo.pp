# Initializes additional repositories: jbeap, jbeaptools, lightblue
class lightblue::yumrepo {
    include lightblue::yumrepo::jbeap
    include lightblue::yumrepo::jbeaptools
    include lightblue::yumrepo::lightblue
}
