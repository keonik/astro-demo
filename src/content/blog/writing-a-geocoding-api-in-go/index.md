---
title: "Writing a Geocoding API in Go (Coming from TypeScript)"
date: "Mar 18 2026"
draft: false
summary: What it's like switching from TypeScript to Go for an API project — the good, the painful, and the surprisingly ergonomic PostGIS queries.
tldr: Go compiles to a single binary with no runtime. Echo feels like Hono. PostGIS is magic. Error handling is verbose but saves you. Zero regrets.
tags:
  - go
  - typescript
  - postgresql
  - postgis
  - api
---

## Story time

I've been writing TypeScript professionally for years. Bun, Hono, React — that's my comfort zone. So why write a geocoding API in Go?

Partly curiosity. Partly because the geocoding API for [Gameplan Network](https://gameplannetwork.com) needed to be fast, standalone, and easy to deploy without a Node/Bun runtime. Go compiles to a single binary. No runtime dependencies. No `node_modules`. Just a binary and a database connection string.

![Michael Scott - Sometimes I'll start a sentence](https://media.giphy.com/media/lqczWksNBr4HK/giphy.gif)

That was enough to convince me to try it.

## The project

A REST API that does geocoding lookups using US ZIP codes and Ohio address data:

- ZIP code lookup with population, density, coordinates, county info
- City/state search
- Ohio address data from official state sources
- Shapefile-to-GeoJSON conversion via GDAL
- PostGIS for all the geospatial queries

## Echo: the Hono of Go

I picked [Echo](https://echo.labstack.com/) as the HTTP framework, and it immediately felt familiar. Route groups, middleware, context objects — the patterns map almost 1:1 to Hono.

```go
e := echo.New()

e.GET("/api/zip/:code", getZipCode)
e.GET("/api/zip/search", searchZipCodes)
e.GET("/api/addresses/search", searchAddresses)
```

Compare that to Hono:

```typescript
app.get("/api/zip/:code", getZipCode);
app.get("/api/zip/search", searchZipCodes);
app.get("/api/addresses/search", searchAddresses);
```

If you squint hard enough they're the same thing. The main difference is the handler signature — in Hono you destructure the context, in Echo you receive it as a single argument. Both feel natural once you adjust.

![Jim - Not bad](https://media.giphy.com/media/GCvktC0KFy9l6/giphy.gif)

## PostGIS is actual magic

The real star of this project isn't Go — it's PostGIS. Geospatial queries that would take hundreds of lines of application code become one SQL statement:

```sql
SELECT zip_code, city, state,
       ST_Distance(
         geom::geography,
         ST_SetSRID(ST_MakePoint($1, $2), 4326)::geography
       ) AS distance_meters
FROM zip_codes
WHERE ST_DWithin(
  geom::geography,
  ST_SetSRID(ST_MakePoint($1, $2), 4326)::geography,
  $3
)
ORDER BY distance_meters;
```

"Find all ZIP codes within X meters of these coordinates, sorted by distance." One query. PostGIS handles the spatial indexing, the geodetic math, all of it.

If you're doing anything location-based and you're not using PostGIS, you're working too hard. I mean it.

![Dwight - Fact](https://media.giphy.com/media/1Z02vuppxP1Pa/giphy.gif)

## What felt different coming from TypeScript

### Error handling

Go's `if err != nil` pattern is the most discussed aspect of the language. And yeah — it's verbose.

```go
zipCode, err := repo.FindByCode(code)
if err != nil {
    return c.JSON(http.StatusInternalServerError, map[string]string{
        "error": "Failed to look up ZIP code",
    })
}
if zipCode == nil {
    return c.JSON(http.StatusNotFound, map[string]string{
        "error": "ZIP code not found",
    })
}
```

But after a few weeks, I started appreciating the explicitness. In TypeScript, errors can fly through async chains silently. In Go, every function call that can fail forces you to decide what to do about it right there. Annoying? Sometimes. Saves you at 2am? Absolutely.

### No undefined

In TypeScript, you're always juggling `null`, `undefined`, and the zero value. In Go, zero values are well-defined and predictable. An empty string is `""`. An unset int is `0`. There's no `undefined` gotcha lurking in the shadows.

### Compilation speed

Go compiles so fast it feels like an interpreted language. Coming from TypeScript where `tsc` can take 10+ seconds on a large project, Go's sub-second compilation is... refreshing. Like unreasonably refreshing.

![Kevin - It's probably the thing I do best](https://media.giphy.com/media/ynRrAHj5SWAu8RA002/giphy.gif)

### The standard library is actually good

`net/http`, `encoding/json`, `database/sql` — you can build a production API with just the standard library. I used Echo for ergonomics, but I didn't need it the way you need Express/Hono in Node.

## GDAL and Shapefiles

Ohio publishes address data as shapefiles — a binary geospatial format from the '90s. To get this data into PostGIS, I used GDAL to convert shapefiles to GeoJSON:

```bash
ogr2ogr -f GeoJSON output.geojson input.shp -t_srs EPSG:4326
```

One of those problems where the tooling does all the work once you know which tool to reach for. GDAL is the Swiss Army knife of geospatial data conversion. If you haven't heard of it, now you have 🎉

## Would I use Go again?

For this kind of project — a focused API with clear inputs and outputs, no complex UI, needs to be fast and easy to deploy — absolutely.

For a full-stack app with a React frontend? I'd still reach for TypeScript and Bun. The shared types between frontend and backend are too valuable to give up.

The sweet spot for Go, at least for me, is standalone services and APIs where you want a single binary, fast startup, and low memory usage. The geocoding API checks all those boxes.

![Michael Scott - I'm not superstitious but I am a little stitious](https://media.giphy.com/media/3kzJvEciJa94SMW3hN/giphy.gif)
