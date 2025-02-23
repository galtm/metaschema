<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet  version="3.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:m="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
    xmlns="http://www.w3.org/1999/xhtml"
    xpath-default-namespace="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
    exclude-result-prefixes="#all">
    
    <!-- Purpose: XSLT 3.0 stylesheet for Metaschema display (HTML): common code -->
    <!-- Input:   Metaschema -->
    <!-- Output:  HTML  -->
    
    <xsl:import href="metaschema-htmldoc-xslt1.xsl"/>
    
    <!--<xsl:import href="metaschema-docs-util.xsl"/>-->
    
    <xsl:param name="schema-path" select="document-uri(/)"/>
    
    <!-- override this from importing XSLT -->
    <xsl:variable name="metaschema-code" select="/*/short-name || '-common'"/>
    
    <xsl:variable name="home" select="/METASCHEMA"/>
    
    <xsl:variable name="all-references" select="//flag/@name | //model//*/@ref"/>
     
    <xsl:key name="definitions" match="/METASCHEMA/define-flag | /METASCHEMA/define-field | /METASCHEMA/define-assembly" use="@name"/>
    <xsl:key name="references" match="flag"             use="@name | @ref"/>
    <xsl:key name="references" match="field | assembly" use="@ref"/>
    
    <xsl:template match="/" mode="standalone make-page">
        <html>
            <head>
                <xsl:call-template name="css"/>
            </head>
            <body>
                <xsl:apply-templates/>
            </body>
        </html>
    </xsl:template>
    
    <!-- stub to override -->
    <xsl:template name="cross-links"/>
    
    <xsl:template match="METASCHEMA">
        <xsl:variable name="definitions" select="define-assembly | define-field | define-flag"/>
        <div class="{$metaschema-code ! replace(.,'.*-','') }-docs">
        <div class="top-level">
            <p><span class="usa-tag">Schema download</span>
                <xsl:text> </xsl:text>
                <a href="{$schema-path}">
                    <xsl:value-of select="replace($schema-path,'^.*/','')"/></a>
            </p>
            <xsl:apply-templates select="* except $definitions"/>
        </div>
        <xsl:apply-templates select="$definitions">
            <xsl:sort select="@name" data-type="text"/>
        </xsl:apply-templates>
        </div>
    </xsl:template>
    
    
    <xsl:template match="METASCHEMA/schema-name"/>
    
    <xsl:template match="METASCHEMA/namespace">
        <p>
            <span class="label">XML namespace</span>
            <xsl:text> </xsl:text>
            <code>
                <xsl:apply-templates/>
            </code>
        </p>
    </xsl:template>
    
    <xsl:template match="description">
        <p class="description">
            <span class="usa-tag">Description</span>
            <xsl:text> </xsl:text>
            <xsl:apply-templates/>
        </p>
    </xsl:template>
    
    <xsl:template match="define-assembly | define-field | define-flag" mode="link-here">
        <a href="#{@name}"><xsl:value-of select="@name"/></a>
    </xsl:template>
    
    <xsl:template match="*[exists(@ref)]" mode="link-here">
        <a href="#{@ref}"><xsl:value-of select="@ref"/></a>
    </xsl:template>
    
    <xsl:template name="definition-header">
        <header class="definition-header">
            <xsl:call-template name="cross-links"/>
            <h2 id="{$metaschema-code}_{@name}" class="{substring-after(local-name(),'define-')}-header">
                <xsl:apply-templates select="(root-name,use-name,@name)[1]" mode="tag"/>
            </h2>
        </header>
        <xsl:apply-templates select="formal-name" mode="header"/>
    </xsl:template>
    
    <xsl:template match="formal-name" mode="header">
        <p class="formal-name">
            <span class="usa-tag">Name</span>
            <xsl:text> </xsl:text>
            <xsl:apply-templates/>
        </p>
    </xsl:template>
    
    <xsl:template name="remarks-group">
        <!-- can't use xsl:where-populated due to the header :-( -->
        <xsl:for-each-group select="remarks[not(@class != 'xml')]" group-by="true()">
            <div class="remarks-group">
                <h4><span class="usa-tag">Remarks</span></h4>
                <xsl:apply-templates select="current-group()"/>
            </div>
        </xsl:for-each-group>
    </xsl:template>
    
    <xsl:template match="code[. = (/*/@name except ancestor::*/@name)]">
        <a href="#{.}">
            <xsl:next-match/>
        </a>
    </xsl:template>
    
    <xsl:template mode="tag" match="@name">
        <code class="tagging"><xsl:value-of select="."/></code>   
    </xsl:template>
    
    <xsl:template mode="tag" match="root-name | use-name">
        <code class="tagging"><xsl:value-of select="."/></code>   
    </xsl:template>
    
    <xsl:template name="allowed-values">
        <xsl:apply-templates select="constraint/allowed-values"/>
        <xsl:if test="empty(constraint/allowed-values)">
            <xsl:apply-templates select="key('definitions', @ref)/constraint/allowed-values"/>
        </xsl:if>
    </xsl:template>
    
    
    <!--<xsl:variable name="github-base" as="xs:string">https://github.com/usnistgov/OSCAL/tree/main</xsl:variable>-->
    
    <xsl:template name="report-module"/>
    
    <!--<xsl:template name="report-module-really">
         <xsl:variable name="metaschema-path" select="substring-after(.,'OSCAL/')"/>
      <xsl:for-each select="@module">
         <p class="text-accent-warm-darker" xsl:expand-text="yes">
            <xsl:text>Module defined: </xsl:text>
            <a href="{ $github-base}/{ $metaschema-path}">{
               replace(.,'.*/','') }</a></p>
      </xsl:for-each>
   </xsl:template>-->
    
    <xsl:template match="example[empty(* except (description | remarks))]"/>
    
    <xsl:template name="css">
        <style type="text/css">
            <xsl:sequence select="unparsed-text('hugo-uswds.css','utf-8') ! replace(.,'#xD;','')"/>
        </style>
    </xsl:template>
    
    <xsl:template mode="occurrence-code" match="*">
        <xsl:variable name="minOccurs" select="(@min-occurs,'0')[1]"/>
        <xsl:variable name="maxOccurs" select="(@max-occurs,'1')[1] ! (if (. eq 'unbounded') then '&#x221e;' else .)"/>
        <i class="occurrence">
        <xsl:text>[</xsl:text>
        <xsl:choose>
            <xsl:when test="$minOccurs = $maxOccurs" expand-text="true">{ $minOccurs }</xsl:when>
            <xsl:when test="number($maxOccurs) = number($minOccurs) + 1" expand-text="true">{ $minOccurs } or { $maxOccurs }</xsl:when>
            <xsl:otherwise expand-text="true">{ $minOccurs } to { $maxOccurs }</xsl:otherwise>
        </xsl:choose>
        <xsl:text>]</xsl:text>
        </i>
    </xsl:template>
    
        <!-- Returns true when a field must become an object, not a string, due to having
     flags that must be properties. -->
    <xsl:function name="m:has-properties" as="xs:boolean">
        <xsl:param name="who" as="element()"/>
        <xsl:sequence select="exists($who/(define-flag|flag)[not((@name|@ref)=../(json-key | json-value-key-flag)/@flag-ref)])"/>
    </xsl:function>
        
</xsl:stylesheet>