# Herald Roadmap

## Priority 1: Gem Extraction Foundation

- [x] Engine packaging — Rails Engine with isolated namespace
- [x] Route mounting — `mount Herald::Engine` with separate public blog routes
- [x] Generators — `rails g herald:install` for migrations, initializer, routes
- [x] Decouple from Jumpstart — configurable owner/author, no hard dependencies
- [x] Asset pipeline isolation — self-contained views with extension points
- [x] Gemspec + README — standard gem packaging

## Priority 2: API Enhancements

- [x] API search — `?q=` param on posts index
- [x] API category filtering — `?category_slug=` on posts index
- [x] API tag filtering — `?tag_slug=` on posts index
- [x] API pagination metadata — page/total_pages/total_count in JSON (data/meta wrapping)
- [x] API post by slug — `GET /api/v1/herald/posts/by_slug/:slug`
- [x] API bulk operations — bulk publish/unpublish/delete
- [x] API tags CRUD — full CRUD for tags
- [x] Tags + pinned + featured_image_url in post JSON
- [x] Webhook delivery on publish — HMAC-SHA256 signed callbacks

## Priority 3: Core Content Features

- [x] Tags — lightweight tagging alongside categories
- [x] Featured image — dedicated featured_image_url field
- [x] Scheduled publishing — future published_at with background job
- [x] Post ordering/pinning — pin posts to top of blog index

## Priority 4: Content Management Polish

- [x] Draft preview — preview a draft as it would appear publicly
- [x] Revision history — automatic snapshots on title/excerpt changes
- [x] Slug editing — manual slug override on edit
- [x] Category management on post form — inline "create category" from post form
- [x] Image uploads in body — ActionText blob attachments
- [x] Reading time estimate — calculated from body word count (200 wpm)

## Priority 5: SEO & Distribution

- [x] Sitemap generation — XML sitemap for published posts
- [x] Canonical URLs — `<link rel="canonical">` on post pages
- [x] JSON-LD structured data — Article schema markup
- [x] Social sharing meta tags — Open Graph + Twitter Card
- [x] Atom feed — in addition to RSS

## Priority 6: Analytics & Engagement

- [x] View counts — post view tracking with bot filtering
- [x] Related posts — scoring by shared categories and tags
- [ ] Comments — optional commenting system
