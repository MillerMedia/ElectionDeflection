import IdentityLookup

final class MessageFilterExtension: ILMessageFilterExtension {
    // List of keywords to filter
    var keywords: [String] = ["trump", "vance", "harris", "walz", "election", "vote", "campaign", "giuliani", "kamala", "democrat", "republican", "senate", "cruz", "congress", "impeach", "ballot", "radical left", "far right", "cmp.lk", "jim jordan", "fundprogress", "dems ", "gop ", " gop:", "kellyanne conway", "steve garvey", "gov. abbott", "governor abbott", "win4tx.org", "biden", "potus", " dems ", "left-wing", "right-wing", "super pac", "actblue", "winred", "dnc ", "rnc ", "pelosi", "chuck schumer", "mitch mcconnell", "lindsey graham", "bernie sanders", "elizabeth warren", "alexandria ocasio-cortez", "aoc ", "ron desantis", "mike pence", "nikki haley", "newsom", "marjorie taylor greene", "matt gaetz", "lauren boebert", "kevin mccarthy", "dm24.co", "bob casey", "dave mccormick", "rep-24", "reagan", "usred.co", "kari lake", "hannity", "maddow", "24-red", "gop-victory.com", "vivek", "ramaswamy", "cheney", "clinton", "obama", "dan osborn", "deb fischer", "vote24.io", "savedemocracypac", "letamericavote", "momsfedup", "lincoln project", "electdemsnow", "boldpac", "hmpac", "electdemocracticwomen", "bluewave", "demmajority", "retireddemocrat", "demgovs", "tim kaine", "trustrightusa", "israelsrvy", "cbcpac", "colin allred", "colinallred.com", "24win.co", "blue wave", "goplink", "tth07", "runityfund", "right-24", "pompeo", "gv077.org", "byron donalds", "gop.", "demturnout", "turnout", "go-24", "tammy baldwin", "fundraising", "elissa slotkin", "haley stevens", "haley4mi", "realclearpolitics", "shawn harris", "charlie kirk", "tpusa", "turning point", "laura loomer", "newt gingrich", "safegive24", "win24", "presidential poll", "drain the swamp", "trustgopusa", "deep state", " cnn ", " msnbc ", " fox news ", "dems-vote", "schiff", "secureliberty", "garvey", "anna paulina luna", "doj", "givegopnow", "robert f. kennedy", "rfk", "ron johnson", "senator", "rep.", "team mackenzie", "the left", "derrick van orden", "kennedy", "rubio", "for.gop", "hawley", " sen. ", "clarence thomas", "patriot", "donor", "gopgift", "nancy mace", "jack smith", "soros", ".gop/", "bannon", "stephen miller", "usgiv", "gv070", "growth action", "kyrsten sinema", "ruben gallego", "kari lake", "rick scott", "mucarsel-powell", "ben cardin", "alsobrooks", "larry hogan", "mike rogers", "stabenow", "slotkin", "jon tester", "tim sheehy", "manchin", "klobuchar", "josh hawley", "romney", "electoral", "don jr", " maga ", "blue victory", "bluevictory", "gv088.org", "8x match", "9x match", "10x match", "gopclick.io", "redsend.net", "hegseth", "scalise", "giv.win", "gv099", "2024wave", "vtred", "gv000", "gv001", "gv002", "gv003", "gv004", "gv005", "gv006", "gv007", "gv008", "gv009", "gv010", "gv011", "gv012", "gv013", "gv014", "gv015", "gv016", "gv017", "gv018", "gv019", "gv020", "gv021", "gv022", "gv023", "gv024", "gv025", "gv026", "gv027", "gv028", "gv029", "gv030", "gv031", "gv032", "gv033", "gv034", "gv035", "gv036", "gv037", "gv038", "gv039", "gv040", "gv041", "gv042", "gv043", "gv044", "gv045", "gv046", "gv047", "gv048", "gv049", "gv050", "gv051", "gv052", "gv053", "gv054", "gv055", "gv056", "gv057", "gv058", "gv059", "gv060", "gv061", "gv062", "gv063", "gv064", "gv065", "gv066", "gv067", "gv068", "gv069", "gv070", "gv071", "gv072", "gv073", "gv074", "gv075", "gv076", "gv077", "gv078", "gv079", "gv080", "gv081", "gv082", "gv083", "gv084", "gv085", "gv086", "gv087", "gv088", "gv089", "gv090", "gv091", "gv092", "gv093", "gv094", "gv095", "gv096", "gv097", "gv098", "gv099", "gv100", "gv101", "gv102", "gv103", "gv104", "gv105", "gv106", "gv107", "gv108", "gv109", "gv110", "gv111", "gv112", "gv113", "gv114", "gv115", "gv116", "gv117", "gv118", "gv119", "gv120", "gv121", "gv122", "gv123", "gv124", "gv125", "gv126", "gv127", "gv128", "gv129", "gv130", "gv131", "gv132", "gv133", "gv134", "gv135", "gv136", "gv137", "gv138", "gv139", "gv140", "gv141", "gv142", "gv143", "gv144", "gv145", "gv146", "gv147", "gv148", "gv149", "gv150", "gv151", "gv152", "gv153", "gv154", "gv155", "gv156", "gv157", "gv158", "gv159", "gv160", "gv161", "gv162", "gv163", "gv164", "gv165", "gv166", "gv167", "gv168", "gv169", "gv170", "gv171", "gv172", "gv173", "gv174", "gv175", "gv176", "gv177", "gv178", "gv179", "gv180", "gv181", "gv182", "gv183", "gv184", "gv185", "gv186", "gv187", "gv188", "gv189", "gv190", "gv191", "gv192", "gv193", "gv194", "gv195", "gv196", "gv197", "gv198", "gv199", "gv200", "r-txt.com", "r-txt.org", "r-txt.net", "alvin bragg", "kathy hocul", "giv.red", "greg abbott", "tx-win", "kash patel", "magaus", "20giv", "mike johnson", "chip24", "glenn youngkin", "tulsi gabbard", "franklin graham", "gop25", "gop24", "gop26", "gop27", "gop28", "gop29", "gop30", "gop31", "gop32", "gop33", "gop34", "gop35", "gop36", "gop37", "gop45", "gop47", "america first alliance", "redvt.cc", "saveusa", " gop's ", "djt", "DOGE", "D.O.G.E.", "gop1poll", "elise stefanik", "stefanik", "house majority", "epstein files", "speaker johnson", "fundnow", "fake news", "leftist", "eli crane", "democracyfirstpac"
    ]
    
    // Dictionary mapping keywords to their whitelisted contexts
    var whitelistContexts: [String: [String]] = [
        "kennedy": [
            "kennedy center",
            "kennedy center honors",
            "kennedy space center"
        ],
        "vote": [
            "batterysf.com/v/",
            "battery powered vote",
            "san francisco resurgence vote",
            "battery sf vote"
        ],
        "voting": [
            "batterysf.com/v/",
            "battery powered voting",
            "san francisco resurgence voting",
            "battery sf voting"
        ],
        "election": [
            "ballot.trax"
        ],
        "ballot": [
            "ballot.trax"
        ],
        "reply stop": [
            ".edu"
        ]
    ]

    // Combined terms that should be filtered when they appear together
    var combinedTerms: [[String]] = [
        ["musk", "stop=end"],
        ["musk", "stop to end"],
        ["musk", "reply stop"],
        ["musk", "stop2end"],
        ["elon", "stop=end"],
        ["elon", "stop to end"],
        ["elon", "reply stop"],
        ["elon", "stop2end"],
        ["democracy", "stop=end"],
        ["democracy", "stop to end"],
        ["democracy", "reply stop"],
        ["democracy", "stop2end"],
    ]

    override init() {
        super.init()
        print("MessageFilterExtension initialized")
        print("Loaded keywords: \(self.keywords.count) keywords")
        print("Loaded whitelist contexts: \(self.whitelistContexts.count) contexts")
        print("Loaded combined terms: \(self.combinedTerms.count) combinations")
    }

    private func isKeywordInWhitelistedContext(_ keyword: String, in messageBody: String) -> Bool {
        guard let whitelistedPhrases = whitelistContexts[keyword.lowercased()] else {
            return false
        }
        
        // Get the surrounding context of the keyword
        for whitelistedPhrase in whitelistedPhrases {
            if messageBody.lowercased().contains(whitelistedPhrase.lowercased()) {
                print("Keyword '\(keyword)' found in whitelisted context: '\(whitelistedPhrase)'")
                return true
            }
        }
        
        return false
    }
    
    // Check if message contains any of the combined terms
    private func containsCombinedTerms(_ messageBody: String) -> Bool {
        let lowercaseMessage = messageBody.lowercased()
        
        for termGroup in combinedTerms {
            // Check if all terms in the group are present in the message
            if termGroup.allSatisfy({ lowercaseMessage.contains($0.lowercased()) }) {
                print("Combined terms detected: \(termGroup.joined(separator: ", "))")
                return true
            }
        }
        
        return false
    }
    


    private func determineAction(for messageBody: String) -> ILMessageFilterAction {
        // Debug: Print the message being evaluated (truncated for privacy)
        let truncatedMessage = messageBody.prefix(30)
        print("Evaluating message: \(truncatedMessage)...")
        
        // First check combined terms (higher priority)
        if containsCombinedTerms(messageBody) {
            print("Combined terms found, categorizing as Promotion")
            return .junk
        }
        
        // Then check individual keywords
        for keyword in keywords {
            if messageBody.lowercased().contains(keyword.lowercased()) {
                // If keyword found, check if it's in a whitelisted context
                if isKeywordInWhitelistedContext(keyword, in: messageBody) {
                    print("Keyword '\(keyword)' found in whitelisted context, allowing message")
                    continue // Continue checking other keywords
                } else {
                    print("Keyword matched: \(keyword), categorizing as Promotion")
                    return .junk
                }
            }
        }
        
        print("No criteria matched, allowing the message")
        return .allow
    }
}

extension MessageFilterExtension: ILMessageFilterQueryHandling {
    func handle(_ queryRequest: ILMessageFilterQueryRequest, context: ILMessageFilterExtensionContext, completion: @escaping (ILMessageFilterQueryResponse) -> Void) {
        let response = ILMessageFilterQueryResponse()
        
        if let messageBody = queryRequest.messageBody {
            response.action = determineAction(for: messageBody)
        } else {
            print("No message body found.")
            response.action = .allow
        }
        
        print("Action taken: \(response.action == .allow ? "Allow" : "Promotion")")
        
        completion(response)
    }
}
