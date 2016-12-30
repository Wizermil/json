//
// ParseArrayContext.cpp
// json
//
// Created by Mathieu Garaud on 26/12/16.
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

ParseArrayContext::ParseArrayContext() : doc(Kind::ARRAY)
, state(State::UNKNOWN)
, value(ParseContextValue::UNKNOWN)
, numCtx(ParseNumberContext::DIGIT)
, commaCount(0)
{
}

ParseArrayContext::ParseArrayContext(ParseArrayContext&& other) noexcept : doc(std::move(other.doc))
, state(other.state)
, value(other.value)
, numCtx(other.numCtx)
, commaCount(other.commaCount)
{
    other.state = State::UNKNOWN;
    other.value = ParseContextValue::UNKNOWN;
    other.numCtx = ParseNumberContext::DIGIT;
    other.commaCount = 0;
}

ParseArrayContext& ParseArrayContext::operator=(ParseArrayContext&& other) noexcept
{
    doc = std::move(other.doc);
    state = other.state;
    value = other.value;
    numCtx = other.numCtx;
    commaCount = other.commaCount;
    other.state = State::UNKNOWN;
    other.value = ParseContextValue::UNKNOWN;
    other.numCtx = ParseNumberContext::DIGIT;
    other.commaCount = 0;
    return *this;
}
