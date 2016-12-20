//
// ParseErrorContext.cpp
// json
//
// Created by Mathieu Garaud on 17/08/16.
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

#include "ParseErrorContext.hpp"
#include "../Document.hpp"

using namespace json;

ParseErrorContext::ParseErrorContext() : line(1)
, column(0)
, stream(nullptr)
, enc(Encoding::UTF8)
, filename("")
{
}

ParseErrorContext::ParseErrorContext(ParseErrorContext&& other) noexcept : line(other.line)
, column(other.column)
, stream(other.stream)
, enc(other.enc)
, filename(std::move(other.filename))
{
    other.line = 1;
    other.column = 0;
    other.stream = nullptr;
    other.enc = Encoding::UTF8;
    other.filename = "";
}

ParseErrorContext& ParseErrorContext::operator=(ParseErrorContext&& other) noexcept
{
    line = other.line;
    column = other.column;
    stream = other.stream;
    enc = other.enc;
    filename = std::move(other.filename);

    other.line = 1;
    other.column = 0;
    other.stream = nullptr;
    other.enc = Encoding::UTF8;
    other.filename = "";
    return *this;
}
