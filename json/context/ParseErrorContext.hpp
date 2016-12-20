//
// ParseErrorContext.hpp
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

#pragma once

#include <cstddef>
#include <istream>
#include <string>

namespace json
{
    enum struct Encoding : std::uint8_t;

    struct ParseErrorContext
    {
        ParseErrorContext();
        ParseErrorContext(ParseErrorContext&& other) noexcept;
        ParseErrorContext& operator=(ParseErrorContext&& other) noexcept;
        ParseErrorContext(const ParseErrorContext& other) = delete;
        ParseErrorContext& operator=(const ParseErrorContext& other) = delete;
        ~ParseErrorContext() = default;

        std::size_t line;
        std::size_t column;
        std::istream* stream;
        Encoding enc;
        std::string filename;
    };
}
