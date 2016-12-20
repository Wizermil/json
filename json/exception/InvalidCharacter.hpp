//
// InvalidCharacter.hpp
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

#pragma once

#include <cstddef>
#include <exception>
#include <string>

namespace json
{
    struct ParseErrorContext;
    enum struct Encoding : std::uint8_t;
    class OStringStream;

    class InvalidCharacter : public std::exception
    {
    public:
        InvalidCharacter() =delete;
        InvalidCharacter(const std::string& message, const ParseErrorContext* errorCtx);
        InvalidCharacter(InvalidCharacter&& other) noexcept;
        InvalidCharacter& operator =(InvalidCharacter&& other) noexcept;
        InvalidCharacter(const InvalidCharacter& other) =delete;
        InvalidCharacter& operator =(const InvalidCharacter& other) =delete;
        ~InvalidCharacter() =default;

        const char* what() const noexcept;

    private:
        std::uint32_t nextChar(std::istream* stream, Encoding enc) const noexcept;
        void writeChar(OStringStream& buffer, const std::uint32_t c) const noexcept;

    private:
        std::string _what;
    };
}
