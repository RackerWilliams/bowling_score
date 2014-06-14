<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:b="http://www.rackspace.com/xml/rocks/bowling"
    exclude-result-prefixes="xs"
    version="2.0">

    <xsl:output method="text"/>

    <b:tests>
        <b:test frames="--------------------" should-score="0"/>
        <b:test frames="-1-1-1-1-1-1-1-1-1-1" should-score="10"/>
        <b:test frames="-1-2-3-4-5-6-7-8-944" should-score="53"/>
        <b:test frames="9-8-7-6-5-4-3-2-1---" should-score="45"/>
        <b:test frames="XXXXXXXXXXXX"         should-score="300"/>
        <b:test frames="3423114/12XX-99---"   should-score="85"/>
        <b:test frames="----XXX439/4/128/4"   should-score="120"/>
        <b:test frames="-72/4/XXX23459/XXX"   should-score="172"/>
        <b:test frames="-/X1/249-8/XX--XXX"   should-score="147"/>
    </b:tests>

    <xsl:include href="bowl.xsl"/>

    <xsl:template match="/">
        <xsl:apply-templates select="document('')//b:test"/>
    </xsl:template>

    <xsl:template match="b:test">
        <xsl:variable name="result" as="xs:integer"
            select="b:calculate-score(b:tokenize(@frames))"/>
        <xsl:choose>
            <xsl:when test="xs:integer(@should-score) = $result">
                <xsl:text>[PASS] </xsl:text>
                <xsl:value-of select="concat(@frames,' ➞ ',@should-score,'&#xa;')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>[FAIL] </xsl:text>
                <xsl:value-of select="concat(@frames,' ➞ ',$result,' ≠ ',@should-score,'&#xa;')"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>