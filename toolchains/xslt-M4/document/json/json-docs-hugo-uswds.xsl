<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:xs="http://www.w3.org/2001/XMLSchema"
   xmlns:m="http://csrc.nist.gov/ns/oscal/metaschema/1.0" xmlns="http://www.w3.org/1999/xhtml"
   xpath-default-namespace="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
   exclude-result-prefixes="#all">

   <!-- Purpose: XSLT 3.0 stylesheet for Metaschema display (HTML): XML version -->
   <!-- Input:   Metaschema -->
   <!-- Output:  HTML  -->

   <xsl:mode on-no-match="text-only-copy"/>

   <!--<xsl:param name="schema-path" select="document-uri(/)"/>-->

   <!--  XXX TO DO XXX -->
   <xsl:param name="content-converter-path" select="'#'"/>

   <xsl:variable name="metaschema-code" select="/*/short-name || '-json'"/>

   <xsl:variable name="datatype-page" as="xs:string">/reference/datatypes</xsl:variable>

   <xsl:strip-space elements="*"/>

   <xsl:preserve-space elements="p li pre i b em strong a code q"/>

   <xsl:output indent="yes"/>

   <!-- Purpose: XSLT 3.0 stylesheet for Metaschema display (HTML): common code -->
   <!-- Input:   Metaschema -->
   <!-- Output:  HTML  -->

   <xsl:import href="../../metapath/docs-metapath.xsl"/>

   <xsl:import href="../metaschema-htmldoc-xslt1.xsl"/>

   <xsl:variable name="home" select="/METASCHEMA"/>

   <xsl:param name="xml-definitions-page" as="xs:string">../../xml/definitions</xsl:param>
   
   
   <xsl:variable name="all-references" select="//flag/@name | //model//*/@ref"/>

   <xsl:key name="assembly-definitions" match="/METASCHEMA/define-assembly" use="@name"/>
   <xsl:key name="field-definitions"    match="/METASCHEMA/define-field"    use="@name"/>
   <xsl:key name="flag-definitions"     match="/METASCHEMA/define-flag"     use="@name"/>
   
   <xsl:key name="assembly-references"  match="assembly" use="@ref"/>
   <xsl:key name="field-references"     match="field"    use="@ref"/>
   <xsl:key name="flag-references"      match="flag"     use="@ref"/>

   <xsl:key name="using-name"
      match="flag | field | assembly | define-flag | define-field | define-assembly"
      use="m:use-name(.)"/>

   <xsl:template match="/" mode="make-page">
      <html>
         <head>
            <xsl:call-template name="css"/>
         </head>
         <body>
            <!--<section>
               <xsl:for-each-group select="//constraint/(.|descendant::require)/(child::* except child::require)" group-by="m:path-key((@target,'.')[1])" expand-text="true">
                  <details>
                     <summary>Path key { current-grouping-key() }</summary>
                     <xsl:apply-templates select="current-group()" mode="build-index"/>
                  </details>
               </xsl:for-each-group> 
            </section>-->
            <xsl:apply-templates/>
         </body>
      </html>
   </xsl:template>



   <xsl:template match="METASCHEMA">
      <xsl:variable name="definitions" select="define-assembly | define-field | define-flag"/>
      <div class="{$metaschema-code ! replace(.,'.*-','') }-docs">
         <xsl:apply-templates select="* except (remarks|$definitions)"/>
         <xsl:apply-templates select="remarks"/>
         <xsl:apply-templates select="child::define-assembly | child::define-field"
            mode="make-definition">
            <xsl:sort select="m:use-name(.)"/>
            <xsl:with-param name="link-context" tunnel="true" select="."/>
         </xsl:apply-templates>
      </div>
   </xsl:template>

   <xsl:template match="METASCHEMA/short-name"/>
   
   <xsl:template match="METASCHEMA/schema-name">
      <p>
         <span class="usa-tag">OSCAL model</span>
         <xsl:text> </xsl:text>
         <xsl:apply-templates/>
      </p>
   </xsl:template>
   
   <xsl:template match="METASCHEMA/namespace"/>
   <!--<xsl:template match="METASCHEMA/namespace">
      <p>
         <span class="usa-tag">XML namespace</span>
         <xsl:text> </xsl:text>
         <code>
            <xsl:apply-templates/>
         </code>
      </p>
   </xsl:template>-->

   <xsl:variable name="file-map" as="map(xs:string, text())">
      <xsl:map>
         <xsl:map-entry key="'oscal-catalog'"  >catalog</xsl:map-entry>
         <xsl:map-entry key="'oscal-profile'"  >profile</xsl:map-entry>
         <xsl:map-entry key="'oscal-component-definition'">component</xsl:map-entry>
         <xsl:map-entry key="'oscal-ssp'"      >ssp</xsl:map-entry>
         <xsl:map-entry key="'oscal-poam'"     >poam</xsl:map-entry>
         <xsl:map-entry key="'oscal-ap'"       >assessment-plan</xsl:map-entry>
         <xsl:map-entry key="'oscal-ar'"       >assessment-results</xsl:map-entry>
      </xsl:map>
   </xsl:variable>

   <xsl:template match="description">
      <xsl:variable name="is-global" select="exists(parent::*/parent::METASCHEMA)"/>
      <p class="description{ ' global'[$is-global]}">
         <!--<span class="usa-tag">Description</span>
         <xsl:text> </xsl:text>-->
         <xsl:apply-templates/>
      </p>
   </xsl:template>

   <xsl:template match="*" mode="link-usage">
      <xsl:value-of select="m:use-name(.)"/>
   </xsl:template>
   
   <!--<xsl:template match="*" mode="link-here">
      <!-\- forcing names in top-down order     -\->
      <a href="#local_{string-join( (ancestor::*|.)/(@name|@ref),'-')}" class="name-link">
         <xsl:value-of select="m:use-name(.)"/>
      </a>
   </xsl:template>

   <xsl:template match="METASCHEMA/define-assembly | METASCHEMA/define-field" mode="link-here">
      <a href="#global_{@name}" class="name-link">
         <xsl:value-of select="m:use-name(.)"/>
      </a>
   </xsl:template>-->

   <xsl:template name="definition-header">
      <xsl:variable name="identifier" select="string-join(ancestor-or-self::*/@name,'/')"/>
      <xsl:variable name="nested" select="count(.|ancestor::define-assembly|ancestor::define-field)"/>
      <xsl:variable name="references"
         select="self::define-flag/key('flag-references', @name) |
         self::define-field/key('field-references', @name) |
         self::define-assembly/key('assembly-references', @name)"/>
      <xsl:variable name="singular-names" as="node()*">
         <xsl:variable name="def-single-name" select="(root-name, use-name, @name)[1]"/>
         <xsl:for-each select="$references[empty(group-as)]">
            <xsl:sequence select="(use-name, $def-single-name, @ref)[1]"/>
         </xsl:for-each>
         <xsl:sequence select="$def-single-name[empty($references) or exists($references/group-as)]"
         />
      </xsl:variable>
      <!--<xsl:variable name="group-names" select="group-as/@name, $references/group-as/@name"/>-->
      <div class="definition-header">
         <xsl:call-template name="cross-links"/>
         <xsl:element name="h{ $nested }" namespace="http://www.w3.org/1999/xhtml">
            <xsl:attribute name="class" select="'toc' || $nested"/>
            <xsl:attribute name="id" select="$identifier"/>
            <span class="defining">
               <xsl:for-each-group select="$singular-names" group-by="string(.)">
                  <xsl:if test="position() gt 1">, </xsl:if>
                  <span class="usename">
                     <xsl:value-of select="current-grouping-key()"/>
                  </span>
               </xsl:for-each-group>
            </span>
         </xsl:element>
         <p>
            <xsl:for-each select="formal-name">
               <span class="usa-tag">formal name</span>
               <xsl:text> </xsl:text>
               <span class="frmname">
                  <xsl:apply-templates/>
               </span>
            </xsl:for-each>
         </p>
      </div>
   </xsl:template>

   <xsl:template name="remarks-group">
      <!-- can't use xsl:where-populated due to the header :-( -->
      <xsl:for-each-group select="remarks[not(@class != 'xml')]" group-by="true()">
         <div class="remarks-group">
            <details open="open">
               <summary class="subhead">Remarks</summary>
               <xsl:apply-templates select="current-group()"/>
            </details>
         </div>
      </xsl:for-each-group>
   </xsl:template>

   <!--<xsl:template match="code[. = (/*/@name except ancestor::*/@name)]">
      <a href="#{.}">
         <xsl:next-match/>
      </a>
   </xsl:template>-->


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
      <style type="text/css" class="doe">
         <xsl:sequence select="unparsed-text('../hugo-uswds.css', 'utf-8') ! replace(., '#xD;', '')"/>
      </style>
   </xsl:template>

   <xsl:template mode="occurrence-code" match="*">
      <xsl:param name="require-member" select="false()"/>
      <xsl:variable name="minOccurs" select="if ($require-member) then  (@min-occurs[not(.='0')], '1')[1]
         else (@min-occurs, '0')[1]"/>
      <xsl:variable name="maxOccurs"
         select="
            (@max-occurs, '1')[1] ! (if (. eq 'unbounded') then
               '&#x221e;'
            else
               .)"/>
      <span class="cardinality">
         <xsl:text>[</xsl:text>
         <xsl:choose>
            <xsl:when test="$minOccurs = $maxOccurs" expand-text="true">{ $minOccurs }</xsl:when>
            <xsl:when test="number($maxOccurs) = number($minOccurs) + 1" expand-text="true">{
               $minOccurs } or { $maxOccurs }</xsl:when>
            <xsl:otherwise expand-text="true">{ $minOccurs } to { $maxOccurs }</xsl:otherwise>
         </xsl:choose>
         <xsl:text>]</xsl:text>
      </span>
   </xsl:template>

   <!-- Returns true when a field must become an object, not a string, due to having
     flags that must be properties. -->
   <xsl:function name="m:has-properties" as="xs:boolean">
      <xsl:param name="who" as="element()"/>
      <xsl:sequence
         select="exists($who/(define-flag | flag)[not((@name | @ref) = ../(json-key | json-value-key-flag)/@flag-ref)])"
      />
   </xsl:function>

   <!-- ^V^V^V^V^V^V^V^V^V^V^V^V^V^V^V^V^V^V^V^V^V^V^V^V^V^V^V^V^V^V^V^V^V^V^V^V -->

   <xsl:template name="cross-links">
      <xsl:variable name="identifier" select="string-join(ancestor-or-self::*/@name,'/')"/>
      <!--<xsl:variable name="schema-base" select="replace($metaschema-code,'-xml$','')"/>-->
      <div class="crosslink">
         <a href="{$xml-definitions-page}/#{$identifier}">
            <button class="schema-link">Switch to XML</button>
         </a>
      </div>
   </xsl:template>
   

   <xsl:template match="define-flag" mode="make-definition">
      <section class="definition define-flag" id="global_{@name}">
         <xsl:call-template name="definition-header"/>
         <xsl:apply-templates select="description"/>
         <xsl:apply-templates select="." mode="representation-in-json"/>
         <xsl:for-each-group select="key('flag-references', @name)/parent::*" group-by="true()">
            <p><xsl:text>This property appears on: </xsl:text>
               <xsl:for-each-group select="current-group()" group-by="@name">
                  <xsl:if test="position() gt 1 and last() ne 2">, </xsl:if>
                  <xsl:if test="position() gt 1 and position() eq last()"> and </xsl:if>
                  <xsl:apply-templates select="." mode="link-usage"/>
               </xsl:for-each-group>.</p>
         </xsl:for-each-group>
         <xsl:call-template name="remarks-group"/>
         <xsl:call-template name="display-applicable-constraints"/>
         <xsl:call-template name="report-module"/>
      </section>
   </xsl:template>

   <xsl:template match="define-field" mode="make-definition">
      <xsl:variable name="showing-flags" select="(define-flag | flag)[not(@name=../json-value-key-flag/@flag-ref)]"/>
      <section class="definition define-field" id="global_{@name}">
         <xsl:call-template name="definition-header">
            <xsl:with-param name="make-page-links" tunnel="true" select="true()"/>
         </xsl:call-template>
         <xsl:apply-templates select="formal-name | description"/>
         <xsl:apply-templates mode="representation-in-json" select="."/>
         <xsl:apply-templates mode="appears-in" select="."/>
         <xsl:call-template name="remarks-group"/>
         
         <xsl:variable name="value-name">
            <xsl:apply-templates select="." mode="get-field-value-name"/>
         </xsl:variable>
         <xsl:variable as="element()?" name="value-property-proxy" expand-text="true">
            <xsl:if test="exists($showing-flags)">
               <m:define-flag name="{$value-name}" value-proxy="true" required="yes">
                  <xsl:copy-of select="@as-type"/>
                  <m:formal-name>{ formal-name } Value</m:formal-name>
                  <xsl:apply-templates select="." mode="get-field-value-description"/>
               </m:define-flag>
            </xsl:if>
         </xsl:variable>
         <xsl:if test="exists($value-property-proxy | $showing-flags)">
         <div class="model properties">
            <p class="subhead">
               <xsl:choose>
                  <xsl:when test="empty($showing-flags)">Property</xsl:when>
                  <xsl:otherwise>Properties</xsl:otherwise>
               </xsl:choose>
            </p>
            <ul>
               <xsl:apply-templates select="$value-property-proxy">
                  <xsl:with-param name="proxy-of" tunnel="true" select="."/>
                  <xsl:with-param name="make-page-links" tunnel="true" select="false()"/>
               </xsl:apply-templates>
               <xsl:apply-templates select="$showing-flags">
                  <xsl:with-param name="make-page-links" tunnel="true" select="false()"/>
               </xsl:apply-templates>
            </ul>
         </div>
         </xsl:if>
         <!--<xsl:call-template name="flags-for-field"/>-->
         <!-- Applicable constraints are produced by $value-property-proxy -->
         <!--<xsl:call-template name="display-applicable-constraints"/>-->
         <xsl:apply-templates select="example"/>
         <xsl:call-template name="report-module"/>
      </section>
   </xsl:template>

   <xsl:template match="define-assembly" mode="make-definition">
      <section class="definition define-assembly" id="global_{@name}">
         <xsl:call-template name="definition-header">
            <xsl:with-param name="make-page-links" tunnel="true" select="true()"/>
         </xsl:call-template>
         <xsl:apply-templates select="formal-name | description"/>
         <xsl:for-each select="root-name">
            <p class="h5"><code xsl:expand-text="true">{ . }</code> is a root (containing) object for thi
               schema.</p>
         </xsl:for-each>
         <xsl:apply-templates mode="appears-in" select="."/>
         <xsl:call-template name="remarks-group"/>
         <xsl:variable name="for-properties" select="flag | define-flag |
            model/(.|choice)/( define-field | define-assembly | field | assembly )"/>
         <xsl:for-each-group select="$for-properties" group-by="true()" expand-text="true">
            <div class="model properties">
               <p class="subhead">{ if (count(current-group()) eq 1) then 'Property' else
                  'Properties' } ({ count(current-group()) })</p>
               <ul>
                  <xsl:apply-templates select="current-group()">
                     <xsl:with-param name="make-page-links" tunnel="true" select="false()"/>
                  </xsl:apply-templates>
               </ul>
            </div>
         </xsl:for-each-group>
         <xsl:call-template name="display-applicable-constraints"/>
         <xsl:apply-templates select="example"/>
         <xsl:call-template name="report-module"/>
      </section>
   </xsl:template>

   <xsl:template match="*" mode="appears-in"/>
      
   <xsl:template match="/METASCHEMA/*" mode="appears-in">
      <xsl:variable name="flag-references" select="key('flag-references', @name)/self::flag"/>
      <xsl:variable name="field-references" select="key('field-references', @name)/self::field"/>
      <xsl:variable name="assembly-references" select="key('assembly-references', @name)/self::assembly"/>
      <xsl:variable name="references"
         select="$flag-references | $field-references | $assembly-references"/>
      <xsl:variable name="homonyms"
         select="key('using-name', m:use-name(.)) except (. | $references)"/>
      <xsl:call-template name="link-paragraph">
         <xsl:with-param name="link-to" select="($field-references | $assembly-references)[group-as/@in-json='BY_KEY']"/>
         <xsl:with-param name="statement">This object appears, with any others of its type, grouped as a property of </xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="link-paragraph">
         <xsl:with-param name="link-to" select="($field-references | $assembly-references)[group-as/@in-json='SINGLETON_OR_ARRAY']"/>
         <xsl:with-param name="statement">This object appears as a property of, or a member of an array property defined for </xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="link-paragraph">
         <xsl:with-param name="link-to" select="($field-references | $assembly-references)[ exists( group-as[not(@in-json=('BY_KEY','SINGLETON_OR_ARRAY'))] ) ]"/>
         <xsl:with-param name="statement" expand-text="true">This object appears as a member of an array property defined for </xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="link-paragraph">
         <xsl:with-param name="link-to"
            select="$flag-references | $homonyms/self::define-field | $homonyms/self::define-assembly"/>
         <xsl:with-param name="statement">A property of this name is also defined for
         </xsl:with-param>
      </xsl:call-template>
   </xsl:template>

   <xsl:template name="link-paragraph">
      <xsl:param name="link-to"/>
      <xsl:param name="statement"/>
      <xsl:for-each-group select="$link-to" group-by="true()">
         <p><xsl:text expand-text="true">{ $statement }</xsl:text>
            <xsl:for-each
               select="current-group()/ancestor::*[self::define-field | self::define-assembly][1]">
               <xsl:if test="position() gt 1 and last() ne 2">, </xsl:if>
               <xsl:if test="position() gt 1 and position() eq last()"> and </xsl:if>
               <xsl:apply-templates select="." mode="link-usage"/>
            </xsl:for-each>.</p>
      </xsl:for-each-group>
   </xsl:template>

   <xsl:template match="@name | @ref">
      <code>
         <xsl:value-of select="."/>
      </code>
   </xsl:template>

   <!--<xsl:template match="*[use-name|root-name]/@name | *[use-name]/@ref">
      <code>
         <xsl:apply-templates select="parent::*/use-name"/>
      </code>
   </xsl:template>-->


   <xsl:template match="define-flag/@name | flag/@name">
      <code>
         <xsl:value-of select="."/>
      </code>
   </xsl:template>

   <!-- list item templates  -->

   <xsl:template match="flag | define-flag">
      <li class="model-entry">
         <xsl:call-template name="model-description"/>
      </li>
   </xsl:template>

   <xsl:template match="field | define-field | assembly | define-assembly">
      <li class="model-entry">
         <xsl:call-template name="model-description"/>
      </li>
   </xsl:template>

   <!--<xsl:template match="define-field[@as-type='markup-multiline'][@in-xml='UNWRAPPED']">
      <li class="model-entry">
         <p>An optional sequence of prose (markup) elements including <code>p</code>, lists, tables and headers (<code>h1-h6</code>).</p>
         <xsl:call-template name="model-description"/>
      </li>
   </xsl:template>-->

   <xsl:template match="*" mode="requirement"> [0 or 1]</xsl:template>

   <xsl:template match="*[exists(@required)]" mode="requirement"> [1]</xsl:template>

   <xsl:template match="any">
      <li>Any property (not defined by OSCAL)</li>
   </xsl:template>

   <xsl:template name="model-description">
      <xsl:apply-templates select="." mode="model-description"/>
   </xsl:template>

   <xsl:template match="*" mode="model-description" expand-text="true">
      <xsl:message>UNEXPECTED MATCH ON { local-name() }</xsl:message>
   </xsl:template>

   <xsl:template match="*[group-as]" mode="model-description" priority="100">
      <div class="group-descr">
         <xsl:apply-templates select="." mode="group-header"/>
         <xsl:next-match/>
      </div>
   </xsl:template>

   <xsl:template match="*" mode="group-header" expand-text="true">
      <div class="model-summary">
         <p class="modeling usename">
            <xsl:value-of select="group-as/@name"/>
         </p>
         <span class="mtyp">
            <xsl:apply-templates select="." mode="group-type"/>
         </span>
         <span class="occurrence">
            <xsl:text expand-text="true">[{ if (not(@min-occurs != '0')) then 'optional' else 'required' }]</xsl:text>
         </span>
         <span>
            <xsl:apply-templates select="." mode="group-qualifier"/>
         </span>
      </div>
   </xsl:template>

   <xsl:template match="*" mode="group-type">array</xsl:template>

   <xsl:template match="*[@in-json = 'BY_KEY']" mode="group-type">object</xsl:template>

   <xsl:template match="*[@in-json = 'SINGLETON_OR_ARRAY']" mode="group-type">object (when a
      singleton) or array (when multiple)</xsl:template>

   <xsl:template match="*" mode="group-qualifier">
      <xsl:text>array of </xsl:text>
      <xsl:apply-templates mode="json-type" select="."/>
      <xsl:text>s</xsl:text>
   </xsl:template>

   <xsl:template match="*[@in-json = 'BY_KEY']" mode="group-type" expand-text="true">object's
      properties have keys bound to the <code>{ group-as/@json-key-flag }</code></xsl:template>

   <xsl:template match="*[@in-json = 'SINGLETON_OR_ARRAY']" mode="group-type">object (when a
      singleton) or array (when multiple)</xsl:template>

   <xsl:template match="*[exists(@ref)]" mode="model-description" expand-text="true">
      <xsl:param name="link-context" tunnel="true" required="yes"/>
      <!--<xsl:param    name="link-context" tunnel="true" select="ancestor::model[1]/parent::define-assembly | parent::define-field | parent::define-assembly)"/>-->
      <xsl:variable name="grouped" select="exists(group-as)"/>
      <xsl:variable name="definition" select="key('assembly-definitions', self::assembly/@ref) |
         key('field-definitions', self::field/@ref) | key('flag-definitions', self::flag/@ref)"/>
      <xsl:variable name="is-a-flag" select="exists(self::flag)"/>
      <!--<xsl:variable name="too-deep"
         select="exists(ancestor::model[2] | (parent::define-field | parent::define-assembly)/ancestor::model)"/>-->
      <xsl:if test="empty($definition)">
         <xsl:message>NO DEFINITION FOUND FOR { local-name() }</xsl:message>
      </xsl:if>
      <div class="model-descr" tabindex="0">
         <div class="model-summary">
            <p class="modeling usename">
               <xsl:apply-templates select="." mode="key-name"/>
            </p>
            <span class="mtyp">
               <xsl:apply-templates select="." mode="metaschema-type"/>
               <xsl:if test="empty($definition)">&#xA0;</xsl:if>
            </span>
            <span class="occurrence">
               <!-- should be 'requirement' with mode 'requirement' for flags -->
               <xsl:apply-templates select="self::flag | self::define-flag" mode="requirement"/>
               <xsl:apply-templates select=". except (self::flag | self::define-flag)"
                  mode="occurrence-code"/>
            </span>
            <span class="frmname">{ $definition/formal-name
               }{'&#xA0;'[empty($definition/formal-name)] }</span>
         </div>
         <xsl:apply-templates select="$definition/description"/>
         <xsl:apply-templates mode="make-link-to-global" select="."/>
         <xsl:for-each-group group-by="true()" select="remarks">
            <div class="remarks-group">
               <details open="open">
                  <summary class="subhead">Remarks (local)</summary>
                  <xsl:apply-templates select="current-group()"/>
               </details>
            </div>
         </xsl:for-each-group>
         <xsl:for-each-group group-by="true()" select="$definition/remarks">
            <div class="remarks-group">
               <details open="open">
                  <summary class="subhead">Remarks (general)</summary>
                  <xsl:apply-templates select="current-group()"/>
               </details>
            </div>
         </xsl:for-each-group>

         <xsl:call-template name="display-properties">
            <xsl:with-param name="definition" select="$definition"/>
         </xsl:call-template>
         <!--<xsl:apply-templates mode="make-contents" select="."/>-->
         <!--<xsl:call-template name="display-applicable-constraints"/>-->
      </div>
   </xsl:template>

   <xsl:template mode="key-name" match="*">
      <xsl:value-of select="m:use-name(.)"/>
   </xsl:template>

   <xsl:template mode="key-name" match="*[group-as/@in-json = 'ARRAY']">(array
      member)</xsl:template>

   <xsl:template mode="key-name" match="*[group-as/@in-json = 'BY_KEY']" expand-text="true">{{{
      group-as/@json-key-flag }}}</xsl:template>

   <xsl:template mode="key-name" match="*[group-as/@in-json = 'SINGLETON_OR_ARRAY']">(array member
      or object)</xsl:template>

   <xsl:template match="define-assembly | define-field | define-flag" mode="model-description"
      expand-text="true">
      <!-- when matching a define-flag produced dynamically as a value proxy (flag), $proxy-of
           is provided to indicate the node whose value this (define-flag) proxies. -->
      <xsl:param name="proxy-of" select="()" tunnel="true"/>
      <xsl:param name="link-context" tunnel="true" required="yes"/>
      <xsl:variable name="definition" select="."/>
      <xsl:variable name="grouped" select="exists(group-as)"/>
      <xsl:variable name="is-local" select="empty(parent::METASCHEMA)"/>
      <xsl:variable name="too-deep"
         select="exists(ancestor::model[2] | (parent::define-field | parent::define-assembly)/ancestor::model)"/>
      <xsl:variable name="is-a-flag" select="exists(self::define-flag)"/>
      <div class="model-descr" tabindex="0"
         id="#local_{ string-join( ($link-context/@name,ancestor-or-self::*/@name),'-') }">
         <!--<xsl:if test="$make-page-links">
            <xsl:attribute name="id" select="'#local_' || string-join( ancestor-or-self::*/@name,'-')"/>
         </xsl:if>-->
         <div class="model-summary{ ' definition-header'[$is-local] }">
            <p class="modeling { ' usename'[not($grouped)]}">
               <xsl:apply-templates select="." mode="key-name"/>
            </p>
            <span class="mtyp">
               <xsl:apply-templates select="." mode="metaschema-type"/>
            </span>
            <span class="occurrence">
               <!-- should be 'requirement' with mode 'requirement' for flags -->
               <xsl:apply-templates select="self::flag | self::define-flag" mode="requirement"/>
               <xsl:apply-templates select=". except (self::flag | self::define-flag)"
                  mode="occurrence-code">
                  <xsl:with-param name="require-member" select="exists(group-as)"/>
               </xsl:apply-templates>
            </span>
            <span class="frmname">{ $definition/formal-name
               }{'&#xA0;'[empty($definition/formal-name)] }</span>
         </div>
         <xsl:apply-templates select="$definition/description"/>
         <xsl:apply-templates mode="make-link-to-global" select="."/>
         <xsl:for-each-group group-by="true()" select="remarks">
            <div class="remarks-group">
               <details open="open">
                  <summary class="subhead">Remarks</summary>
                  <xsl:apply-templates select="current-group()"/>
               </details>
            </div>
         </xsl:for-each-group>

         <xsl:call-template name="display-properties">
            <xsl:with-param name="definition" select="$definition"/>
         </xsl:call-template>

         <!--<xsl:apply-templates mode="make-contents" select="."/>-->
        <!-- <xsl:if test="exists($proxy-of)">
            <xsl:message expand-text="true">seeing proxy-of: { local-name($proxy-of) } { $proxy-of/@name }</xsl:message>
         </xsl:if>-->
         <xsl:call-template name="display-applicable-constraints">
            <xsl:with-param name="context" select="($proxy-of,.)[1]"/>
         </xsl:call-template>
      </div>
   </xsl:template>

   <xsl:template name="display-properties">
      <xsl:param name="definition" select="."/>
      <xsl:variable name="for-properties" select="flag | define-flag |
         model/(.|choice)/( define-field | define-assembly | field | assembly )"/>
      <xsl:for-each-group select="$for-properties" group-by="true()" expand-text="true">
         <div class="properties">
            <details>
               <summary class="subhead">
                  <xsl:text>{ if (count(current-group()) eq 1) then 'Property' else 'Properties' } ({ count(current-group()) }): </xsl:text>
                  <xsl:for-each select="current-group()">
                     <xsl:if test="not(position() eq 1)">, </xsl:if>
                     <code>{ (m:use-name(.),@name,@ref,local-name())[1] }</code>
                  </xsl:for-each>
               </summary>
               <ul>
                  <xsl:apply-templates select="current-group()">
                     <xsl:with-param name="link-context" tunnel="true" select="$definition"/>
                  </xsl:apply-templates>
               </ul>
            </details>
         </div>
      </xsl:for-each-group>

      <!--<xsl:for-each-group select="$definition/(define-flag | flag)" group-by="true()" expand-text="true">
         <div class="attributes">
            <details open="open">
               <summary  class="subhead">
                  <xsl:text>{ if (count(current-group()) eq 1) then 'Attribute' else 'Attributes' } ({ count(current-group()) }): </xsl:text>
                  <xsl:for-each select="current-group()">
                     <xsl:if test="not(position() eq 1)">, </xsl:if>
                     <code>{ m:use-name(.) }</code>
                  </xsl:for-each></summary>
               <ul>
                  <xsl:apply-templates select="current-group()">
                     <xsl:with-param name="make-page-links" tunnel="true" select="false()"/>
                  </xsl:apply-templates>
               </ul>
            </details>
         </div>
      </xsl:for-each-group>-->
   </xsl:template>


   <xsl:template match="flag | define-flag | define-field | define-assembly"
      mode="make-link-to-global"/>

   <xsl:template match="*" mode="make-link-to-global" expand-text="true">
      <div class="deflink">
         <!-- XXX -->
         <a href="#xxx">Link to <code>{ m:use-name(.) }</code> global definition to see
            contents.</a>
      </div>
   </xsl:template>

   <!--<!-\- Showing model contents only for local assembly definitions. -\->
   <xsl:template match="*" mode="make-contents"/>
   
   <xsl:template match="define-assembly" mode="make-contents" expand-text="true">
      <xsl:apply-templates select="model" mode="#current"/>
   </xsl:template>
   
   <xsl:template match="define-assembly/model" mode="make-contents">
      <!-\- for local define-assembly only, we dump -\->
      <details open="open">
         <summary class="subhead">Element content<xsl:if test="count(*) > 1">s (in
            order)</xsl:if></summary>
         <ul>
            <xsl:apply-templates>
               <xsl:with-param name="make-page-links" tunnel="true" select="false()"/>
            </xsl:apply-templates>
         </ul>
      </details>
   </xsl:template>-->


   <xsl:template match="constraint" expand-text="true">
      <details open="open" class="constraint-set">
         <xsl:variable name="constraints"
            select=".//allowed-values | .//matches | .//has-cardinality | .//is-unique | .//index-has-key | .//index"/>
         <summary class="subhead"><span class="usa-tag">{ if (count($constraints) eq 1) then
               'constraint' else 'constraints'}</span> Defined in this context:</summary>
         <xsl:apply-templates select="$constraints"/>
      </details>
   </xsl:template>

   <xsl:template name="and-code-sequence">
      <xsl:param name="what" as="item()*"/>
      <xsl:for-each select="$what[position() lt last()]">
         <code>
            <xsl:value-of select="."/>
         </code>
      </xsl:for-each>
      <xsl:if test="count($what) gt 1"> and </xsl:if>
      <code>
         <xsl:value-of select="$what[last()]"/>
      </code>
   </xsl:template>

   <xsl:template priority="3" match="constraint//require">
      <xsl:apply-templates/>
   </xsl:template>

   <xsl:key name="constraints-for-target"
      match="index | index-has-key | is-unique | has-cardinality | allowed-values | matches"
      use="m:constraint-key(.)"/>

   <!-- For multiple targets are given there could be multiple keys -->
   <xsl:function name="m:constraint-key" as="xs:string*">
      <xsl:param name="who" as="element()"/>
      <!--<xsl:value-of select="local-name($who)"/>-->
      <xsl:choose>
         <xsl:when test="$who/@target = ('.', 'value()')">
            <xsl:sequence select="$who/ancestor::constraint/parent::*/m:use-name(.)"/>
         </xsl:when>
         <xsl:when test="empty($who/@target)">
            <xsl:sequence select="$who/ancestor::constraint/parent::*/m:use-name(.)"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:sequence
               select="($who/m:express-targets(@target) ! tokenize(., '/')[last()]) => distinct-values()"
            />
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>

   <!--<xsl:function name="m:constraint-key" as="xs:string">
      <xsl:param name="who" as="element()"/>
      <xsl:text>boo</xsl:text>
   </xsl:function>-->

   <xsl:template match="*" mode="report-context" expand-text="true">
      <code>
         <xsl:for-each select="ancestor::define-field | ancestor::define-assembly">
            <xsl:if test="exists(ancestor::define-field | ancestor::define-assembly)">/</xsl:if>
            <xsl:value-of select="m:use-name(.)"/>
         </xsl:for-each>
         <xsl:for-each select="ancestor::define-flag">
            <xsl:if test="exists(ancestor::define-field | ancestor::define-assembly)">/</xsl:if>
            <xsl:text>@</xsl:text>
            <xsl:value-of select="m:use-name(.)"/>
         </xsl:for-each>
         <xsl:for-each select="ancestor::require">[{@when}]</xsl:for-each>
         <xsl:apply-templates select="." mode="report-target"/>
      </code>
   </xsl:template>

   <xsl:template match="*" mode="report-target">
      <xsl:text>/</xsl:text>
      <xsl:value-of select="@target"/>
   </xsl:template>

   <xsl:template priority="3" mode="report-target" match="has-cardinality"/>

   <xsl:template priority="2" mode="report-target"
      match="*[empty(@target) or @target = ('.', 'value()')]"/>

   <xsl:template priority="2" match="allowed-values" expand-text="true">
      <xsl:variable name="enums" select="enum"/>
      <div class="constraint">
         <p>
            <span class="cnstr-tag">allowed value{ 's'[count($enums) gt 1] }</span>
            <xsl:text> for </xsl:text>
            <xsl:apply-templates select="." mode="report-context"/>
            <!-- insert for a hidden box <span class="gloss">
               <xsl:for-each select="enum">
                  <xsl:if test="position() gt 1"> | </xsl:if>
                  <strong>{ @value }</strong>
               </xsl:for-each>
            </span>-->
         </p>
         <xsl:choose expand-text="true">
            <xsl:when test="@allow-other and @allow-other = 'yes'">
               <p>The value <b>may be locally defined,</b> or { 'one of '[count($enums) gt 1] }the following:</p>
            </xsl:when>
            <xsl:otherwise>
               <p>The value <b>must be</b> { 'one of '[count($enums) gt 1] } the following:</p>
            </xsl:otherwise>
         </xsl:choose>
         <ul>
            <xsl:apply-templates/>
         </ul>
      </div>
   </xsl:template>

   <xsl:template priority="2" match="matches[@regex]" expand-text="true">
      <xsl:variable name="target" select="@target[not(. = ('.', 'value()'))]"/>
      <div class="constraint">
         <p>
            <span class="usa-tag">constraint</span>
            <xsl:apply-templates select="." mode="report-context"/>
            <span class="cnstr-tag">match</span>
            <xsl:text expand-text="true"> a target (value) must match the regular expression '{ @regex }'.</xsl:text>
         </p>
      </div>
   </xsl:template>


   <xsl:template priority="2" match="matches[@datatype]" expand-text="true">
      <div class="constraint">
         <p>
            <span class="usa-tag">constraint</span>
            <xsl:apply-templates select="." mode="report-context"/>
            <span class="cnstr-tag">match</span>
            <xsl:text>the target value must match the lexical form of the '{ @datatype }' data type.</xsl:text>
         </p>
      </div>
   </xsl:template>

   <xsl:template priority="2" match="is-unique">
      <xsl:variable name="target" select="@target[not(. = ('.', 'value()'))]"/>
      <div class="constraint">
         <p>
            <span class="usa-tag">constraint</span>
            <xsl:apply-templates select="." mode="report-context"/>
            <span class="cnstr-tag">uniqueness rule</span>
            <xsl:text>: any target value must be unique (i.e., occur only once)</xsl:text>
         </p>
      </div>
   </xsl:template>

   <xsl:template priority="2" match="has-cardinality" expand-text="true">
      <div class="constraint">
         <p>
            <span class="usa-tag">constraint</span>
            <xsl:apply-templates select="." mode="report-context"/>
            <span class="cnstr-tag">cardinality rule</span>
            <xsl:text> the cardinality of  </xsl:text>
            <code>{ @target }</code>
            <xsl:text> is constrained: </xsl:text>
            <b>{ (@min-occurs,0)[1] }</b>
            <xsl:text>; maximum </xsl:text>
            <b>{ (@max-occurs,'unbounded')[1]}</b>.</p>
      </div>
   </xsl:template>

   <xsl:template priority="2" match="index-has-key" expand-text="true">
      <xsl:variable name="target" select="@target[not(. = ('.', 'value()'))]"/>
      <div class="constraint">
         <p>
            <span class="usa-tag">constraint</span>
            <xsl:apply-templates select="." mode="report-context"/>
            <span class="cnstr-tag">index rule</span>
            <xsl:text>this value must correspond to a listing in the index </xsl:text>
            <code>{ @name }</code>
            <xsl:text> using a key constructed of key field(s) </xsl:text>
            <xsl:for-each select="key-field">
               <xsl:if test="position() gt 1">; </xsl:if>
               <code>
                  <xsl:value-of select="@target"/>
               </code>
            </xsl:for-each>
         </p>
      </div>
   </xsl:template>

   <xsl:template priority="2" match="index" expand-text="true">
      <div class="constraint">
         <p>
            <span class="usa-tag">constraint</span>
            <xsl:apply-templates select="." mode="report-context"/>
            <span class="cnstr-tag">index definition</span>
            <xsl:text> an index </xsl:text>
            <code>{ @name }</code>
            <xsl:text> shall list values returned by targets </xsl:text>
            <code>{ @target }</code>
            <xsl:text> using keys constructed of key field(s) </xsl:text>
            <xsl:for-each select="key-field">
               <xsl:if test="position() gt 1">; </xsl:if>
               <code>
                  <xsl:value-of select="@target"/>
               </code>
            </xsl:for-each>
         </p>
      </div>
   </xsl:template>

   <!-- Only display allowed-values for now -->
   <xsl:template name="display-applicable-constraints">
      <xsl:param name="context" select="."/>
      <xsl:variable name="applicable-constraints"
         select="$context/key('constraints-for-target', m:use-name(.), $home)[m:include-constraint(., $context)]"/>
      <!-- debug <xsl:if test="@name='property'">
         <xsl:message expand-text="true">{ local-name(.) } { m:use-name(.) } { count($applicable-constraints) }</xsl:message>
         <xsl:for-each select="$applicable-constraints/self::allowed-values">
            <xsl:message expand-text="true">{ serialize(.) }</xsl:message>
         </xsl:for-each>
      </xsl:if>-->
      <xsl:for-each-group select="$applicable-constraints/self::allowed-values" group-by="true()"
         expand-text="true">
         <div class="constraints">
            <xsl:apply-templates select="current-group()"/>
            <!--<xsl:for-each-group select="$applicable-constraints except $applicable-constraints/self::allowed-values" group-by="true()">
               <details>
                  <summary class="subhead">Applicable { if (count(current-group()) eq 1) then 'constraint' else 'constraints' } ({ count(current-group()) })</summary>
                  <xsl:apply-templates select="current-group()"/>
               </details>
            </xsl:for-each-group>-->
         </div>
      </xsl:for-each-group>
   </xsl:template>

   <!-- key 'constraints-for-target' is too greedy: for a reference appearing in a local definition,
     the definition context can exclude constraints that are defined to apply to the node in other contexts.
     This filter returns 'true' pairwise for any constraint and context-indicating element (whether definition or reference),
     when the two overlap. This must account for when constraints designate multiple targets. -->
   <xsl:function name="m:include-constraint" as="xs:boolean">
      <xsl:param name="constraint" as="element()"/>
      <!-- has-cardinality, matches, allowed-values etc -->
      <xsl:param name="context" as="element()"/>
      <!-- assembly, field, flag, define-assembly, define-field, define-flag -->
      <xsl:variable name="context-path"
         select="string-join($context/(ancestor::* | .) ! m:use-name(.), '/')"/>
      <xsl:variable name="constraint-context-path"
         select="string-join($constraint/ancestor-or-self::*/m:use-name(.), '/')"/>
      <xsl:variable name="constraint-targets" as="xs:string*">
         <xsl:choose>
            <xsl:when test="empty($constraint/@target)">
               <xsl:sequence select="$constraint-context-path"/>
            </xsl:when>
            <xsl:otherwise>
               <xsl:sequence
                  select="$constraint/@target/m:express-targets(.) ! string-join(($constraint-context-path, .[normalize-space(.)]), '/')"
               />
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>
      <!-- debugging <xsl:if test="contains($context-path,'control')">
         <xsl:message expand-text="true">on { name($constraint)}, testing { $context-path } against { string-join($constraint-targets,', ')} getting { m:match-paths($constraint-targets[1],$context-path)}</xsl:message>
      </xsl:if>-->
      <xsl:sequence
         select="
            some $t in $constraint-targets
               satisfies
               m:match-paths($t, $context-path)"
      />
   </xsl:function>

   <xsl:template mode="make-definition" match="field | flag | assembly"/>

   <!--<xsl:template mode="make-definition" match="field | flag | assembly"/>
      <xsl:apply-templates select="key('definitions',@ref)" mode="make-definition"/>
   </xsl:template>-->


   <!-- remarks are kept if @class='xml' or no class is given -->
   <xsl:template match="remarks[@class != 'json']" priority="2"/>

   <xsl:template match="remarks[@class = 'json']/p[1]">
      <p class="p">
         <span class="usa-tag">JSON</span>
         <xsl:text> </xsl:text>
         <xsl:apply-templates/>
      </p>
   </xsl:template>

   <xsl:template match="remarks/p" mode="model #default">
      <p class="p">
         <xsl:apply-templates/>
      </p>
   </xsl:template>

   <xsl:template match="example"/>

   <!-- XXX FIX, then pull the 'dev' mode  -->
   <xsl:template match="example" mode="dev">
      <xsl:variable name="example-no" select="'example' || count(. | preceding-sibling::example)"/>
      <div class="example usa-accordion">
         <p>
            <button class="usa-accordion__button" aria-expanded="true"
               aria-controls="{ ../@name }_{$example-no}_xml">
               <xsl:text>Example</xsl:text>
               <xsl:for-each select="description">: <xsl:apply-templates/></xsl:for-each>
            </button>
         </p>
         <div id="{ m:use-name(..) }_{ $example-no }_xml"
            class="example-content usa-accordion__content usa-prose">
            <xsl:apply-templates select="remarks"/>
            <pre>
               <!-- 'doe' span can be wiped in post-process, but permits disabling output escaping -->
               <span class="doe">&#xA;{{&lt; highlight xml "linenos=table" > }}&#xA;</span>
               <xsl:apply-templates select="*" mode="as-example"/>
               <span class="doe">&#xA;{{ &lt;/ highlight > }}&#xA;</span>
            </pre>
         </div>
      </div>
   </xsl:template>

   <!-- mode as-example filters metaschema elements from elements representing examples -->
   <xsl:template match="m:*" xmlns:m="http://csrc.nist.gov/ns/oscal/metaschema/1.0"
      mode="as-example"/>

   <xsl:template match="define-flag | define-field[empty(flag | define-flag)]"
      mode="representation-in-json">
      <xsl:variable name="json-object-type">
         <xsl:apply-templates select="." mode="json-type"/>
      </xsl:variable>
      <xsl:variable name="datatype">
         <xsl:apply-templates select="." mode="metaschema-type"/>
      </xsl:variable>
      <p>
         <xsl:text>A </xsl:text>
         <xsl:sequence select="$json-object-type"/>
         <xsl:text> conforming to the lexical and value-space requirements defined for </xsl:text>
         <xsl:sequence select="$datatype"/>
         <xsl:text>.</xsl:text>
      </p>
      <xsl:apply-templates select="." mode="type-annotation"/>
   </xsl:template>
   
   <xsl:template match="define-field" mode="representation-in-json">
      <xsl:apply-templates select="." mode="type-annotation"/>
   </xsl:template>

   <xsl:template match="*" mode="get-field-value-name">STRVALUE</xsl:template>
   
   <xsl:template match="*[@as-type='markup-multiline']" mode="get-field-value-name">RICHTEXT</xsl:template>
   
   <xsl:template match="*[exists(json-value-key)]" mode="get-field-value-name">
      <xsl:value-of select="json-value-key"/>   
   </xsl:template>
   
   <xsl:template priority="2" match="*[exists(json-value-key-flag/@flag-ref)]" mode="get-field-value-name">
      <xsl:text>{{taken as the </xsl:text>
      <em>
      <xsl:value-of select="json-value-key-flag/@flag-ref"/>
      </em>
      <xsl:text> property}}</xsl:text>
   </xsl:template>
   
   <xsl:template match="*" mode="get-field-value-description">
      <m:description>This property provides the (nominal) value for this object as a whole.</m:description>
   </xsl:template>
   
   <xsl:template priority="2" match="*[exists(json-value-key-flag/@flag-ref)]" mode="get-field-value-description">
      <m:description>A property whose name is distinct from assigned properties for this object is taken as its (nominal) value, while its key is taken to be the value of the <code><xsl:value-of select="json-value-key-flag/@flag-ref"/></code> property.</m:description>
   </xsl:template>
   
   <xsl:template match="*" mode="type-annotation"/>
      
   <xsl:template match="*[@as-type = 'markup-multiline']" mode="type-annotation">
      <p>As such, this value permits expression of marked up text in Markdown format, according to
         the rules described for the (text-based) datatype. This datatype permits the expression of
            <em>block-level</em> constructs including paragraphs, lists and simple tables,
         potentially including simple formatting such as bold or typographic emphasis. This
         representation is designed for the relatively unconstrained capture of simple <q>free
            text</q>, i.e. without formatting or <q>decoration</q> that might serve as ad-hoc and
         uncontrolled semantic encoding not subject to detection, regularization or validation.</p>
      <p>This data construct is designed to be minimalistic for
         purposes of ease of development and interchange. It will not fit all operational scenarios;
         when <xsl:apply-templates select="." mode="metaschema-type"/> is not adequate for purposes
         of necessary (informational) fidelity to information encoded in source formats (and
         subsequently converted into OSCAL), alternative strategies are available for such data
         capture. Users and stakeholders who expose requirements in this area are encouraged to
         provide feedback and request guidance.</p>
   </xsl:template>
   
   <xsl:template match="*[@as-type = 'markup-line']" mode="type-annotation">
      <p>As such, this value permits expression of marked up text in Markdown format, according to
         the rules described for the (text-based) datatype. This datatype permits the expression of
         <em>inline</em> constructs, including text marked as strong, bold or emphatic.</p>
      <p>This data construct is designed to be minimalistic for
         purposes of ease of development and interchange. It will not fit all operational scenarios;
         when <xsl:apply-templates select="." mode="metaschema-type"/> is not adequate for purposes
         of necessary (informational) fidelity to information encoded in source formats (and
         subsequently converted into OSCAL), alternative strategies are available for such data
         capture. Users and stakeholders who expose requirements in this area are encouraged to
         provide feedback and request guidance.</p>
   </xsl:template>
   
   <xsl:template match="field" mode="metaschema-type">
      <xsl:apply-templates select="key('field-definitions', @ref)" mode="#current"/>
   </xsl:template>
   
   <xsl:template match="assembly" mode="metaschema-type">
      <xsl:apply-templates select="key('assembly-definitions', @ref)" mode="#current"/>
   </xsl:template>
   
   <xsl:template mode="metaschema-type" match="define-field[empty(flag | define-flag)]">
      <xsl:variable name="given-type" select="(@as-type, 'string')[1]"/>
      <a href="{$datatype-page}/#{(lower-case($given-type))}">
         <xsl:apply-templates mode="#current" select="$given-type"/>
      </a>
   </xsl:template>
   
   <xsl:template mode="metaschema-type" match="flag | define-flag">
      <xsl:variable name="given-type"
         select="(@as-type, key('flag-definitions', @ref, $home)/@as-type, 'string')[1]"/>
      <a href="{$datatype-page}/#{(lower-case($given-type))}">
         <xsl:apply-templates mode="#current" select="$given-type"/>
      </a>
   </xsl:template>
   
   <xsl:variable name="numeric-types"
      select="'boolean', 'integer', 'positiveInteger', 'nonNegativeInteger'"/>

   <xsl:template mode="metaschema-type json-type" match="define-assembly | define-field"
      >object</xsl:template>
   
   <xsl:template mode="json-type" match="*[exists(@ref)]">
      <xsl:variable name="definition" select="key('assembly-definitions', self::assembly/@ref,$home) |
         key('field-definitions', self::field/@ref,$home) | key('flag-definitions', self::flag/@ref,$home)"/>
      <xsl:apply-templates mode="#current" select="$definition"/>
   </xsl:template>
   
   <xsl:template mode="json-type" match="*">object</xsl:template>
   
   
   <!--<xsl:variable name="definition" select="key('assembly-definitions', self::assembly/@ref) |
      key('field-definitions', self::field/@ref) | key('flag-definitions', self::flag/@ref)"/>
   -->
   
   <xsl:template mode="json-type"
      match="define-field[empty(flag | define-flag)]">
      <xsl:variable name="given-type" select="(@as-type, 'string')[1]"/>      
      <xsl:choose>
         <xsl:when test="$given-type = 'boolean'">boolean value</xsl:when>
         <xsl:when test="$given-type = $numeric-types">numeric value</xsl:when>
         <xsl:otherwise>string</xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   
   <xsl:template mode="json-type"
      match="flag | define-flag">
      <xsl:variable name="given-type"
         select="(@as-type, key('flag-definitions', @ref)/@as-type, 'string')[1]"/>
      <xsl:choose>
         <xsl:when test="$given-type = 'boolean'">boolean value</xsl:when>
         <xsl:when test="$given-type = $numeric-types">numeric value</xsl:when>
         <xsl:otherwise>string</xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   
   <xsl:template mode="metaschema-type" match="METASCHEMA/define-assembly">
      <!-- XXX -->
      <a href="#xxx">object (globally&#xA0;defined)</a>
   </xsl:template>

   <xsl:template match="*" mode="metaschema-type">
      <xsl:message>Matching <xsl:value-of select="local-name()"/></xsl:message>
   </xsl:template>

   <xsl:template mode="build-index" match="*">
      <details class="constraint-index">
         <xsl:apply-templates select=".." mode="constraint-context"/>
         <xsl:apply-templates select="."/>
      </details>
   </xsl:template>

   <xsl:template match="*" mode="constraint-context">
      <summary>In <xsl:apply-templates
            select="ancestor::define-assembly | ancestor::define-field | ancestor::define-flag"
            mode="read-context"/>
         <xsl:apply-templates select="ancestor::require" mode="read-context"/>
      </summary>
   </xsl:template>

   <xsl:template match="define-assembly | define-field" mode="read-context">
      <xsl:if test="position() gt 1">/</xsl:if>
      <xsl:apply-templates select="@name"/>
   </xsl:template>

   <xsl:template match="define-flag" mode="read-context">
      <xsl:if test="position() gt 1">/@</xsl:if>
      <xsl:apply-templates select="@name"/>
   </xsl:template>

   <xsl:template match="require" mode="read-context">
      <xsl:text> when </xsl:text>
      <code>
         <xsl:apply-templates select="@when"/>
      </code>
   </xsl:template>

   <xsl:function name="m:use-name" as="xs:string?">
      <xsl:param name="who" as="element()"/>
      <xsl:variable name="definition" select="$who/self::assembly/key('assembly-definitions', @ref) |
         $who/self::field/key('field-definitions', @ref) | $who/self::flag/key('flag-definitions',@ref)"/>
      <xsl:variable name="using-name"
         select="($who/self::any/'ANY', $who/root-name, $who/use-name, $definition/root-name, $definition/use-name, $definition/@name,$who/@name)[1]"/>
      <!--<xsl:if test="$who/self::field/@ref='all'">
         <xsl:message expand-text="true">seeing 'all'; m:use-name is { $using-name }</xsl:message>
      </xsl:if>
      <xsl:if test="empty($using-name)">
         <xsl:message expand-text="true">not seeing a usable name on { local-name($who) || ' ' || $who/(@name|@ref)}</xsl:message>
      </xsl:if>-->
      
      <!--<xsl:if test="exists($who/(self::field|self::assembly|self::flag)) and empty($definition">
         <xsl:message expand-text="true">no use name for { $who/local-name() }</xsl:message>
      </xsl:if>-->
      <xsl:sequence select="$using-name"/>
      
      <!--<xsl:sequence
         select="$who/(self::define-assembly|self::define-field|self::define-flag|self::assembly|self::field|self::flag)/
         (root-name, key('definitions',@ref)/root-name, @name, @ref)[1]"/>
      <xsl:if test="empty( $who/(self::define-assembly|self::define-field|self::define-flag|self::assembly|self::field|self::flag)/
         (root-name, key('definitions',@ref)/root-name, @name, @ref)[1] )">
         <xsl:message expand-text="true">asking for use-name from { local-name($who) }</xsl:message>
      </xsl:if>-->
      <!--<xsl:sequence
         select="$who/(self::define-assembly|self::define-field|self::define-flag|self::assembly|self::field|self::flag)/
         (root-name, use-name, key('definitions',@ref)/(root-name, use-name, @name), @name, @ref)[1]"/>-->
   </xsl:function>

</xsl:stylesheet>
