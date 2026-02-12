# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2025-01-01

### Added

- Mountable Rails engine with admin UI, public blog, and JSON API
- Rich text editing with ActionText
- Featured images via ActiveStorage
- Categories and tags
- Post pinning and draft preview
- Revision history
- Slug editing and reading time estimates
- Scheduled publishing with `PublishScheduledPostsJob`
- View count tracking with bot filtering
- Related posts scored by shared categories and tags
- RSS and Atom feeds
- XML sitemap
- SEO meta tags (Open Graph, Twitter Card, JSON-LD)
- Webhook delivery on publish with HMAC-SHA256 signing and retry
- Bulk API operations (publish, unpublish, delete)
- Configurable authentication, layouts, and author model
