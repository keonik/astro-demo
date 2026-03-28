<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:atom="http://www.w3.org/2005/Atom">
  <xsl:output method="html" version="1.0" encoding="UTF-8" indent="yes"/>
  <xsl:template match="/">
    <html xmlns="http://www.w3.org/1999/xhtml" lang="en">
      <head>
        <title><xsl:value-of select="/rss/channel/title"/> — RSS Feed</title>
        <meta charset="utf-8"/>
        <meta name="viewport" content="width=device-width, initial-scale=1"/>
        <style>
          * { margin: 0; padding: 0; box-sizing: border-box; }
          body { font-family: system-ui, -apple-system, sans-serif; line-height: 1.6; color: #1f2937; max-width: 48rem; margin: 0 auto; padding: 2rem 1.5rem; }
          .badge { display: inline-block; background: #dbeafe; color: #1e40af; font-size: 0.75rem; font-weight: 600; padding: 0.25rem 0.75rem; border-radius: 9999px; margin-bottom: 1rem; }
          h1 { font-size: 1.5rem; font-weight: 700; margin-bottom: 0.25rem; }
          .description { color: #6b7280; margin-bottom: 0.5rem; }
          .subscribe { color: #6b7280; font-size: 0.875rem; margin-bottom: 2rem; }
          .subscribe code { background: #f3f4f6; padding: 0.125rem 0.375rem; border-radius: 0.25rem; font-size: 0.8125rem; }
          hr { border: none; border-top: 1px solid #e5e7eb; margin: 1.5rem 0; }
          .item { padding: 1rem 0; }
          .item h2 { font-size: 1.125rem; font-weight: 600; }
          .item h2 a { color: #2563eb; text-decoration: none; }
          .item h2 a:hover { text-decoration: underline; }
          .item .date { font-size: 0.8125rem; color: #9ca3af; margin-top: 0.125rem; }
          .item .summary { color: #4b5563; margin-top: 0.375rem; font-size: 0.9375rem; }
          @media (prefers-color-scheme: dark) {
            body { background: #030712; color: #e5e7eb; }
            .badge { background: #1e3a5f; color: #93c5fd; }
            .description, .subscribe { color: #9ca3af; }
            .subscribe code { background: #1f2937; }
            hr { border-color: #374151; }
            .item h2 a { color: #60a5fa; }
            .item .date { color: #6b7280; }
            .item .summary { color: #9ca3af; }
          }
        </style>
      </head>
      <body>
        <span class="badge">RSS Feed</span>
        <h1><xsl:value-of select="/rss/channel/title"/></h1>
        <p class="description"><xsl:value-of select="/rss/channel/description"/></p>
        <p class="subscribe">Subscribe by copying this URL into your RSS reader: <code><xsl:value-of select="/rss/channel/link"/>/rss.xml</code></p>
        <hr/>
        <xsl:for-each select="/rss/channel/item">
          <div class="item">
            <h2><a><xsl:attribute name="href"><xsl:value-of select="link"/></xsl:attribute><xsl:value-of select="title"/></a></h2>
            <p class="date"><xsl:value-of select="pubDate"/></p>
            <p class="summary"><xsl:value-of select="description"/></p>
          </div>
        </xsl:for-each>
      </body>
    </html>
  </xsl:template>
</xsl:stylesheet>
