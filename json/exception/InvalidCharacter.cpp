//
// InvalidCharacter.cpp
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

#include "InvalidCharacter.hpp"

#include "../context/ParseErrorContext.hpp"
#include "../Document.hpp"
#include "../std/OStringStream.hpp"
#include <ios>
#include <iostream>

using namespace json;

InvalidCharacter::InvalidCharacter(const std::string& message, const ParseErrorContext* errorCtx) : std::exception()
, _what(":0:0: error: ???\r\n")
{
    OStringStream whatBuf("", std::ios::ate);
    OStringStream extractBuf("", std::ios::ate);

    if (errorCtx != nullptr)
    {
        std::istream* stream = errorCtx->stream;
        if (stream->good())
        {
            const std::istream::pos_type maxCharLog(40);
            const auto current = stream->tellg();
            std::istream::pos_type firstBye(0);
            if (current > (maxCharLog+std::istream::pos_type(2)))
                firstBye = current-maxCharLog-std::istream::pos_type(1);
            stream->seekg(firstBye);

            std::uint32_t c = 0;

            OStringStream cursorErrorBuf("", std::ios::ate);
            bool isCursorWritten = false;

            for (c = nextChar(stream, errorCtx->enc);!stream->eof() && !stream->bad();c = nextChar(stream, errorCtx->enc))
            {
                const auto now = stream->tellg();
                if (c == '\r' || c == '\n')
                {
                    if (now <= current)
                    {
                        extractBuf.clear();
                        extractBuf.seekp(std::ios::beg);
                        cursorErrorBuf.clear();
                        cursorErrorBuf.seekp(std::ios::beg);
                    }
                    else
                        break;
                }
                else
                {
                    writeChar(extractBuf, c);
                    if (now < current)
                        cursorErrorBuf << (c == '\t'?'\t':' ');
                    else if (!isCursorWritten)
                    {
                        //cursorErrorBuf << "\033[32m";
                        cursorErrorBuf << '^';
                        isCursorWritten = true;
                    }
                }
                if (now >= (current + maxCharLog))
                    break;
            }

            extractBuf << '\r' << '\n' << cursorErrorBuf.str();
        }
    }
    whatBuf << errorCtx->filename << ':' << (errorCtx == nullptr?0:errorCtx->line) << ':' << (errorCtx == nullptr?0:errorCtx->column) << ": error: "<< message << '\r' << '\n' << extractBuf.str() << '\r' << '\n';
    _what = whatBuf.str();
}
InvalidCharacter::InvalidCharacter(InvalidCharacter&& other) noexcept : std::exception(std::move(other))
, _what(std::move(other._what))
{
}
InvalidCharacter& InvalidCharacter::operator =(InvalidCharacter&& other) noexcept
{
    _what = std::move(other._what);
    std::exception::operator=(std::move(other));
    return *this;
}

void InvalidCharacter::writeChar(OStringStream& buffer, const std::uint32_t c) const noexcept
{
    if (c <= 0x7F)
        buffer << static_cast<char>(c);
    else if (c <= 0x7FF)
        buffer << static_cast<char>((0x1F & (c >> 6)) | 0xC0) << static_cast<char>((0x3F & c) | 0x80);
    else if (c <= 0xFFFF)
        buffer << static_cast<char>((0x0F & (c >> 12)) | 0xE0) << static_cast<char>((0x3F & (c >> 6)) | 0x80) << static_cast<char>((0x3F & c) | 0x80);
    else if (c <= 0x10FFFF)
        buffer << static_cast<char>((0x07 & (c >> 18)) | 0xF0) << static_cast<char>((0x3F & (c >> 12)) | 0x80) << static_cast<char>((0x3F & (c >> 6)) | 0x80) <<static_cast<char>((0x3F & c) | 0x80);
}

std::uint32_t InvalidCharacter::nextChar(std::istream* stream, Encoding enc) const noexcept
{
    std::uint8_t unicodeCount = 0;
    std::istream::char_type ch = 0;
    std::uint8_t uCh = 0;
    std::uint32_t c = 0;

    for (stream->get(ch); !stream->eof() && !stream->bad(); stream->get(ch))
    {
        if (enc == Encoding::UTF8)
        {
            uCh = static_cast<std::uint8_t>(ch);
            if (unicodeCount == 0)
            {
                c = 0;
                if (uCh <= 0x7F)
                {
                    c = uCh;
                    unicodeCount = 0;
                }
                else if (uCh <= 0xDF)
                {
                    c = uCh & 0x1F;
                    c <<= 6;
                    unicodeCount = 1;
                }
                else if (uCh <= 0xEF)
                {
                    c = uCh & 0x0F;
                    c <<= 12;
                    unicodeCount = 2;
                }
                else if (uCh <= 0xFF)
                {
                    c = uCh & 0x07;
                    c <<= 18;
                    unicodeCount = 3;
                }
            }
            else if (uCh >= 0x80 && uCh <= 0xBF)
            {
                --unicodeCount;
                c |= static_cast<std::uint32_t>(0x003F & uCh) << (6*unicodeCount);
            }
            else // Just in case you start reading a character in a middle of UTF-8 sequence or it's invalid.
            {
                c = 0xFFFD;
                unicodeCount = 0;
            }
            if (unicodeCount == 0)
                break;
        }
        else if (enc == Encoding::UTF16)
        {
            if (unicodeCount == 0)
            {
                c = 0;
                c |= uCh;
                c <<= 8;
                unicodeCount=1;
            }
            else if (--unicodeCount == 0)
            {
                c |= uCh;
                if (c >= 0xD800 && c <= 0xDFFF)
                {
                    c &= 0x3FF;
                    c <<=10;
                    unicodeCount=3; // It's a nasty trick to avoid an extra variable for surrogate characters.
                }
            }
            else if (unicodeCount == 2)
            {
                std::uint16_t tmp = uCh;
                tmp &= 0x03;
                tmp <<= 8;
                c |= tmp;
            }
            else if (unicodeCount == 1)
            {
                c |= uCh;
                c |= 0x10000;
                unicodeCount=0;
            }
            if (unicodeCount == 0)
                break;
        }
        else if (enc == Encoding::UTF32)
        {
            if (unicodeCount == 0)
            {
                c = 0;
                c |= uCh;
                c <<= 24;
                unicodeCount=3;
            }
            else
            {
                unicodeCount--;
                std::uint32_t tmp = uCh;
                tmp <<= (unicodeCount*8);
                c |= tmp;
            }
            if (unicodeCount == 0)
                break;
        }
    }

    return c;
}

const char* InvalidCharacter::what() const noexcept
{
    return _what.c_str();
}
