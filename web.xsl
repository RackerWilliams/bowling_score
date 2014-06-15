<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:html="http://www.w3.org/1999/xhtml"
    xmlns:ixsl="http://saxonica.com/ns/interactiveXSLT" xmlns:prop="http://saxonica.com/ns/html-property"
    xmlns:b="http://www.rackspace.com/xml/rocks/bowling"
    extension-element-prefixes="ixsl" version="2.0">

    <xsl:include href="bowl.xsl"/>
    <xsl:include href="error.xsl"/>

    <xsl:template name="init">
        <xsl:result-document href="#errors" method="ixsl:replace-content"/>
        <xsl:result-document href="#frames" method="ixsl:replace-content"/>
        <xsl:result-document href="#score" method="ixsl:replace-content"/>
    </xsl:template>

    <xsl:template match="html:input" mode="ixsl:onkeyup">
        <xsl:variable name="frames" as="node()" select="b:tokenize(@prop:value)"/>
        <xsl:variable name="errors" as="node()*" select="b:check-errors($frames)"/>
        <xsl:choose>
            <xsl:when test="empty($errors)">
                <xsl:result-document href="#errors" method="ixsl:replace-content"/>
                <xsl:result-document href="#score" method="ixsl:replace-content">
                    <xsl:value-of select="b:calculate-score($frames)"/>
                </xsl:result-document>
            </xsl:when>
            <xsl:otherwise>
                <xsl:result-document href="#errors" method="ixsl:replace-content">
                    <xsl:apply-templates select="$errors" mode="print-errors"/>
                </xsl:result-document>
                <xsl:result-document href="#score" method="ixsl:replace-content"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="b:error" mode="print-errors">
        <html:div>
            Error on frame <xsl:value-of select="@frame"/>,
            throw <xsl:value-of select="@throw"/>:
            <xsl:value-of select="@message"/>
        </html:div>
    </xsl:template>
</xsl:stylesheet>