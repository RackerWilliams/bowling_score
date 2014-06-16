<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:b="http://www.rackspace.com/xml/rocks/bowling" version="2.0">

    <xsl:function name="b:check-errors" as="node()*">
        <xsl:param name="frame-tokens" as="node()?"/>
        <xsl:apply-templates select="$frame-tokens" mode="error"/>
    </xsl:function>

    <xsl:template match="b:junk" mode="error">
        <xsl:sequence select="b:error(.,'Frame contains junk')"/>
    </xsl:template>

    <xsl:template match="b:spare[@throw = '1']" mode="error" priority="3">
        <xsl:sequence select="b:error(.,'Not possbile to get a spare on the first throw')"/>
    </xsl:template>

    <xsl:template match="b:strike[@throw='2']" mode="error" priority="3">
        <xsl:sequence select="b:error(.,'Not possbile to get a strike on the second throw')"/>
    </xsl:template>

    <xsl:template match="b:*[xs:integer(@frame) ge 13]" mode="error">
        <xsl:sequence select="b:error(.,'Too many frames: this frame is unnessesary')"/>
    </xsl:template>

    <xsl:template match="b:*[@frame = '11' and @throw = '1']" mode="error">
        <xsl:variable name="ten-throw-one" as="xs:string" select="local-name(preceding-sibling::element()[@frame='10' and @throw='1'])"/>
        <xsl:variable name="ten-throw-two" as="xs:string" select="local-name(preceding-sibling::element()[@frame='10' and @throw='2'])"/>
        <xsl:if test="($ten-throw-one != 'strike') and ($ten-throw-two != 'spare')">
            <xsl:sequence select="b:error(.,'Too many frames: the 11th frame is only valid if the 10th frame contains a spare or strike')"/>
        </xsl:if>
    </xsl:template>

    <xsl:template match="b:*[@frame = '11' and @throw = '2']" mode="error">
        <xsl:variable name="ten-throw-one" as="xs:string" select="local-name(preceding-sibling::element()[@frame='10' and @throw='1'])"/>
        <xsl:if test="$ten-throw-one != 'strike'">
            <xsl:sequence select="b:error(.,'Too many frames: the 11th frame, throw 2 is only valid if the 10th frame is a strike')"/>
        </xsl:if>
    </xsl:template>

    <xsl:template match="b:*[@frame = '12']" mode="error">
        <xsl:variable name="ten-throw-one" as="xs:string" select="local-name(preceding-sibling::element()[@frame='10' and @throw='1'])"/>
        <xsl:variable name="eleven-throw-one" as="xs:string" select="local-name(preceding-sibling::element()[@frame='11' and @throw='1'])"/>
        <xsl:if test="($ten-throw-one != 'strike') or ($eleven-throw-one != 'strike')">
            <xsl:sequence select="b:error(.,'Too many frames: the 12th frame is only valid if 10th and 11th frames are strikes')"/>
        </xsl:if>
    </xsl:template>

    <xsl:function name="b:error" as="node()">
        <xsl:param name="frame-token" as="node()"/>
        <xsl:param name="msg" as="xs:string"/>
        <b:error message="{$msg}" frame="{$frame-token/@frame}" throw="{$frame-token/@throw}"/>
    </xsl:function>
</xsl:stylesheet>