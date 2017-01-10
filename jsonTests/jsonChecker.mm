//
// jsonChecker.mm
// jsonTests
//
// Created by Mathieu Garaud on 09/08/16.
//
// MIT License
//
// Copyright © 2016 Pretty Simple
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

#import <XCTest/XCTest.h>
#import <json/json.hpp>
#include <exception>
#include <iostream>

/**
 Implements the test based on the information provided on this website: http://www.json.org/JSON_checker/
 */
@interface jsonChecker : XCTestCase

@end

@implementation jsonChecker

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

static bool fail(const std::string& json)
{
    bool ret = false;
    json::Document doc;
    try {
        doc.deserialize(json);
    } catch (const std::exception& e) {
        ret = true;
    }
    return ret;
}

// Ignore this test based on this article: http://seriot.ch/parsing_json.php
/*- (void)testFail1 {
    bool ret = fail("\"A JSON payload should be an object or array, not a string.\"");
    XCTAssertEqual(ret, true);
}*/
- (void)testFail2 {
    bool ret = fail("[\"Unclosed array\"");
    XCTAssertEqual(ret, true);
}
- (void)testFail3 {
    bool ret = fail("{unquoted_key: \"keys must be quoted\"}");
    XCTAssertEqual(ret, true);
}
- (void)testFail4 {
    bool ret = fail("[\"extra comma\",]");
    XCTAssertEqual(ret, true);
}
- (void)testFail5 {
    bool ret = fail("[\"double extra comma\",,]");
    XCTAssertEqual(ret, true);
}
- (void)testFail6 {
    bool ret = fail("[   , \"<-- missing value\"]");
    XCTAssertEqual(ret, true);
}
- (void)testFail7 {
    bool ret = fail("[\"Comma after the close\"],");
    XCTAssertEqual(ret, true);
}
- (void)testFail8 {
    bool ret = fail("[\"Extra close\"]]");
    XCTAssertEqual(ret, true);
}
- (void)testFail9 {
    bool ret = fail("{\"Extra comma\": true,}");
    XCTAssertEqual(ret, true);
}
- (void)testFail10 {
    bool ret = fail("{\"Extra value after close\": true} \"misplaced quoted value\"");
    XCTAssertEqual(ret, true);
}
- (void)testFail11 {
    bool ret = fail("{\"Illegal expression\": 1 + 2}");
    XCTAssertEqual(ret, true);
}
- (void)testFail12 {
    bool ret = fail("{\"Illegal invocation\": alert()}");
    XCTAssertEqual(ret, true);
}
- (void)testFail13 {
    bool ret = fail("{\"Numbers cannot have leading zeroes\": 013}");
    XCTAssertEqual(ret, true);
}
- (void)testFail14 {
    bool ret = fail("{\"Numbers cannot be hex\": 0x14}");
    XCTAssertEqual(ret, true);
}
- (void)testFail15 {
    bool ret = fail("[\"Illegal backslash escape: \\x15\"]");
    XCTAssertEqual(ret, true);
}
- (void)testFail16 {
    bool ret = fail("[\naked]");
    XCTAssertEqual(ret, true);
}
- (void)testFail17 {
    bool ret = fail("[\"Illegal backslash escape: \\017\"]");
    XCTAssertEqual(ret, true);
}
- (void)testFail19 {
    bool ret = fail("{\"Missing colon\" null}");
    XCTAssertEqual(ret, true);
}
- (void)testFail20 {
    bool ret = fail("{\"Double colon\":: null}");
    XCTAssertEqual(ret, true);
}
- (void)testFail21 {
    bool ret = fail("{\"Comma instead of colon\", null}");
    XCTAssertEqual(ret, true);
}
- (void)testFail22 {
    bool ret = fail("[\"Colon instead of comma\": false]");
    XCTAssertEqual(ret, true);
}
- (void)testFail23 {
    bool ret = fail("[\"Bad value\", truth]");
    XCTAssertEqual(ret, true);
}
- (void)testFail24 {
    bool ret = fail("['single quote']");
    XCTAssertEqual(ret, true);
}
- (void)testFail25 {
    bool ret = fail("[\"	tab	character	in	string	\"]");
    XCTAssertEqual(ret, true);
}
- (void)testFail26 {
    bool ret = fail("[\"tab\\   character\\   in\\  string\\  \"]");
    XCTAssertEqual(ret, true);
}
- (void)testFail27 {
    bool ret = fail("[\"line\nbreak\"]");
    XCTAssertEqual(ret, true);
}
- (void)testFail28 {
    bool ret = fail("[\"line\\\nbreak\"]");
    XCTAssertEqual(ret, true);
}
- (void)testFail29 {
    bool ret = fail("[0e]");
    XCTAssertEqual(ret, true);
}
- (void)testFail30 {
    bool ret = fail("[0e+]");
    XCTAssertEqual(ret, true);
}
- (void)testFail31 {
    bool ret = fail("[0e+-1]");
    XCTAssertEqual(ret, true);
}
- (void)testFail32 {
    bool ret = fail("{\"Comma instead if closing brace\": true,");
    XCTAssertEqual(ret, true);
}
- (void)testFail33 {
    bool ret = fail("[\"mismatch\"}");
    XCTAssertEqual(ret, true);
}

- (void)testPass1 {
    bool ret = fail(R"foo([
    "JSON Test Pattern pass1",
    {"object with 1 member":["array with 1 element"]},
    {},
    [],
    -42,
    true,
    false,
    null,
    {
        "integer": 1234567890,
        "real": -9876.543210,
        "e": 0.123456789e-12,
        "E": 1.234567890E+34,
        "":  23456789012E66,
        "zero": 0,
        "one": 1,
        "space": " ",
        "quote": "\"",
        "backslash": "\\",
        "controls": "\b\f\n\r\t",
        "slash": "/ & \/",
        "alpha": "abcdefghijklmnopqrstuvwyz",
        "ALPHA": "ABCDEFGHIJKLMNOPQRSTUVWYZ",
        "digit": "0123456789",
        "0123456789": "digit",
        "special": "`1~!@#$%^&*()_+-={':[,]}|;.</>?",
        "hex": "\u0123\u4567\u89AB\uCDEF\uabcd\uef4A",
        "true": true,
        "false": false,
        "null": null,
        "array":[  ],
        "object":{  },
        "address": "50 St. James Street",
        "url": "http://www.JSON.org/",
        "comment": "// /* <!-- --",
        "# -- --> */": " ",
        " s p a c e d " :[1,2 , 3

,

4 , 5        ,          6           ,7        ],"compact":[1,2,3,4,5,6,7],
        "jsontext": "{\"object with 1 member\":[\"array with 1 element\"]}",
        "quotes": "&#34; \u0022 %22 0x22 034 &#x22;",
        "\/\\\"\uCAFE\uBABE\uAB98\uFCDE\ubcda\uef4A\b\f\n\r\t`1~!@#$%^&*()_+-=[]{}|;:',./<>?"
: "A key can be any string"
     },
     0.5 ,98.6
,
99.44
,

1066,
1e1,
0.1e1,
1e-1,
1e00,2e+00,2e-00
,"rosebud"])foo");
    XCTAssertEqual(ret, false);
}
- (void)testPass2 {
    bool ret = fail("[[[[[[[[[[[[[[[[[[[\"Not too deep\"]]]]]]]]]]]]]]]]]]]");
    XCTAssertEqual(ret, false);
}
- (void)testPass3 {
    bool ret = fail(R"foo({
    "JSON Test Pattern pass3": {
        "The outermost value": "must be an object or array.",
        "In this test": "It is an object."
    }
}
)foo");
    XCTAssertEqual(ret, false);
}


@end
