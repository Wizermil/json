//
// ParseContext.cpp
// json
//
// Created by Mathieu Garaud on 24/07/16.
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

#include "ParseContext.hpp"

#include "../Document.hpp"

using namespace json;

ParseObjectContext::ParseObjectContext() : doc(Kind::OBJECT)
, state(State::UNKNOWN)
, value(ParseContextValue::UNKNOWN)
, keyState(StateKey::UNKNOWN)
, key("")
, numCtx(ParseNumberContext::DIGIT)
, commaCount(0)
, colonCount(0)
, duplicatedKeys(0)
{
}

ParseObjectContext::ParseObjectContext(ParseObjectContext&& other) noexcept : doc(std::move(other.doc))
, state(other.state)
, value(other.value)
, keyState(other.keyState)
, key(std::move(other.key))
, numCtx(other.numCtx)
, commaCount(other.commaCount)
, colonCount(other.colonCount)
, duplicatedKeys(other.duplicatedKeys)
{
    other.state = State::UNKNOWN;
    other.value = ParseContextValue::UNKNOWN;
    other.keyState = StateKey::UNKNOWN;
    other.key = "";
    other.numCtx = ParseNumberContext::DIGIT;
    other.commaCount = 0;
    other.colonCount = 0;
    other.duplicatedKeys = 0;
}

ParseObjectContext& ParseObjectContext::operator=(ParseObjectContext&& other) noexcept
{
    doc = std::move(other.doc);
    state = other.state;
    value = other.value;
    keyState = other.keyState;
    key = std::move(other.key);
    numCtx = other.numCtx;
    commaCount = other.commaCount;
    colonCount = other.colonCount;
    duplicatedKeys = other.duplicatedKeys;

    other.state = State::UNKNOWN;
    other.value = ParseContextValue::UNKNOWN;
    other.keyState = StateKey::UNKNOWN;
    other.key = "";
    other.numCtx = ParseNumberContext::DIGIT;
    other.commaCount = 0;
    other.colonCount = 0;
    other.duplicatedKeys = 0;
    return *this;
}
