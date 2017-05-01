import Result

enum LibraryName {
    case
    gitHub(owner: String, repo: String),
    name(String)

    var repoName: String {
        switch self {
        case .gitHub(_, let repo): return repo
        case .name(let name): return name
        }
    }

    var owner: String? {
        switch self {
        case .gitHub(let owner, _): return owner
        case .name: return nil
        }
    }
}

extension LibraryName: Equatable {

    public static func ==(lhs: LibraryName, rhs: LibraryName) -> Bool {
        switch lhs {
        case .gitHub(let owner_l, let repo_l):
            switch rhs {
            case .gitHub(let owner_r, let repo_r):
                return owner_l == owner_r && repo_l == repo_r
            case .name:
                return false
            }
        case .name(let name_l):
            switch rhs {
            case .gitHub:
                return false
            case .name(let name_r):
                return name_l == name_r
            }
        }
    }
}

extension LibraryName: Hashable {
    var hashValue: Int {
        return self.repoName.hash
    }


}
