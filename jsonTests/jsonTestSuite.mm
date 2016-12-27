//
// jsonTestSuite.m
// jsonTests
//
// Created by Mathieu Garaud on 22/07/16.
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
#import <json/json.h>
#include <exception>

/**
 Implements the test based on this repo: https://github.com/nst/JSONTestSuite
 */
@interface jsonTestSuite : XCTestCase

@end

@implementation jsonTestSuite

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (BOOL)fail:(NSString*)json
{
    NSString* filePath = [[[NSBundle bundleForClass:[self class]] resourcePath] stringByAppendingPathComponent:json];
    bool ret = false;
    json::Document doc;
    try {
        doc.deserializeFromPath([filePath UTF8String]);
    } catch (const std::exception& e) {
        ret = true;
    }
    return ret;
}

- (void)test_i_number_double_huge_neg_exp {
    bool ret = [self fail:@"i_number_double_huge_neg_exp.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_i_number_huge_exp {
    bool ret = [self fail:@"i_number_huge_exp.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_i_number_neg_int_huge_exp {
    bool ret = [self fail:@"i_number_neg_int_huge_exp.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_i_number_pos_double_huge_exp {
    bool ret = [self fail:@"i_number_pos_double_huge_exp.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_i_number_real_neg_overflow {
    bool ret = [self fail:@"i_number_real_neg_overflow.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_i_number_real_pos_overflow {
    bool ret = [self fail:@"i_number_real_pos_overflow.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_i_number_real_underflow {
    bool ret = [self fail:@"i_number_real_underflow.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_i_number_too_big_neg_int {
    bool ret = [self fail:@"i_number_too_big_neg_int.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_i_number_too_big_pos_int {
    bool ret = [self fail:@"i_number_too_big_pos_int.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_i_number_very_big_negative_int {
    bool ret = [self fail:@"i_number_very_big_negative_int.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_i_object_key_lone_2nd_surrogate {
    bool ret = [self fail:@"i_object_key_lone_2nd_surrogate.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_i_string_1st_surrogate_but_2nd_missing {
    bool ret = [self fail:@"i_string_1st_surrogate_but_2nd_missing.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_i_string_1st_valid_surrogate_2nd_invalid {
    bool ret = [self fail:@"i_string_1st_valid_surrogate_2nd_invalid.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_i_string_incomplete_surrogate_and_escape_valid {
    bool ret = [self fail:@"i_number_huge_exp.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_i_string_incomplete_surrogate_pair {
    bool ret = [self fail:@"i_string_incomplete_surrogate_and_escape_valid.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_i_string_incomplete_surrogates_escape_valid {
    bool ret = [self fail:@"i_string_incomplete_surrogates_escape_valid.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_i_string_invalid_lonely_surrogate {
    bool ret = [self fail:@"i_string_invalid_lonely_surrogate.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_i_string_invalid_surrogate {
    bool ret = [self fail:@"i_string_invalid_surrogate.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_i_string_invalid_utf8 {
    bool ret = [self fail:@"i_string_invalid_utf-8.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_i_string_inverted_surrogates_U1D11E {
    bool ret = [self fail:@"i_string_inverted_surrogates_U+1D11E.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_i_string_iso_latin_1 {
    bool ret = [self fail:@"i_string_iso_latin_1.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_i_string_lone_second_surrogate {
    bool ret = [self fail:@"i_string_lone_second_surrogate.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_i_string_lone_utf8_continuation_byte {
    bool ret = [self fail:@"i_string_lone_utf8_continuation_byte.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_i_string_not_in_unicode_range {
    bool ret = [self fail:@"i_string_not_in_unicode_range.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_i_string_overlong_sequence_2_bytes {
    bool ret = [self fail:@"i_string_overlong_sequence_2_bytes.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_i_string_overlong_sequence_6_bytes_null {
    bool ret = [self fail:@"i_string_overlong_sequence_6_bytes_null.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_i_string_overlong_sequence_6_bytes {
    bool ret = [self fail:@"i_string_overlong_sequence_6_bytes.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_i_string_truncated_utf8 {
    bool ret = [self fail:@"i_string_truncated-utf-8.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_i_string_UTF8_invalid_sequence {
    bool ret = [self fail:@"i_string_UTF-8_invalid_sequence.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_i_string_UTF16LE_with_BOM {
    bool ret = [self fail:@"i_string_UTF-16LE_with_BOM.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_i_string_UTF8_surrogate_UD800 {
    bool ret = [self fail:@"i_string_UTF8_surrogate_U+D800.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_i_string_utf16BE_no_BOM {
    bool ret = [self fail:@"i_string_utf16BE_no_BOM.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_i_string_utf16LE_no_BOM {
    bool ret = [self fail:@"i_string_utf16LE_no_BOM.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_i_structure_500_nested_arrays {
    bool ret = [self fail:@"i_structure_500_nested_arrays.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_i_structure_UTF8_BOM_empty_object {
    bool ret = [self fail:@"i_structure_UTF-8_BOM_empty_object.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_array_1_true_without_comma {
    bool ret = [self fail:@"n_array_1_true_without_comma.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_array_a_invalid_utf8 {
    bool ret = [self fail:@"n_array_a_invalid_utf8.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_array_colon_instead_of_comma {
    bool ret = [self fail:@"n_array_colon_instead_of_comma.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_array_comma_after_close {
    bool ret = [self fail:@"n_array_comma_after_close.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_array_comma_and_number {
    bool ret = [self fail:@"n_array_comma_and_number.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_array_double_comma {
    bool ret = [self fail:@"n_array_double_comma.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_array_double_extra_comma {
    bool ret = [self fail:@"n_array_double_extra_comma.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_array_extra_close {
    bool ret = [self fail:@"n_array_extra_close.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_array_extra_comma {
    bool ret = [self fail:@"n_array_extra_comma.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_array_incomplete_invalid_value {
    bool ret = [self fail:@"n_array_incomplete_invalid_value.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_array_incomplete {
    bool ret = [self fail:@"n_array_incomplete.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_array_inner_array_no_comma {
    bool ret = [self fail:@"n_array_inner_array_no_comma.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_array_invalid_utf8 {
    bool ret = [self fail:@"n_array_invalid_utf8.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_array_items_separated_by_semicolon {
    bool ret = [self fail:@"n_array_items_separated_by_semicolon.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_array_just_comma {
    bool ret = [self fail:@"n_array_just_comma.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_array_just_minus {
    bool ret = [self fail:@"n_array_just_minus.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_array_missing_value {
    bool ret = [self fail:@"n_array_missing_value.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_array_newlines_unclosed {
    bool ret = [self fail:@"n_array_newlines_unclosed.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_array_number_and_comma {
    bool ret = [self fail:@"n_array_number_and_comma.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_array_number_and_several_commas {
    bool ret = [self fail:@"n_array_number_and_several_commas.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_array_spaces_vertical_tab_formfeed {
    bool ret = [self fail:@"n_array_spaces_vertical_tab_formfeed.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_array_star_inside {
    bool ret = [self fail:@"n_array_star_inside.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_array_unclosed_trailing_comma {
    bool ret = [self fail:@"n_array_unclosed_trailing_comma.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_array_unclosed_with_new_lines {
    bool ret = [self fail:@"n_array_unclosed_with_new_lines.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_array_unclosed_with_object_inside {
    bool ret = [self fail:@"n_array_unclosed_with_object_inside.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_array_unclosed {
    bool ret = [self fail:@"n_array_unclosed.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_incomplete_false {
    bool ret = [self fail:@"n_incomplete_false.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_incomplete_null {
    bool ret = [self fail:@"n_incomplete_null.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_incomplete_true {
    bool ret = [self fail:@"n_incomplete_true.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_multidigit_number_then_00 {
    bool ret = [self fail:@"n_multidigit_number_then_00.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_number_minus1dot0dot {
    bool ret = [self fail:@"n_number_-1.0..json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_number_minus01 {
    bool ret = [self fail:@"n_number_-01.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_number_minus2dot {
    bool ret = [self fail:@"n_number_-2..json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_number_minusNaN {
    bool ret = [self fail:@"n_number_-NaN.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_number_dotminus1 {
    bool ret = [self fail:@"n_number_.-1.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_number_dot2eminus3 {
    bool ret = [self fail:@"n_number_.2e-3.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_number_plusplus {
    bool ret = [self fail:@"n_number_++.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_number_plus1 {
    bool ret = [self fail:@"n_number_+1.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_number_plusInf {
    bool ret = [self fail:@"n_number_+Inf.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_number_0_capital_E {
    bool ret = [self fail:@"n_number_0_capital_E.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_number_0_capital_Eplus {
    bool ret = [self fail:@"n_number_0_capital_E+.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_number_0dot1dot2 {
    bool ret = [self fail:@"n_number_0.1.2.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_number_0dot3e {
    bool ret = [self fail:@"n_number_0.3e.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_number_0dot3eplus {
    bool ret = [self fail:@"n_number_0.3e+.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_number_0dote1 {
    bool ret = [self fail:@"n_number_0.e1.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_number_0e {
    bool ret = [self fail:@"n_number_0e.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_number_0eplus {
    bool ret = [self fail:@"n_number_0e+.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_number_1_000 {
    bool ret = [self fail:@"n_number_1_000.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_number_1dot0eminus {
    bool ret = [self fail:@"n_number_1.0e-.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_number_1dot0e {
    bool ret = [self fail:@"n_number_1.0e.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_number_1dot0eplus {
    bool ret = [self fail:@"n_number_1.0e+.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_number_1eE2 {
    bool ret = [self fail:@"n_number_1eE2.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_number_2doteminus3 {
    bool ret = [self fail:@"n_number_2.e-3.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_number_2doteplus3 {
    bool ret = [self fail:@"n_number_2.e+3.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_number_2dote3 {
    bool ret = [self fail:@"n_number_2.e3.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_number_9doteplus {
    bool ret = [self fail:@"n_number_9.e+.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_number_expression {
    bool ret = [self fail:@"n_number_expression.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_number_hex_1_digit {
    bool ret = [self fail:@"n_number_hex_1_digit.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_number_hex_2_digits {
    bool ret = [self fail:@"n_number_hex_2_digits.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_number_Inf {
    bool ret = [self fail:@"n_number_Inf.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_number_infinity {
    bool ret = [self fail:@"n_number_infinity.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_number_invalid_negative_real {
    bool ret = [self fail:@"n_number_invalid-negative-real.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_number_invalid_utf8_in_bigger_int {
    bool ret = [self fail:@"n_number_invalid-utf-8-in-bigger-int.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_number_invalid_utf8_in_exponent {
    bool ret = [self fail:@"n_number_invalid-utf-8-in-exponent.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_number_invalid_utf8_in_int {
    bool ret = [self fail:@"n_number_invalid-utf-8-in-int.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_number_invalidplusminus {
    bool ret = [self fail:@"n_number_invalid+-.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_number_minus_infinity {
    bool ret = [self fail:@"n_number_minus_infinity.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_number_minus_sign_with_trailing_garbage {
    bool ret = [self fail:@"n_number_minus_sign_with_trailing_garbage.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_number_minus_space_1 {
    bool ret = [self fail:@"n_number_minus_space_1.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_number_NaN {
    bool ret = [self fail:@"n_number_NaN.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_number_neg_int_starting_with_zero {
    bool ret = [self fail:@"n_number_neg_int_starting_with_zero.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_number_neg_real_without_int_part {
    bool ret = [self fail:@"n_number_neg_real_without_int_part.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_number_neg_with_garbage_at_end {
    bool ret = [self fail:@"n_number_neg_with_garbage_at_end.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_number_real_garbage_after_e {
    bool ret = [self fail:@"n_number_real_garbage_after_e.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_number_real_with_invalid_utf8_after_e {
    bool ret = [self fail:@"n_number_real_with_invalid_utf8_after_e.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_number_real_without_fractional_part {
    bool ret = [self fail:@"n_number_real_without_fractional_part.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_number_starting_with_dot {
    bool ret = [self fail:@"n_number_starting_with_dot.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_number_UFF11_fullwidth_digit_one {
    bool ret = [self fail:@"n_number_U+FF11_fullwidth_digit_one.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_number_with_alpha_char {
    bool ret = [self fail:@"n_number_with_alpha_char.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_number_with_alpha {
    bool ret = [self fail:@"n_number_with_alpha.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_number_with_leading_zero {
    bool ret = [self fail:@"n_number_with_leading_zero.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_object_bad_value {
    bool ret = [self fail:@"n_object_bad_value.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_object_bracket_key {
    bool ret = [self fail:@"n_object_bracket_key.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_object_comma_instead_of_colon {
    bool ret = [self fail:@"n_object_comma_instead_of_colon.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_object_double_colon {
    bool ret = [self fail:@"n_object_double_colon.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_object_emoji {
    bool ret = [self fail:@"n_object_emoji.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_object_garbage_at_end {
    bool ret = [self fail:@"n_object_garbage_at_end.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_object_key_with_single_quotes {
    bool ret = [self fail:@"n_object_key_with_single_quotes.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_object_missing_colon {
    bool ret = [self fail:@"n_object_missing_colon.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_object_missing_key {
    bool ret = [self fail:@"n_object_missing_key.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_object_missing_semicolon {
    bool ret = [self fail:@"n_object_missing_semicolon.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_object_missing_value {
    bool ret = [self fail:@"n_object_missing_value.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_object_nocolon {
    bool ret = [self fail:@"n_object_no-colon.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_object_non_string_key_but_huge_number_instead {
    bool ret = [self fail:@"n_object_non_string_key_but_huge_number_instead.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_object_non_string_key {
    bool ret = [self fail:@"n_object_non_string_key.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_object_pi_in_key_and_trailing_comma {
    bool ret = [self fail:@"n_object_pi_in_key_and_trailing_comma.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_object_repeated_null_null {
    bool ret = [self fail:@"n_object_repeated_null_null.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_object_several_trailing_commas {
    bool ret = [self fail:@"n_object_several_trailing_commas.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_object_single_quote {
    bool ret = [self fail:@"n_object_single_quote.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_object_trailing_comma {
    bool ret = [self fail:@"n_object_trailing_comma.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_object_trailing_comment_open {
    bool ret = [self fail:@"n_object_trailing_comment_open.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_object_trailing_comment_slash_open_incomplete {
    bool ret = [self fail:@"n_object_trailing_comment_slash_open_incomplete.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_object_trailing_comment_slash_open {
    bool ret = [self fail:@"n_object_trailing_comment_slash_open.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_object_trailing_comment {
    bool ret = [self fail:@"n_object_trailing_comment.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_object_two_commas_in_a_row {
    bool ret = [self fail:@"n_object_two_commas_in_a_row.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_object_unquoted_key {
    bool ret = [self fail:@"n_object_unquoted_key.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_object_unterminated_value {
    bool ret = [self fail:@"n_object_unterminated-value.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_object_with_single_string {
    bool ret = [self fail:@"n_object_with_single_string.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_object_with_trailing_garbage {
    bool ret = [self fail:@"n_object_with_trailing_garbage.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_single_space {
    bool ret = [self fail:@"n_single_space.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_string_1_surrogate_then_escape_u {
    bool ret = [self fail:@"n_string_1_surrogate_then_escape_u.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_string_1_surrogate_then_escape_u1 {
    bool ret = [self fail:@"n_string_1_surrogate_then_escape_u1.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_string_1_surrogate_then_escape_u1x {
    bool ret = [self fail:@"n_string_1_surrogate_then_escape_u1x.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_string_1_surrogate_then_escape {
    bool ret = [self fail:@"n_string_1_surrogate_then_escape.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_string_accentuated_char_no_quotes {
    bool ret = [self fail:@"n_string_accentuated_char_no_quotes.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_string_backslash_00 {
    bool ret = [self fail:@"n_string_backslash_00.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_string_escape_x {
    bool ret = [self fail:@"n_string_escape_x.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_string_escaped_backslash_bad {
    bool ret = [self fail:@"n_string_escaped_backslash_bad.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_string_escaped_ctrl_char_tab {
    bool ret = [self fail:@"n_string_escaped_ctrl_char_tab.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_string_escaped_emoji {
    bool ret = [self fail:@"n_string_escaped_emoji.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_string_incomplete_escape {
    bool ret = [self fail:@"n_string_incomplete_escape.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_string_incomplete_escaped_character {
    bool ret = [self fail:@"n_string_incomplete_escaped_character.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_string_incomplete_surrogate_escape_invalid {
    bool ret = [self fail:@"n_string_incomplete_surrogate_escape_invalid.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_string_incomplete_surrogate {
    bool ret = [self fail:@"n_string_incomplete_surrogate.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_string_invalid_backslash_esc {
    bool ret = [self fail:@"n_string_invalid_backslash_esc.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_string_invalid_unicode_escape {
    bool ret = [self fail:@"n_string_invalid_unicode_escape.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_string_invalid_utf8_after_escape {
    bool ret = [self fail:@"n_string_invalid_utf8_after_escape.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_string_invalid_utf8_in_escape {
    bool ret = [self fail:@"n_string_invalid-utf-8-in-escape.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_string_leading_uescaped_thinspace {
    bool ret = [self fail:@"n_string_leading_uescaped_thinspace.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_string_no_quotes_with_bad_escape {
    bool ret = [self fail:@"n_string_no_quotes_with_bad_escape.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_string_single_doublequote {
    bool ret = [self fail:@"n_string_single_doublequote.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_string_single_quote {
    bool ret = [self fail:@"n_string_single_quote.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_string_single_string_no_double_quotes {
    bool ret = [self fail:@"n_string_single_string_no_double_quotes.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_string_start_escape_unclosed {
    bool ret = [self fail:@"n_string_start_escape_unclosed.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_string_unescaped_crtl_char {
    bool ret = [self fail:@"n_string_unescaped_crtl_char.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_string_unescaped_newline {
    bool ret = [self fail:@"n_string_unescaped_newline.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_string_unescaped_tab {
    bool ret = [self fail:@"n_string_unescaped_tab.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_string_unicode_CapitalU {
    bool ret = [self fail:@"n_string_unicode_CapitalU.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_string_with_trailing_garbage {
    bool ret = [self fail:@"n_string_with_trailing_garbage.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_structure_100000_opening_arrays {
    bool ret = [self fail:@"n_structure_100000_opening_arrays.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_structure_angle_bracket_dot {
    bool ret = [self fail:@"n_structure_angle_bracket_..json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_structure_angle_bracket_null {
    bool ret = [self fail:@"n_structure_angle_bracket_null.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_structure_array_trailing_garbage {
    bool ret = [self fail:@"n_structure_array_trailing_garbage.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_structure_array_with_extra_array_close {
    bool ret = [self fail:@"n_structure_array_with_extra_array_close.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_structure_array_with_unclosed_string {
    bool ret = [self fail:@"n_structure_array_with_unclosed_string.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_structure_ascii_unicode_identifier {
    bool ret = [self fail:@"n_structure_ascii-unicode-identifier.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_structure_capitalized_True {
    bool ret = [self fail:@"n_structure_capitalized_True.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_structure_close_unopened_array {
    bool ret = [self fail:@"n_structure_close_unopened_array.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_structure_comma_instead_of_closing_brace {
    bool ret = [self fail:@"n_structure_comma_instead_of_closing_brace.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_structure_double_array {
    bool ret = [self fail:@"n_structure_double_array.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_structure_end_array {
    bool ret = [self fail:@"n_structure_end_array.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_structure_incomplete_UTF8_BOM {
    bool ret = [self fail:@"n_structure_incomplete_UTF8_BOM.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_structure_lone_invalid_utf8 {
    bool ret = [self fail:@"n_structure_lone-invalid-utf-8.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_structure_lone_open_bracket {
    bool ret = [self fail:@"n_structure_lone-open-bracket.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_structure_no_data {
    bool ret = [self fail:@"n_structure_no_data.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_structure_null_byte_outside_string {
    bool ret = [self fail:@"n_structure_null-byte-outside-string.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_structure_number_with_trailing_garbage {
    bool ret = [self fail:@"n_structure_number_with_trailing_garbage.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_structure_object_followed_by_closing_object {
    bool ret = [self fail:@"n_structure_object_followed_by_closing_object.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_structure_object_unclosed_no_value {
    bool ret = [self fail:@"n_structure_object_unclosed_no_value.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_structure_object_with_comment {
    bool ret = [self fail:@"n_structure_object_with_comment.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_structure_object_with_trailing_garbage {
    bool ret = [self fail:@"n_structure_object_with_trailing_garbage.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_structure_open_array_apostrophe {
    bool ret = [self fail:@"n_structure_open_array_apostrophe.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_structure_open_array_comma {
    bool ret = [self fail:@"n_structure_open_array_comma.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_structure_open_array_object {
    bool ret = [self fail:@"n_structure_open_array_object.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_structure_open_array_open_object {
    bool ret = [self fail:@"n_structure_open_array_open_object.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_structure_open_array_open_string {
    bool ret = [self fail:@"n_structure_open_array_open_string.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_structure_open_array_string {
    bool ret = [self fail:@"n_structure_open_array_string.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_structure_open_object_close_array {
    bool ret = [self fail:@"n_structure_open_object_close_array.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_structure_open_object_comma {
    bool ret = [self fail:@"n_structure_open_object_comma.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_structure_open_object_open_array {
    bool ret = [self fail:@"n_structure_open_object_open_array.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_structure_open_object_open_string {
    bool ret = [self fail:@"n_structure_open_object_open_string.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_structure_open_object_string_with_apostrophes {
    bool ret = [self fail:@"n_structure_open_object_string_with_apostrophes.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_structure_open_object {
    bool ret = [self fail:@"n_structure_open_object.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_structure_open_open {
    bool ret = [self fail:@"n_structure_open_open.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_structure_single_eacute {
    bool ret = [self fail:@"n_structure_single_eacute.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_structure_single_star {
    bool ret = [self fail:@"n_structure_single_star.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_structure_trailing_sharp {
    bool ret = [self fail:@"n_structure_trailing_#.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_structure_U2060_word_joined {
    bool ret = [self fail:@"n_structure_U+2060_word_joined.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_structure_uescaped_LF_before_string {
    bool ret = [self fail:@"n_structure_uescaped_LF_before_string.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_structure_unclosed_array_partial_null {
    bool ret = [self fail:@"n_structure_unclosed_array_partial_null.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_structure_unclosed_array_unfinished_false {
    bool ret = [self fail:@"n_structure_unclosed_array_unfinished_false.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_structure_unclosed_array_unfinished_true {
    bool ret = [self fail:@"n_structure_unclosed_array_unfinished_true.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_structure_unclosed_array {
    bool ret = [self fail:@"n_structure_unclosed_array.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_structure_unclosed_object {
    bool ret = [self fail:@"n_structure_unclosed_object.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_structure_unicode_identifier {
    bool ret = [self fail:@"n_structure_unicode-identifier.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_structure_UTF8_BOM_no_data {
    bool ret = [self fail:@"n_structure_UTF8_BOM_no_data.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_structure_whitespace_formfeed {
    bool ret = [self fail:@"n_structure_whitespace_formfeed.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_n_structure_whitespace_U2060_word_joiner {
    bool ret = [self fail:@"n_structure_whitespace_U+2060_word_joiner.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_y_array_arraysWithSpaces {
    bool ret = [self fail:@"y_array_arraysWithSpaces.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_y_array_empty_string {
    bool ret = [self fail:@"y_array_empty-string.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_y_array_empty {
    bool ret = [self fail:@"y_array_empty.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_y_array_ending_with_newline {
    bool ret = [self fail:@"y_array_ending_with_newline.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_y_array_false {
    bool ret = [self fail:@"y_array_false.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_y_array_heterogeneous {
    bool ret = [self fail:@"y_array_heterogeneous.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_y_array_null {
    bool ret = [self fail:@"y_array_null.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_y_array_with_1_and_newline {
    bool ret = [self fail:@"y_array_with_1_and_newline.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_y_array_with_leading_space {
    bool ret = [self fail:@"y_array_with_leading_space.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_y_array_with_several_null {
    bool ret = [self fail:@"y_array_with_several_null.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_y_array_with_trailing_space {
    bool ret = [self fail:@"y_array_with_trailing_space.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_y_number_0eplus1 {
    bool ret = [self fail:@"y_number_0e+1.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_y_number_0e1 {
    bool ret = [self fail:@"y_number_0e1.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_y_number_after_space {
    bool ret = [self fail:@"y_number_after_space.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_y_number_double_close_to_zero {
    bool ret = [self fail:@"y_number_double_close_to_zero.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_y_number_int_with_exp {
    bool ret = [self fail:@"y_number_int_with_exp.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_y_number_minus_zero {
    bool ret = [self fail:@"y_number_minus_zero.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_y_number_negative_int {
    bool ret = [self fail:@"y_number_negative_int.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_y_number_negative_one {
    bool ret = [self fail:@"y_number_negative_one.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_y_number_negative_zero {
    bool ret = [self fail:@"y_number_negative_zero.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_y_number_real_capital_e_neg_exp {
    bool ret = [self fail:@"y_number_real_capital_e_neg_exp.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_y_number_real_capital_e_pos_exp {
    bool ret = [self fail:@"y_number_real_capital_e_pos_exp.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_y_number_real_capital_e {
    bool ret = [self fail:@"y_number_real_capital_e.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_y_number_real_exponent {
    bool ret = [self fail:@"y_number_real_exponent.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_y_number_real_fraction_exponent {
    bool ret = [self fail:@"y_number_real_fraction_exponent.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_y_number_real_neg_exp {
    bool ret = [self fail:@"y_number_real_neg_exp.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_y_number_real_pos_exponent {
    bool ret = [self fail:@"y_number_real_pos_exponent.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_y_number_simple_int {
    bool ret = [self fail:@"y_number_simple_int.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_y_number_simple_real {
    bool ret = [self fail:@"y_number_simple_real.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_y_number {
    bool ret = [self fail:@"y_number.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_y_object_basic {
    bool ret = [self fail:@"y_object_basic.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_y_object_duplicated_key_and_value {
    bool ret = [self fail:@"y_object_duplicated_key_and_value.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_y_object_duplicated_key {
    bool ret = [self fail:@"y_object_duplicated_key.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_y_object_empty_key {
    bool ret = [self fail:@"y_object_empty_key.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_y_object_empty {
    bool ret = [self fail:@"y_object_empty.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_y_object_escaped_null_in_key {
    bool ret = [self fail:@"y_object_escaped_null_in_key.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_y_object_extreme_numbers {
    bool ret = [self fail:@"y_object_extreme_numbers.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_y_object_long_strings {
    bool ret = [self fail:@"y_object_long_strings.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_y_object_simple {
    bool ret = [self fail:@"y_object_simple.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_y_object_string_unicode {
    bool ret = [self fail:@"y_object_string_unicode.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_y_object_with_newlines {
    bool ret = [self fail:@"y_object_with_newlines.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_y_object {
    bool ret = [self fail:@"y_object.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_y_string_1_2_3_bytes_UTF8_sequences {
    bool ret = [self fail:@"y_string_1_2_3_bytes_UTF-8_sequences.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_y_string_accepted_surrogate_pair {
    bool ret = [self fail:@"y_string_accepted_surrogate_pair.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_y_string_accepted_surrogate_pairs {
    bool ret = [self fail:@"y_string_accepted_surrogate_pairs.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_y_string_allowed_escapes {
    bool ret = [self fail:@"y_string_allowed_escapes.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_y_string_backslash_and_u_escaped_zero {
    bool ret = [self fail:@"y_string_backslash_and_u_escaped_zero.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_y_string_backslash_doublequotes {
    bool ret = [self fail:@"y_string_backslash_doublequotes.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_y_string_comments {
    bool ret = [self fail:@"y_string_comments.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_y_string_double_escape_a {
    bool ret = [self fail:@"y_string_double_escape_a.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_y_string_double_escape_n {
    bool ret = [self fail:@"y_string_double_escape_n.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_y_string_escaped_control_character {
    bool ret = [self fail:@"y_string_escaped_control_character.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_y_string_escaped_noncharacter {
    bool ret = [self fail:@"y_string_escaped_noncharacter.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_y_string_in_array_with_leading_space {
    bool ret = [self fail:@"y_string_in_array_with_leading_space.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_y_string_in_array {
    bool ret = [self fail:@"y_string_in_array.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_y_string_last_surrogates_1_and_2 {
    bool ret = [self fail:@"y_string_last_surrogates_1_and_2.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_y_string_nbsp_uescaped {
    bool ret = [self fail:@"y_string_nbsp_uescaped.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_y_string_nonCharacterInUTF8_U1FFFF {
    bool ret = [self fail:@"y_string_nonCharacterInUTF-8_U+1FFFF.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_y_string_nonCharacterInUTF8_U10FFFF {
    bool ret = [self fail:@"y_string_nonCharacterInUTF-8_U+10FFFF.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_y_string_nonCharacterInUTF8_UFFFF {
    bool ret = [self fail:@"y_string_nonCharacterInUTF-8_U+FFFF.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_y_string_null_escape {
    bool ret = [self fail:@"y_string_null_escape.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_y_string_one_byte_utf8 {
    bool ret = [self fail:@"y_string_one-byte-utf-8.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_y_string_pi {
    bool ret = [self fail:@"y_string_pi.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_y_string_simple_ascii {
    bool ret = [self fail:@"y_string_simple_ascii.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_y_string_space {
    bool ret = [self fail:@"y_string_space.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_y_string_surrogates_U1D11E_MUSICAL_SYMBOL_G_CLEF {
    bool ret = [self fail:@"y_string_surrogates_U+1D11E_MUSICAL_SYMBOL_G_CLEF.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_y_string_three_byte_utf8 {
    bool ret = [self fail:@"y_string_three-byte-utf-8.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_y_string_two_byte_utf8 {
    bool ret = [self fail:@"y_string_two-byte-utf-8.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_y_string_u2028_line_sep {
    bool ret = [self fail:@"y_string_u+2028_line_sep.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_y_string_u2029_par_sep {
    bool ret = [self fail:@"y_string_u+2029_par_sep.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_y_string_uEscape {
    bool ret = [self fail:@"y_string_uEscape.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_y_string_uescaped_newline {
    bool ret = [self fail:@"y_string_uescaped_newline.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_y_string_unescaped_char_delete {
    bool ret = [self fail:@"y_string_unescaped_char_delete.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_y_string_unicode_2 {
    bool ret = [self fail:@"y_string_unicode_2.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_y_string_unicode_escaped_double_quote {
    bool ret = [self fail:@"y_string_unicode_escaped_double_quote.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_y_string_unicode_U1FFFE_nonchar {
    bool ret = [self fail:@"y_string_unicode_U+1FFFE_nonchar.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_y_string_unicode_U10FFFE_nonchar {
    bool ret = [self fail:@"y_string_unicode_U+10FFFE_nonchar.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_y_string_unicode_U200B_ZERO_WIDTH_SPACE {
    bool ret = [self fail:@"y_string_unicode_U+200B_ZERO_WIDTH_SPACE.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_y_string_unicode_U2064_invisible_plus {
    bool ret = [self fail:@"y_string_unicode_U+2064_invisible_plus.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_y_string_unicode_UFDD0_nonchar {
    bool ret = [self fail:@"y_string_unicode_U+FDD0_nonchar.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_y_string_unicode_UFFFE_nonchar {
    bool ret = [self fail:@"y_string_unicode_U+FFFE_nonchar.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_y_string_unicode {
    bool ret = [self fail:@"y_string_unicode.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_y_string_unicodeEscapedBackslash {
    bool ret = [self fail:@"y_string_unicodeEscapedBackslash.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_y_string_utf8 {
    bool ret = [self fail:@"y_string_utf8.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_y_string_with_del_character {
    bool ret = [self fail:@"y_string_with_del_character.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_y_structure_lonely_false {
    bool ret = [self fail:@"y_structure_lonely_false.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_y_structure_lonely_int {
    bool ret = [self fail:@"y_structure_lonely_int.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_y_structure_lonely_negative_real {
    bool ret = [self fail:@"y_structure_lonely_negative_real.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_y_structure_lonely_null {
    bool ret = [self fail:@"y_structure_lonely_null.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_y_structure_lonely_string {
    bool ret = [self fail:@"y_structure_lonely_string.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_y_structure_lonely_true {
    bool ret = [self fail:@"y_structure_lonely_true.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_y_structure_string_empty {
    bool ret = [self fail:@"y_structure_string_empty.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_y_structure_trailing_newline {
    bool ret = [self fail:@"y_structure_trailing_newline.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_y_structure_true_in_array {
    bool ret = [self fail:@"y_structure_true_in_array.json"];
    XCTAssertEqual(ret, true);
}
- (void)test_y_structure_whitespace_array {
    bool ret = [self fail:@"y_structure_whitespace_array.json"];
    XCTAssertEqual(ret, true);
}

@end
