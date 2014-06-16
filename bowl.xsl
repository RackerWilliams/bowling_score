<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:b="http://www.rackspace.com/xml/rocks/bowling" version="2.0">
    
    <xsl:function name="b:calculate-score" as="xs:integer">
        <xsl:param name="frame-tokens" as="node()?"/>
        <xsl:variable name="scores" as="xs:integer*">
            <xsl:apply-templates select="$frame-tokens"/>
            <xsl:apply-templates select="$frame-tokens" mode="bonus"/>
        </xsl:variable>
        <xsl:value-of select="sum($scores)"/>
    </xsl:function>

    <xsl:template match="text()" mode="#all"/>
    <xsl:template match="b:miss">0</xsl:template>
    <xsl:template match="b:digit"><xsl:value-of select="."/></xsl:template>
    <xsl:template match="b:strike">10</xsl:template>
    <xsl:template match="b:spare">
        <xsl:variable name="p" as="xs:integer">
            <xsl:apply-templates select="preceding-sibling::element()[1]"/>
        </xsl:variable>
        <xsl:value-of select="10 - $p"/>
    </xsl:template>

    <xsl:template match="b:strike[xs:integer(@frame) lt 10]" mode="bonus">
        <xsl:apply-templates select="following-sibling::element()[1] | following-sibling::element()[2]"/>
    </xsl:template>
    <xsl:template match="b:spare[xs:integer(@frame) lt 10]" mode="bonus">
        <xsl:apply-templates select="following-sibling::element()[1]"/>
    </xsl:template>

    <xsl:function name="b:tokenize" as="node()">
        <xsl:param as="xs:string" name="in"/>
        <b:frame-tokens>
            <xsl:sequence select="b:tokenizeFrames($in, 1, 1)"/>
        </b:frame-tokens>
    </xsl:function>

    <xsl:function name="b:tokenizeFrames" as="node()*">
        <xsl:param as="xs:string" name="in"/>
        <xsl:param as="xs:integer" name="throw"/>
        <xsl:param as="xs:integer" name="frame"/>
        <xsl:variable as="xs:string" name="f" select="substring($in,1,1)"/>
        <xsl:if test="$f != ''">
            <xsl:choose>
                <xsl:when test="$f = '-'">
                    <b:miss throw="{$throw}" frame="{$frame}"/>
                </xsl:when>
                <xsl:when test="$f = ('x','X')">
                    <b:strike throw="{$throw}" frame="{$frame}"/>
                </xsl:when>
                <xsl:when test="$f = '/'">
                    <b:spare   throw="{$throw}" frame="{$frame}"/>
                </xsl:when>
                <xsl:when test="matches($f,'[0-9]')">
                    <b:digit  throw="{$throw}" frame="{$frame}"><xsl:value-of select="$f"/></b:digit>
                </xsl:when>
                <xsl:otherwise>
                    <b:junk  throw="{$throw}" frame="{$frame}"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:sequence select="b:tokenizeFrames(substring($in,2),
                if ($throw eq 2 or $f = ('x','X','/')) then 1 else 2,
                if ($throw eq 2 or $f = ('x','X','/')) then $frame+1 else $frame)"/>
        </xsl:if>
    </xsl:function>
</xsl:stylesheet>