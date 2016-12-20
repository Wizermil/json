//
// OStringStream.cpp
// json
//
// Created by Mathieu Garaud on 08/09/16.
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
#include "OStringStream.hpp"
#include <memory>

using namespace json;

OStringStream::OStringStream(std::ios::openmode wch) : std::ostream(&_sb)
, _sb(wch | std::ios::out)
{
}

OStringStream::OStringStream(const std::string& s, std::ios::openmode wch) : std::ostream(&_sb)
, _sb(s, wch | std::ios::out)
{
}

OStringStream::OStringStream(OStringStream&& other) noexcept : std::ostream(std::move(other))
, _sb(std::move(other._sb))
{
    set_rdbuf(&_sb);
}

OStringStream& OStringStream::operator=(OStringStream&& other) noexcept
{
    _sb = std::move(other._sb);
    set_rdbuf(&_sb);
    std::ostream::operator=(std::move(other));
    return *this;
}

OStringStream::~OStringStream()
{
}

void OStringStream::swap(OStringStream& other)
{
    std::ostream::swap(other);
    _sb.swap(other._sb);
    set_rdbuf(&_sb);
    other.set_rdbuf(&other._sb);
}

Stringbuf* OStringStream::rdbuf() const
{
    return const_cast<Stringbuf*>(&_sb);
}

std::string OStringStream::str() const
{
    return _sb.str();
}

void OStringStream::str(const std::string& s)
{
    _sb.str(s);
}
